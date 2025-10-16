import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import '../models/pending_action.dart';
import 'offline_storage_service.dart';

/// Service for managing offline action queue
/// Stores QR scans when offline and syncs when connection is restored
class OfflineQueueService {
  final OfflineStorageService _storage;
  final Logger _logger = Logger();

  OfflineQueueService(this._storage);

  /// Queue a scan action for later sync
  Future<PendingAction> queueAction({
    required String qrCode,
    required String apiKey,
    String action = 'auto',
    bool isOfflineScan = true, // Default to true for queued actions
  }) async {
    try {
      final pendingAction = PendingAction.create(
        qrCode: qrCode,
        apiKey: apiKey,
        type: action,
        isOfflineScan: isOfflineScan,
      );

      final db = await _storage.database;
      await db.insert(
        'pending_actions',
        pendingAction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      _logger.i('Queued action: ${pendingAction.id} for QR: $qrCode');
      return pendingAction;
    } catch (e) {
      _logger.e('Failed to queue action: $e');
      rethrow;
    }
  }

  /// Get all pending (unsynced) actions
  Future<List<PendingAction>> getPendingActions() async {
    try {
      final db = await _storage.database;
      final results = await db.query(
        'pending_actions',
        where: 'synced = ?',
        whereArgs: [0],
        orderBy: 'timestamp ASC',
      );

      return results.map((map) => PendingAction.fromMap(map)).toList();
    } catch (e) {
      _logger.e('Failed to get pending actions: $e');
      return [];
    }
  }

  /// Get count of pending actions
  Future<int> getPendingCount() async {
    try {
      final db = await _storage.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM pending_actions WHERE synced = 0',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      _logger.e('Failed to get pending count: $e');
      return 0;
    }
  }

  /// Mark an action as synced
  Future<void> markAsSynced(String actionId) async {
    try {
      final db = await _storage.database;
      await db.update(
        'pending_actions',
        {'synced': 1, 'error': null},
        where: 'id = ?',
        whereArgs: [actionId],
      );
      _logger.i('Marked action as synced: $actionId');
    } catch (e) {
      _logger.e('Failed to mark action as synced: $e');
    }
  }

  /// Update action with retry count and error
  Future<void> updateActionRetry(PendingAction action) async {
    try {
      final db = await _storage.database;
      await db.update(
        'pending_actions',
        {
          'retry_count': action.retryCount,
          'error': action.error,
        },
        where: 'id = ?',
        whereArgs: [action.id],
      );
      _logger.i('Updated retry count for action: ${action.id}');
    } catch (e) {
      _logger.e('Failed to update action retry: $e');
    }
  }

  /// Delete an action (synced or max retries reached)
  Future<void> deleteAction(String actionId) async {
    try {
      final db = await _storage.database;
      await db.delete(
        'pending_actions',
        where: 'id = ?',
        whereArgs: [actionId],
      );
      _logger.i('Deleted action: $actionId');
    } catch (e) {
      _logger.e('Failed to delete action: $e');
    }
  }

  /// Clear all synced actions (cleanup)
  Future<int> clearSyncedActions() async {
    try {
      final db = await _storage.database;
      final count = await db.delete(
        'pending_actions',
        where: 'synced = ?',
        whereArgs: [1],
      );
      _logger.i('Cleared $count synced actions');
      return count;
    } catch (e) {
      _logger.e('Failed to clear synced actions: $e');
      return 0;
    }
  }

  /// Clear ALL pending actions (including failed/stuck ones)
  Future<int> clearAllPendingActions() async {
    try {
      final db = await _storage.database;
      final count = await db.delete('pending_actions');
      _logger.i('Cleared ALL $count pending actions');
      return count;
    } catch (e) {
      _logger.e('Failed to clear all pending actions: $e');
      return 0;
    }
  }

  /// Get all actions (for debugging)
  Future<List<PendingAction>> getAllActions() async {
    try {
      final db = await _storage.database;
      final results = await db.query(
        'pending_actions',
        orderBy: 'timestamp DESC',
      );

      return results.map((map) => PendingAction.fromMap(map)).toList();
    } catch (e) {
      _logger.e('Failed to get all actions: $e');
      return [];
    }
  }
}

