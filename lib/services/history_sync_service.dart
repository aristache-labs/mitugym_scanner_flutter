import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../providers/history_provider.dart';
import '../providers/config_provider.dart';

/// History sync service
/// Periodically syncs history from server in the background
class HistorySyncService {
  final Ref ref;
  final Logger _logger = Logger();
  Timer? _syncTimer;
  Timer? _cleanupTimer;
  bool _isRunning = false;

  HistorySyncService(this.ref);

  /// Start periodic sync (every 30 minutes)
  void startPeriodicSync() {
    if (_isRunning) {
      _logger.w('Sync service already running');
      return;
    }

    _isRunning = true;
    _logger.i('Starting periodic history sync service');

    // Perform initial sync
    Future.microtask(() => _performSync());

    // Schedule periodic sync every 30 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _performSync();
    });

    // Schedule daily cleanup check (every 24 hours)
    _cleanupTimer = Timer.periodic(const Duration(hours: 24), (timer) {
      _performCleanup();
    });
  }

  /// Stop periodic sync
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _cleanupTimer?.cancel();
    _syncTimer = null;
    _cleanupTimer = null;
    _isRunning = false;
    _logger.i('Stopped periodic history sync service');
  }

  /// Perform sync from server
  Future<void> _performSync() async {
    try {
      _logger.i('Performing scheduled history sync');
      await ref.read(historyProvider.notifier).syncFromServer();
      _logger.i('Scheduled history sync completed');
    } catch (e) {
      _logger.e('Failed to perform scheduled sync: $e');
    }
  }

  /// Perform cleanup of old records
  Future<void> _performCleanup() async {
    try {
      final config = ref.read(configProvider);
      final lastCleanup = config.lastHistorySync;
      
      // Only cleanup if last cleanup was more than 24 hours ago
      if (lastCleanup == null || 
          DateTime.now().difference(lastCleanup).inHours >= 24) {
        _logger.i('Performing scheduled history cleanup');
        final deletedCount = await ref.read(historyProvider.notifier).cleanupOldHistory();
        _logger.i('Cleanup completed: deleted $deletedCount old records');
      }
    } catch (e) {
      _logger.e('Failed to perform scheduled cleanup: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    stopPeriodicSync();
  }
}

/// Provider for history sync service
final historySyncServiceProvider = Provider<HistorySyncService>((ref) {
  final service = HistorySyncService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});

