import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/offline_storage_service.dart';
import '../services/connectivity_service.dart';
import '../services/api_service.dart';
import 'config_provider.dart';

/// Provider for offline storage service
final offlineStorageServiceProvider = Provider<OfflineStorageService>((ref) {
  return OfflineStorageService();
});

/// Offline state
class OfflineState {
  final bool isOnline;
  final int pendingSyncCount;
  final bool isSyncing;
  final String? syncError;

  const OfflineState({
    this.isOnline = true,
    this.pendingSyncCount = 0,
    this.isSyncing = false,
    this.syncError,
  });

  OfflineState copyWith({
    bool? isOnline,
    int? pendingSyncCount,
    bool? isSyncing,
    String? syncError,
  }) {
    return OfflineState(
      isOnline: isOnline ?? this.isOnline,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      isSyncing: isSyncing ?? this.isSyncing,
      syncError: syncError,
    );
  }
}

/// Offline provider notifier
class OfflineNotifier extends Notifier<OfflineState> {
  @override
  OfflineState build() {
    _initialize();
    return const OfflineState();
  }

  ConnectivityService? _connectivityService;
  OfflineStorageService? _offlineStorage;

  /// Initialize offline services
  Future<void> _initialize() async {
    try {
      // Initialize connectivity service
      _connectivityService = ConnectivityService();
      await _connectivityService!.initialize();

      // Listen to connectivity changes
      _connectivityService!.connectionStatus.listen((isOnline) {
        state = state.copyWith(isOnline: isOnline);
        if (isOnline) {
          syncPendingItems();
        }
      });

      // Check initial connectivity
      final isOnline = await _connectivityService!.checkConnection();
      state = state.copyWith(isOnline: isOnline);

      // Initialize offline storage
      _offlineStorage = OfflineStorageService();
      await _updatePendingCount();
    } catch (e) {
      state = state.copyWith(syncError: 'Failed to initialize offline mode: $e');
    }
  }

  /// Update pending sync count
  Future<void> _updatePendingCount() async {
    if (_offlineStorage == null) return;
    final pending = await _offlineStorage!.getPendingSyncItems();
    state = state.copyWith(pendingSyncCount: pending.length);
  }

  /// Sync pending items when connection is restored
  Future<void> syncPendingItems() async {
    if (!state.isOnline || _offlineStorage == null) return;
    if (state.isSyncing) return; // Already syncing

    state = state.copyWith(isSyncing: true, syncError: null);

    try {
      final pending = await _offlineStorage!.getPendingSyncItems();
      final config = ref.read(configProvider);
      final apiService = ApiService(apiUrl: config.apiUrl, apiKey: config.apiKey);

      for (final item in pending) {
        try {
          // Try to sync the item
          final qrCode = item['qr_code'] as String;
          final result = await apiService.checkInOut(qrCode, config.apiKey);

          if (result.success) {
            // Remove from queue if successful
            await _offlineStorage!.removeSyncedItem(item['id'] as int);
          } else {
            // Increment retry count
            await _offlineStorage!.incrementRetryCount(item['id'] as int);
          }
        } catch (e) {
          // Increment retry count on error
          await _offlineStorage!.incrementRetryCount(item['id'] as int);
        }
      }

      await _updatePendingCount();
      state = state.copyWith(isSyncing: false);
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        syncError: 'Sync failed: $e',
      );
    }
  }

  /// Manually trigger sync
  Future<void> manualSync() async {
    await syncPendingItems();
  }

  /// Sync now - force sync
  Future<void> syncNow() async {
    if (!state.isOnline) {
      state = state.copyWith(syncError: 'Cannot sync while offline');
      return;
    }
    await syncPendingItems();
  }

  /// Get offline storage service
  OfflineStorageService? get offlineStorage => _offlineStorage;

  /// Check if connected
  bool get isConnected => state.isOnline;
}

/// Provider for offline state
final offlineProvider = NotifierProvider<OfflineNotifier, OfflineState>(() {
  return OfflineNotifier();
});

/// Provider for offline storage service
final offlineStorageProvider = Provider<OfflineStorageService>((ref) {
  return OfflineStorageService();
});

/// Provider for connectivity service
final connectivityProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.initialize();
  return service;
});

