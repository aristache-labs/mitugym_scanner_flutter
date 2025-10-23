import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/activity_log.dart';
import '../services/api_service.dart';
import '../services/logger_service.dart';
import 'offline_provider.dart';
import 'config_provider.dart';
import 'logger_provider.dart' as logger_provider;

/// History state
class HistoryState {
  final List<ActivityLog> items;
  final bool isLoading;
  final bool hasMore;
  final int offset;
  final String? error;
  final String searchQuery;
  final String statusFilter;
  final DateTimeRange? dateRange;

  const HistoryState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.offset = 0,
    this.error,
    this.searchQuery = '',
    this.statusFilter = 'all',
    this.dateRange,
  });

  HistoryState copyWith({
    List<ActivityLog>? items,
    bool? isLoading,
    bool? hasMore,
    int? offset,
    String? error,
    String? searchQuery,
    String? statusFilter,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
  }) {
    return HistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
    );
  }
}

/// History provider notifier
class HistoryNotifier extends Notifier<HistoryState> {
  static const int pageSize = 50;
  final Logger _logger = Logger();
  
  LoggerService get _verboseLogger => ref.read(logger_provider.loggerServiceProvider);

  @override
  HistoryState build() {
    return const HistoryState();
  }

  /// Load initial history from database
  Future<void> loadInitialHistory() async {
    _verboseLogger.logDebug('Loading initial history from database', source: 'HistoryProvider');
    state = state.copyWith(isLoading: true, error: null, offset: 0);

    try {
      _verboseLogger.logDebug('Fetching history - limit: $pageSize, offset: 0', source: 'HistoryProvider');
      final storage = ref.read(offlineStorageServiceProvider);
      final items = await storage.getCheckInHistory(
        limit: pageSize,
        offset: 0,
        startDate: state.dateRange?.start,
        endDate: state.dateRange?.end,
        searchQuery: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        statusFilter: state.statusFilter,
      );

      _verboseLogger.logDebug('Loaded ${items.length} history items', source: 'HistoryProvider');
      state = state.copyWith(
        items: items,
        isLoading: false,
        hasMore: items.length >= pageSize,
        offset: pageSize,
      );
    } catch (e) {
      _logger.e('Failed to load history: $e');
      _verboseLogger.logDebug('Error loading history: $e', source: 'HistoryProvider');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load more history (pagination)
  Future<void> loadMoreHistory() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final storage = ref.read(offlineStorageServiceProvider);
      final newItems = await storage.getCheckInHistory(
        limit: pageSize,
        offset: state.offset,
        startDate: state.dateRange?.start,
        endDate: state.dateRange?.end,
        searchQuery: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        statusFilter: state.statusFilter,
      );

      state = state.copyWith(
        items: [...state.items, ...newItems],
        isLoading: false,
        hasMore: newItems.length >= pageSize,
        offset: state.offset + pageSize,
      );
    } catch (e) {
      _logger.e('Failed to load more history: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Apply filters and reload
  Future<void> applyFilters({
    String? searchQuery,
    String? statusFilter,
    DateTimeRange? dateRange,
  }) async {
    state = state.copyWith(
      searchQuery: searchQuery,
      statusFilter: statusFilter,
      dateRange: dateRange,
      offset: 0,
    );

    await loadInitialHistory();
  }

  /// Clear filters
  Future<void> clearFilters() async {
    state = state.copyWith(
      searchQuery: '',
      statusFilter: 'all',
      clearDateRange: true,
      offset: 0,
    );

    await loadInitialHistory();
  }

  /// Clear local history and sync fresh from server
  Future<void> clearAndSyncFromServer() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final config = ref.read(configProvider);
      final apiService = ApiService(
        apiUrl: config.apiUrl,
        apiKey: config.apiKey,
      );
      final storage = ref.read(offlineStorageServiceProvider);

      // Clear all local history
      _logger.i('Clearing local history...');
      await storage.clearAllHistory();

      // Fetch fresh history from server (last 90 days or retention period)
      final sinceDate = DateTime.now().subtract(
        Duration(days: config.historyRetentionDays),
      );

      _logger.i('Fetching fresh history from server since: $sinceDate');
      final serverHistory = await apiService.fetchHistoryFromServer(
        sinceDate: sinceDate,
        limit: 1000, // Fetch more for initial sync
      );

      // Save to local database
      _logger.i('Saving ${serverHistory.length} records to local database...');
      for (final activity in serverHistory) {
        await storage.saveCheckInHistory(activity, synced: true);
      }

      // Update last sync timestamp
      await ref.read(configProvider.notifier).updateLastHistorySync(DateTime.now());

      // Reload history
      await loadInitialHistory();

      _logger.i('✅ Synced ${serverHistory.length} fresh records from server');
    } catch (e) {
      _logger.e('Failed to clear and sync from server: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Sync failed: ${e.toString()}',
      );
    }
  }

  /// Sync from server (incremental - fetch only new records)
  Future<void> syncFromServer() async {
    _verboseLogger.logDebug('Starting incremental sync from server', source: 'HistoryProvider');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final config = ref.read(configProvider);
      final apiService = ApiService(
        apiUrl: config.apiUrl,
        apiKey: config.apiKey,
        verboseLogger: _verboseLogger,
      );

      // Get last sync timestamp
      final lastSync = config.lastHistorySync ?? 
          DateTime.now().subtract(const Duration(days: 7));
      
      _verboseLogger.logDebug('Last sync was: $lastSync', source: 'HistoryProvider');

      // Fetch history from server
      final serverHistory = await apiService.fetchHistoryFromServer(
        sinceDate: lastSync,
        limit: 500,
      );

      _verboseLogger.logDebug('Received ${serverHistory.length} records from server', source: 'HistoryProvider');

      // Save to local database
      final storage = ref.read(offlineStorageServiceProvider);
      for (final activity in serverHistory) {
        await storage.saveCheckInHistory(activity, synced: true);
      }

      _verboseLogger.logDebug('Saved all records to local database', source: 'HistoryProvider');

      // Update last sync timestamp
      await ref.read(configProvider.notifier).updateLastHistorySync(DateTime.now());

      // Reload history
      await loadInitialHistory();

      _logger.i('Synced ${serverHistory.length} records from server');
      _verboseLogger.logDebug('Sync completed successfully', source: 'HistoryProvider');
    } catch (e) {
      _logger.e('Failed to sync from server: $e');
      _verboseLogger.logDebug('Sync failed: $e', source: 'HistoryProvider');
      state = state.copyWith(
        isLoading: false,
        error: 'Sync failed: ${e.toString()}',
      );
    }
  }

