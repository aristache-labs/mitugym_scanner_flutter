import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/pending_action.dart';
import '../services/offline_queue_service.dart';
import '../services/api_service.dart';
import 'offline_provider.dart';
import 'scan_provider.dart';

/// Offline queue state
class OfflineQueueState {
  final List<PendingAction> pendingActions;
  final bool isSyncing;
  final int syncedCount;
  final String? error;

  const OfflineQueueState({
    this.pendingActions = const [],
    this.isSyncing = false,
    this.syncedCount = 0,
    this.error,
  });

  OfflineQueueState copyWith({
    List<PendingAction>? pendingActions,
    bool? isSyncing,
    int? syncedCount,
    String? error,
  }) {
    return OfflineQueueState(
      pendingActions: pendingActions ?? this.pendingActions,
      isSyncing: isSyncing ?? this.isSyncing,
      syncedCount: syncedCount ?? this.syncedCount,
      error: error,
    );
  }

  int get pendingCount => pendingActions.where((a) => !a.synced).length;
}

/// Offline queue provider notifier
class OfflineQueueNotifier extends Notifier<OfflineQueueState> {
  final Logger _logger = Logger();
  OfflineQueueService? _queueService;
  ApiService? _apiService;

  @override
  OfflineQueueState build() {
    // Load pending actions on init
    _loadPendingActions();
    return const OfflineQueueState();
  }

  /// Get queue service
  OfflineQueueService _getQueueService() {
    if (_queueService == null) {
      final offlineStorage = ref.read(offlineStorageServiceProvider);
      _queueService = OfflineQueueService(offlineStorage);
    }
    return _queueService!;
  }

  /// Get API service
  ApiService _getApiService() {
    _apiService ??= ref.read(apiServiceProvider);
    return _apiService!;
  }

  /// Load pending actions from database
  Future<void> _loadPendingActions() async {
    try {
      final queueService = _getQueueService();
      final actions = await queueService.getPendingActions();
      state = state.copyWith(pendingActions: actions);
    } catch (e) {
      _logger.e('Failed to load pending actions: $e');
    }
  }

  /// Queue an action when offline
  Future<void> queueAction({
    required String qrCode,
    required String apiKey,
    String action = 'auto',
  }) async {
    try {
      final queueService = _getQueueService();
      final pendingAction = await queueService.queueAction(
        qrCode: qrCode,
        apiKey: apiKey,
        action: action,
      );

      // Add to state
      final updatedActions = [...state.pendingActions, pendingAction];
      state = state.copyWith(pendingActions: updatedActions);

      _logger.i('Action queued: ${pendingAction.id}');
    } catch (e) {
      _logger.e('Failed to queue action: $e');
      state = state.copyWith(error: 'Failed to queue action: $e');
    }
  }

  /// Sync all pending actions with server
  Future<void> syncPendingActions() async {
    if (state.isSyncing) {
      _logger.w('Sync already in progress');
      return;
    }

    final pendingActions = state.pendingActions.where((a) => !a.synced).toList();
    if (pendingActions.isEmpty) {
      _logger.i('No pending actions to sync');
      return;
    }

    state = state.copyWith(isSyncing: true, syncedCount: 0, error: null);
    _logger.i('Starting sync of ${pendingActions.length} actions');

    int successCount = 0;
    final queueService = _getQueueService();
    final apiService = _getApiService();

    for (final action in pendingActions) {
      try {
        // Skip if max retries reached
        if (!action.canRetry()) {
          _logger.w('Max retries reached for action: ${action.id}');
          await queueService.deleteAction(action.id);
          continue;
        }

        // Attempt to sync with offline flag
        final result = await apiService.checkInOut(
          action.qrCode, // Contains just member_id for offline scans
          action.apiKey,
          isOfflineScan: action.isOfflineScan, // Pass offline flag to skip TOTP
        );

        if (result.success) {
          // Mark as synced
          await queueService.markAsSynced(action.id);
          successCount++;
          _logger.i('Synced action: ${action.id}');
        } else {
          // Increment retry count
          final updatedAction = action.incrementRetry(
            errorMessage: result.error ?? result.message,
          );
          await queueService.updateActionRetry(updatedAction);
          _logger.w('Failed to sync action ${action.id}: ${result.error}');
        }
      } catch (e) {
        _logger.e('Error syncing action ${action.id}: $e');
        
        // Increment retry count
        final updatedAction = action.incrementRetry(errorMessage: e.toString());
        await queueService.updateActionRetry(updatedAction);
      }
    }

    // Reload pending actions
    await _loadPendingActions();

    // Clear synced actions from database
    await queueService.clearSyncedActions();

    state = state.copyWith(
      isSyncing: false,
      syncedCount: successCount,
    );

    _logger.i('Sync complete. Synced: $successCount/${pendingActions.length}');
  }

  /// Get pending count
  Future<int> getPendingCount() async {
    try {
      final queueService = _getQueueService();
      return await queueService.getPendingCount();
    } catch (e) {
      _logger.e('Failed to get pending count: $e');
      return 0;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh pending actions
  Future<void> refresh() async {
    await _loadPendingActions();
  }

  /// Clear all pending actions (including failed/stuck ones)
  Future<void> clearAllPending() async {
    try {
      final queueService = _getQueueService();
      final count = await queueService.clearAllPendingActions();
      _logger.i('Cleared $count pending actions');
      
      // Reload state
      await _loadPendingActions();
    } catch (e) {
      _logger.e('Failed to clear all pending actions: $e');
      state = state.copyWith(error: 'Failed to clear pending actions');
    }
  }
}

/// Provider for offline queue state
final offlineQueueProvider = NotifierProvider<OfflineQueueNotifier, OfflineQueueState>(() {
  return OfflineQueueNotifier();
});

