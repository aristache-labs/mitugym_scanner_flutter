import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../providers/history_provider.dart';
import '../providers/gym_schedule_provider.dart';
import '../providers/offline_queue_provider.dart';
import '../providers/offline_provider.dart';

/// Comprehensive data sync service
/// Coordinates all data synchronization across the app
/// Triggered after QR code scans or when connection is restored
class DataSyncService {
  final Ref ref;
  final Logger _logger = Logger();
  bool _isSyncing = false;

  DataSyncService(this.ref);

  /// Sync all data across the entire app
  /// This is the main function to call after QR code scans
  /// 
  /// [forceSync] - Force sync even if recently synced
  /// [syncHistory] - Include history sync (default: true)
  /// [syncSchedule] - Include gym schedule sync (default: true)
  /// [syncOfflineQueue] - Include offline queue sync (default: true)
  Future<SyncResult> syncAllData({
    bool forceSync = false,
    bool syncHistory = true,
    bool syncSchedule = true,
    bool syncOfflineQueue = true,
  }) async {
    if (_isSyncing && !forceSync) {
      _logger.w('Sync already in progress, skipping...');
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
      );
    }

    _isSyncing = true;
    final startTime = DateTime.now();
    _logger.i('🔄 Starting comprehensive data sync...');

    final results = <String, bool>{};
    final errors = <String>[];

    try {
      // Check if online
      final isOnline = ref.read(offlineProvider).isOnline;
      if (!isOnline) {
        _logger.w('Device is offline, skipping server sync');
        _isSyncing = false;
        return SyncResult(
          success: false,
          message: 'Device is offline',
          syncedItems: results,
          errors: ['Device is offline'],
        );
      }

      // 1. Sync offline queue first (if any pending actions)
      if (syncOfflineQueue) {
        try {
          _logger.i('📤 Syncing offline queue...');
          final queueState = ref.read(offlineQueueProvider);
          final pendingCount = queueState.pendingCount;
          
          if (pendingCount > 0) {
            await ref.read(offlineQueueProvider.notifier).syncPendingActions();
            _logger.i('✅ Offline queue synced ($pendingCount items)');
            results['offlineQueue'] = true;
          } else {
            _logger.i('✓ No pending offline actions');
            results['offlineQueue'] = true;
          }
        } catch (e) {
          _logger.e('❌ Failed to sync offline queue: $e');
          errors.add('Offline queue sync failed: $e');
          results['offlineQueue'] = false;
        }
      }

      // 2. Sync history from server
      if (syncHistory) {
        try {
          _logger.i('📥 Syncing history from server...');
          await ref.read(historyProvider.notifier).syncFromServer();
          _logger.i('✅ History synced successfully');
          results['history'] = true;
        } catch (e) {
          _logger.e('❌ Failed to sync history: $e');
          errors.add('History sync failed: $e');
          results['history'] = false;
        }
      }

      // 3. Refresh gym schedule
      if (syncSchedule) {
        try {
          _logger.i('📅 Refreshing gym schedule...');
          await ref.read(gymScheduleProvider.notifier).fetchSchedule();
          _logger.i('✅ Gym schedule refreshed');
          results['schedule'] = true;
        } catch (e) {
          _logger.e('❌ Failed to refresh gym schedule: $e');
          errors.add('Schedule sync failed: $e');
          results['schedule'] = false;
        }
      }

      final duration = DateTime.now().difference(startTime);
      final allSuccess = results.values.every((success) => success);
      
      if (allSuccess) {
        _logger.i('✅ All data synced successfully in ${duration.inMilliseconds}ms');
      } else {
        _logger.w('⚠️ Data sync completed with some errors in ${duration.inMilliseconds}ms');
      }

      _isSyncing = false;
      return SyncResult(
        success: allSuccess,
        message: allSuccess 
            ? 'All data synced successfully' 
            : 'Some sync operations failed',
        syncedItems: results,
        errors: errors,
        duration: duration,
      );
    } catch (e) {
      _logger.e('❌ Critical error during sync: $e');
      _isSyncing = false;
      return SyncResult(
        success: false,
        message: 'Critical sync error',
        syncedItems: results,
        errors: [...errors, 'Critical error: $e'],
      );
    }
  }

  /// Quick sync - only essential data (history)
  /// Used after successful QR scans
  Future<SyncResult> quickSync() async {
    _logger.i('⚡ Quick sync initiated');
    return syncAllData(
      syncHistory: true,
      syncSchedule: false,
      syncOfflineQueue: false,
    );
  }

  /// Full sync - all data including schedule and offline queue
  /// Used on app startup or manual refresh
  Future<SyncResult> fullSync() async {
    _logger.i('🔄 Full sync initiated');
    return syncAllData(
      forceSync: true,
      syncHistory: true,
      syncSchedule: true,
      syncOfflineQueue: true,
    );
  }

  /// Sync after coming back online
  /// Prioritizes offline queue, then history
  Future<SyncResult> syncAfterReconnect() async {
    _logger.i('🌐 Reconnection sync initiated');
    return syncAllData(
      forceSync: true,
      syncHistory: true,
      syncSchedule: true,
      syncOfflineQueue: true,
    );
  }

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;
}

/// Sync result class
class SyncResult {
  final bool success;
  final String message;
  final Map<String, bool> syncedItems;
  final List<String> errors;
  final Duration? duration;

  SyncResult({
    required this.success,
    required this.message,
    this.syncedItems = const {},
    this.errors = const [],
    this.duration,
  });

  @override
  String toString() {
    return 'SyncResult(success: $success, message: $message, items: $syncedItems, errors: ${errors.length})';
  }
}

/// Provider for data sync service
final dataSyncServiceProvider = Provider<DataSyncService>((ref) {
  return DataSyncService(ref);
});

