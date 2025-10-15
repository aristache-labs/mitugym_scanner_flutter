import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:logger/logger.dart';
import '../models/member_data.dart';
import '../models/activity_log.dart';

/// Offline storage service using SQLite
/// Stores member data and check-in history locally for offline support
class OfflineStorageService {
  static Database? _database;
  final Logger _logger = Logger();
  
  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  /// Initialize database
  Future<Database> _initDatabase() async {
    try {
      // Initialize FFI for desktop
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      
      final dbPath = await databaseFactoryFfi.getDatabasesPath();
      final path = '$dbPath/mitugym_offline.db';
      
      _logger.i('Initializing offline database at: $path');
      
      return await openDatabase(
        path,
        version: 2,
        onCreate: _createTables,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      _logger.e('Failed to initialize database: $e');
      rethrow;
    }
  }
  
  /// Create database tables
  Future<void> _createTables(Database db, int version) async {
    // Members table
    await db.execute('''
      CREATE TABLE members (
        member_id TEXT PRIMARY KEY,
        member_name TEXT NOT NULL,
        plan_name TEXT NOT NULL,
        expires_at TEXT NOT NULL,
        membership_status TEXT NOT NULL,
        avatar_url TEXT,
        last_updated INTEGER NOT NULL
      )
    ''');
    
    // Check-in history table
    await db.execute('''
      CREATE TABLE checkin_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        member_id TEXT,
        member_name TEXT NOT NULL,
        action TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        success INTEGER NOT NULL,
        synced INTEGER DEFAULT 0,
        avatar_url TEXT
      )
    ''');
    
    // Create index for faster queries
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_timestamp 
      ON checkin_history(timestamp)
    ''');
    
    // Pending sync queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        qr_code TEXT NOT NULL,
        action TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');
    
    _logger.i('Database tables created successfully');
  }
  
  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.i('Upgrading database from v$oldVersion to v$newVersion');
    
    if (oldVersion < 2) {
      // Add avatar_url column to checkin_history table
      try {
        await db.execute('ALTER TABLE checkin_history ADD COLUMN avatar_url TEXT');
        _logger.i('Added avatar_url column to checkin_history table');
      } catch (e) {
        _logger.w('Could not add avatar_url column (may already exist): $e');
      }
      
      // Create index for faster queries
      try {
        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_timestamp 
          ON checkin_history(timestamp)
        ''');
        _logger.i('Created index on timestamp column');
      } catch (e) {
        _logger.w('Could not create index: $e');
      }
    }
  }
  
  /// Save member data locally
  Future<void> saveMemberLocally(MemberData member) async {
    try {
      final db = await database;
      await db.insert(
        'members',
        {
          'member_id': member.memberId,
          'member_name': member.memberName,
          'plan_name': member.planName,
          'expires_at': member.expiresAt,
          'membership_status': member.membershipStatus,
          'avatar_url': member.avatarUrl,
          'last_updated': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.d('Saved member ${member.memberName} to offline storage');
    } catch (e) {
      _logger.e('Failed to save member locally: $e');
    }
  }
  
  /// Get member from local storage by ID
  Future<MemberData?> getMemberById(String memberId) async {
    try {
      final db = await database;
      final results = await db.query(
        'members',
        where: 'member_id = ?',
        whereArgs: [memberId],
        limit: 1,
      );
      
      if (results.isEmpty) return null;
      
      final data = results.first;
      return MemberData(
        memberId: data['member_id'] as String,
        memberName: data['member_name'] as String,
        planName: data['plan_name'] as String,
        expiresAt: data['expires_at'] as String,
        membershipStatus: data['membership_status'] as String,
        avatarUrl: data['avatar_url'] as String?,
      );
    } catch (e) {
      _logger.e('Failed to get member by ID: $e');
      return null;
    }
  }
  
  /// Get all offline members
  Future<List<MemberData>> getOfflineMembers({
    String? statusFilter,
    int limit = 100,
  }) async {
    try {
      final db = await database;
      final results = await db.query(
        'members',
        where: statusFilter != null ? 'membership_status = ?' : null,
        whereArgs: statusFilter != null ? [statusFilter] : null,
        orderBy: 'last_updated DESC',
        limit: limit,
      );
      
      return results.map((data) => MemberData(
        memberId: data['member_id'] as String,
        memberName: data['member_name'] as String,
        planName: data['plan_name'] as String,
        expiresAt: data['expires_at'] as String,
        membershipStatus: data['membership_status'] as String,
        avatarUrl: data['avatar_url'] as String?,
      )).toList();
    } catch (e) {
      _logger.e('Failed to get offline members: $e');
      return [];
    }
  }
  
  /// Save check-in to history (prevents duplicates)
  Future<void> saveCheckInHistory(ActivityLog activity, {bool synced = true}) async {
    try {
      final db = await database;
      
      // Check for duplicate entry (same member, action, and timestamp within 5 seconds)
      final timestampStart = activity.time.millisecondsSinceEpoch - 5000;
      final timestampEnd = activity.time.millisecondsSinceEpoch + 5000;
      
      final existing = await db.query(
        'checkin_history',
        where: 'member_name = ? AND action = ? AND timestamp BETWEEN ? AND ?',
        whereArgs: [activity.memberName, activity.action, timestampStart, timestampEnd],
        limit: 1,
      );
      
      // If duplicate exists, skip insertion
      if (existing.isNotEmpty) {
        _logger.d('Duplicate entry detected for ${activity.memberName}, skipping');
        return;
      }
      
      // Insert new record
      await db.insert('checkin_history', {
        'member_id': activity.memberId ?? '',
        'member_name': activity.memberName,
        'action': activity.action,
        'timestamp': activity.time.millisecondsSinceEpoch,
        'success': activity.success ? 1 : 0,
        'synced': synced ? 1 : 0,
        'avatar_url': activity.avatarUrl,
      });
      _logger.d('Saved check-in history for ${activity.memberName}');
    } catch (e) {
      _logger.e('Failed to save check-in history: $e');
    }
  }
  
  /// Get check-in history
  Future<List<ActivityLog>> getCheckInHistory({
    int limit = 100,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? statusFilter,
  }) async {
    try {
      final db = await database;
      
      final whereConditions = <String>[];
      final whereArgs = <dynamic>[];
      
      if (startDate != null && endDate != null) {
        whereConditions.add('timestamp BETWEEN ? AND ?');
        whereArgs.add(startDate.millisecondsSinceEpoch);
        whereArgs.add(endDate.millisecondsSinceEpoch);
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereConditions.add('member_name LIKE ?');
        whereArgs.add('%$searchQuery%');
      }
      
      if (statusFilter != null && statusFilter != 'all') {
        if (statusFilter == 'success') {
          whereConditions.add('success = 1');
        } else if (statusFilter == 'failed') {
          whereConditions.add('success = 0');
        }
      }
      
      final results = await db.query(
        'checkin_history',
        where: whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'timestamp DESC',
        limit: limit,
        offset: offset,
      );
      
      return results.map((data) => ActivityLog(
        memberName: data['member_name'] as String,
        action: data['action'] as String,
        time: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int),
        success: (data['success'] as int) == 1,
        memberId: (data['member_id'] as String?)?.isNotEmpty == true ? data['member_id'] as String : null,
        avatarUrl: data['avatar_url'] as String?,
      )).toList();
    } catch (e) {
      _logger.e('Failed to get check-in history: $e');
      return [];
    }
  }
  
  /// Queue a check-in for later sync
  Future<void> queueCheckIn(String qrCode, String action) async {
    try {
      final db = await database;
      await db.insert('sync_queue', {
        'qr_code': qrCode,
        'action': action,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'retry_count': 0,
      });
      _logger.i('Queued check-in for sync: $qrCode');
    } catch (e) {
      _logger.e('Failed to queue check-in: $e');
    }
  }
  
  /// Get pending sync items
  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    try {
      final db = await database;
      return await db.query(
        'sync_queue',
        orderBy: 'timestamp ASC',
      );
    } catch (e) {
      _logger.e('Failed to get pending sync items: $e');
      return [];
    }
  }
  
  /// Remove synced item from queue
  Future<void> removeSyncedItem(int id) async {
    try {
      final db = await database;
      await db.delete(
        'sync_queue',
        where: 'id = ?',
        whereArgs: [id],
      );
      _logger.d('Removed synced item: $id');
    } catch (e) {
      _logger.e('Failed to remove synced item: $e');
    }
  }
  
  /// Increment retry count for failed sync
  Future<void> incrementRetryCount(int id) async {
    try {
      final db = await database;
      await db.rawUpdate(
        'UPDATE sync_queue SET retry_count = retry_count + 1 WHERE id = ?',
        [id],
      );
    } catch (e) {
      _logger.e('Failed to increment retry count: $e');
    }
  }
  
  /// Clear old data (for cleanup)
  Future<void> clearOldData(int daysToKeep) async {
    try {
      final db = await database;
      final cutoffTime = DateTime.now()
          .subtract(Duration(days: daysToKeep))
          .millisecondsSinceEpoch;
      
      // Clear old check-in history
      await db.delete(
        'checkin_history',
        where: 'timestamp < ? AND synced = 1',
        whereArgs: [cutoffTime],
      );
      
      _logger.i('Cleared check-in history older than $daysToKeep days');
    } catch (e) {
      _logger.e('Failed to clear old data: $e');
    }
  }
  
  /// Get total count of check-in history records
  Future<int> getCheckInHistoryCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM checkin_history');
      if (result.isNotEmpty && result.first['count'] != null) {
        return result.first['count'] as int;
      }
      return 0;
    } catch (e) {
      _logger.e('Failed to get check-in history count: $e');
      return 0;
    }
  }
  
  /// Clear all history (for fresh sync from server)
  Future<void> clearAllHistory() async {
    try {
      final db = await database;
      await db.delete('checkin_history');
      _logger.i('Cleared all local history');
    } catch (e) {
      _logger.e('Failed to clear all history: $e');
    }
  }

  /// Delete old history records based on retention days
  Future<int> deleteOldHistory(int daysToKeep) async {
    try {
      final db = await database;
      final cutoffTime = DateTime.now()
          .subtract(Duration(days: daysToKeep))
          .millisecondsSinceEpoch;
      
      final deletedCount = await db.delete(
        'checkin_history',
        where: 'timestamp < ?',
        whereArgs: [cutoffTime],
      );
      
      _logger.i('Deleted $deletedCount records older than $daysToKeep days');
      return deletedCount;
    } catch (e) {
      _logger.e('Failed to delete old history: $e');
      return 0;
    }
  }
  
  /// Remove duplicate entries from database
  Future<int> removeDuplicates() async {
    try {
      final db = await database;
      
      // Find duplicates (same member_name, action, and timestamp within 5 seconds)
      final duplicates = await db.rawQuery('''
        SELECT member_name, action, timestamp, COUNT(*) as count
        FROM checkin_history
        GROUP BY member_name, action, timestamp
        HAVING count > 1
      ''');
      
      int deletedCount = 0;
      
      for (final dup in duplicates) {
        final memberName = dup['member_name'] as String;
        final action = dup['action'] as String;
        final timestamp = dup['timestamp'] as int;
        
        // Get all duplicates for this entry
        final entries = await db.query(
          'checkin_history',
          where: 'member_name = ? AND action = ? AND timestamp = ?',
          whereArgs: [memberName, action, timestamp],
          orderBy: 'id ASC',
        );
        
        // Keep the first one, delete the rest
        if (entries.length > 1) {
          for (int i = 1; i < entries.length; i++) {
            await db.delete(
              'checkin_history',
              where: 'id = ?',
              whereArgs: [entries[i]['id']],
            );
            deletedCount++;
          }
        }
      }
      
      _logger.i('Removed $deletedCount duplicate entries');
      return deletedCount;
    } catch (e) {
      _logger.e('Failed to remove duplicates: $e');
      return 0;
    }
  }
  
  /// Search members by name
  Future<List<MemberData>> searchMembers(String query) async {
    try {
      final db = await database;
      final results = await db.query(
        'members',
        where: 'member_name LIKE ? OR member_id LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'member_name ASC',
        limit: 50,
      );
      
      return results.map((data) => MemberData(
        memberId: data['member_id'] as String,
        memberName: data['member_name'] as String,
        planName: data['plan_name'] as String,
        expiresAt: data['expires_at'] as String,
        membershipStatus: data['membership_status'] as String,
        avatarUrl: data['avatar_url'] as String?,
      )).toList();
    } catch (e) {
      _logger.e('Failed to search members: $e');
      return [];
    }
  }
  
  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    _logger.i('Database closed');
  }
}