  /// Cleanup old history
  Future<int> cleanupOldHistory() async {
    try {
      final config = ref.read(configProvider);
      final storage = ref.read(offlineStorageServiceProvider);
      
      final deletedCount = await storage.deleteOldHistory(
        config.historyRetentionDays,
      );

      _logger.i('Cleaned up $deletedCount old records');

      // Reload history
      await loadInitialHistory();

      return deletedCount;
    } catch (e) {
      _logger.e('Failed to cleanup old history: $e');
      return 0;
    }
  }

  /// Refresh history
  Future<void> refreshHistory() async {
    await loadInitialHistory();
  }

  /// Get total record count
  Future<int> getTotalCount() async {
    try {
      final storage = ref.read(offlineStorageServiceProvider);
      return await storage.getCheckInHistoryCount();
    } catch (e) {
      _logger.e('Failed to get total count: $e');
      return 0;
    }
  }

  /// Add activity immediately (for real-time updates from scanner)
  Future<void> addActivity(ActivityLog activity) async {
    try {
      // Add to local storage
      final storage = ref.read(offlineStorageServiceProvider);
      await storage.saveCheckInHistory(activity, synced: false);

      // Add to the beginning of the in-memory list for immediate UI update
      final updatedItems = [activity, ...state.items];
      state = state.copyWith(items: updatedItems);

      _logger.i('Added activity to history: ${activity.memberName}');
    } catch (e) {
      _logger.e('Failed to add activity: $e');
    }
  }
}

/// Provider for history
final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(() {
  return HistoryNotifier();
});

