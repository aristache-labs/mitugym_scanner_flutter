import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scan_result.dart';
import '../models/activity_log.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/logger_service.dart';
import 'config_provider.dart';
import 'offline_provider.dart';
import 'history_provider.dart';
import 'offline_queue_provider.dart';

/// Scan state class
class ScanState {
  final bool isScanning;
  final bool cooldownActive;
  final int cooldownRemaining;
  final ScanResult? lastResult;
  final List<ActivityLog> recentActivity;
  final String? statusMessage;

  const ScanState({
    this.isScanning = false,
    this.cooldownActive = false,
    this.cooldownRemaining = 0,
    this.lastResult,
    this.recentActivity = const [],
    this.statusMessage,
  });

  ScanState copyWith({
    bool? isScanning,
    bool? cooldownActive,
    int? cooldownRemaining,
    ScanResult? lastResult,
    List<ActivityLog>? recentActivity,
    String? statusMessage,
  }) {
    return ScanState(
      isScanning: isScanning ?? this.isScanning,
      cooldownActive: cooldownActive ?? this.cooldownActive,
      cooldownRemaining: cooldownRemaining ?? this.cooldownRemaining,
      lastResult: lastResult ?? this.lastResult,
      recentActivity: recentActivity ?? this.recentActivity,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

/// Scan state notifier
class ScanNotifier extends Notifier<ScanState> {
  Timer? _cooldownTimer;

  @override
  ScanState build() {
    return const ScanState();
  }

  ApiService get _apiService => ref.read(apiServiceProvider);
  AudioService get _audioService => ref.read(audioServiceProvider);
  LoggerService get _loggerService => ref.read(loggerServiceProvider);

  /// Start scanning mode
  void startScanning() {
    state = state.copyWith(
      isScanning: true,
      statusMessage: 'Ready to scan...',
    );
  }

  /// Stop scanning mode
  void stopScanning() {
    _cooldownTimer?.cancel();
    state = state.copyWith(
      isScanning: false,
      cooldownActive: false,
      cooldownRemaining: 0,
      statusMessage: 'Scanning stopped',
    );
  }

  /// Process a scanned QR code
  Future<void> processScan(String qrCode) async {
    if (state.cooldownActive) {
      return; // Ignore scans during cooldown
    }

    // Get config and connectivity status
    final config = ref.read(configProvider);
    final isOnline = ref.read(offlineProvider).isOnline;
    
    // Use location API key from settings (NOT user's personal API key)
    // This is the API key for check-in/out operations
    final locationApiKey = config.apiKey;
    
    // Update status
    state = state.copyWith(statusMessage: 'Processing...');

    // If offline, queue the action
    if (!isOnline) {
      await _handleOfflineScan(qrCode, locationApiKey);
      _startCooldown(config.debounceDuration);
      return;
    }

    try {
      // Call API with location API key
      final result = await _apiService.checkInOut(qrCode, locationApiKey);
      
      // Update state with result
      state = state.copyWith(lastResult: result);

      // Save member data to local database for search
      if (result.data != null) {
        final storage = ref.read(offlineStorageServiceProvider);
        await storage.saveMemberLocally(result.data!);
      }
      
      // Play audio feedback
      if (result.success) {
        await _audioService.playSuccess();
        
        // Log success
        final memberName = result.data?.memberName ?? 'Unknown';
        final action = result.message;
        await _loggerService.logSuccess(memberName, action);
        
        // Add to in-memory activity log (max 10 for dashboard display)
        final activityLog = ActivityLog(
          memberName: memberName,
          action: action,
          time: DateTime.now(),
          success: true,
          avatarUrl: result.data?.avatarUrl,
          memberId: result.data?.memberId,
          memberData: result.data, // Store full member data for details modal
        );
        _addActivityLog(activityLog);
        
        // Wait a moment for server to process, then sync history
        // This ensures dashboard/history show correct session data
        Future.delayed(const Duration(milliseconds: 500), () {
          ref.read(historyProvider.notifier).clearAndSyncFromServer();
        });
        
        state = state.copyWith(statusMessage: result.message);
      } else {
        await _audioService.playError();
        
        // Log error
        await _loggerService.logError(
          result.error ?? 'Unknown error',
          'QR Code: $qrCode',
        );
        
        // Add to in-memory activity log
        final activityLog = ActivityLog(
          memberName: result.data?.memberName ?? 'Error',
          action: result.error ?? result.message,
          time: DateTime.now(),
          success: false,
          avatarUrl: result.data?.avatarUrl,
          memberId: result.data?.memberId,
          memberData: result.data, // Store full member data for details modal
        );
        _addActivityLog(activityLog);
        
        // Wait a moment for server to process, then sync history (includes this denied scan)
        Future.delayed(const Duration(milliseconds: 500), () {
          ref.read(historyProvider.notifier).clearAndSyncFromServer();
        });
        
        state = state.copyWith(statusMessage: result.error ?? result.message);
      }

      // Start cooldown
      _startCooldown(config.debounceDuration);
    } catch (e) {
      // Check if it's a connection error - if so, queue for later
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('connection') || 
          errorMessage.contains('network') ||
          errorMessage.contains('host lookup')) {
        // Connection error - queue for offline sync
        await _loggerService.logError('Connection error', 'Queuing scan for later');
        await _handleOfflineScan(qrCode, locationApiKey);
      } else {
        // Other error - handle normally
        await _audioService.playError();
        await _loggerService.logError('Exception during scan', e.toString());
        
        state = state.copyWith(
          lastResult: ScanResult.error('Error processing scan: $e'),
          statusMessage: 'Error: $e',
        );
      }
      
      _startCooldown(config.debounceDuration);
    }
  }

  /// Start cooldown timer
  void _startCooldown(int duration) {
    _cooldownTimer?.cancel();
    
    state = state.copyWith(
      cooldownActive: true,
      cooldownRemaining: duration,
    );

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.cooldownRemaining - 1;
      
      if (remaining <= 0) {
        timer.cancel();
        state = state.copyWith(
          cooldownActive: false,
          cooldownRemaining: 0,
          statusMessage: 'Ready to scan...',
        );
      } else {
        state = state.copyWith(cooldownRemaining: remaining);
      }
    });
  }

  /// Add activity to log (max 10 items)
  void _addActivityLog(ActivityLog log) {
    // Don't save to database - history will be synced from server
    // This prevents duplicate entries when server sync happens
    
    // Keep in-memory list for dashboard (max 10)
    final newActivity = [log, ...state.recentActivity];
    if (newActivity.length > 10) {
      newActivity.removeLast();
    }
    state = state.copyWith(recentActivity: newActivity);
  }

  /// Clear activity log
  void clearActivity() {
    state = state.copyWith(recentActivity: []);
  }

  /// Handle scan when offline - queue for later sync
  Future<void> _handleOfflineScan(String qrCode, String apiKey) async {
    try {
      // Queue the action for later sync
      await ref.read(offlineQueueProvider.notifier).queueAction(
        qrCode: qrCode,
        apiKey: apiKey,
      );
      
      // Play success sound for queuing
      await _audioService.playSuccess();
      
      // Log the queued action
      await _loggerService.logSuccess('Offline Scan', 'Queued for sync: $qrCode');
      
      // Add to activity log as "Pending"
      final activityLog = ActivityLog(
        memberName: 'Offline Scan',
        action: 'Queued for sync',
        time: DateTime.now(),
        success: true,
        avatarUrl: null,
        memberId: null,
        memberData: null,
      );
      _addActivityLog(activityLog);
      
      // Update state with success message
      state = state.copyWith(
        lastResult: ScanResult(
          success: true,
          message: 'Scan queued for sync',
          data: null,
        ),
        statusMessage: 'Queued for sync when online',
      );
    } catch (e) {
      // Handle error
      await _audioService.playError();
      await _loggerService.logError('Failed to queue offline scan', e.toString());
      
      state = state.copyWith(
        lastResult: ScanResult.error('Failed to queue scan: $e'),
        statusMessage: 'Error queuing scan',
      );
    }
  }

}

/// Provider for API Service
final apiServiceProvider = Provider<ApiService>((ref) {
  final config = ref.watch(configProvider);
  return ApiService(apiUrl: config.apiUrl, apiKey: config.apiKey);
});

/// Provider for Audio Service
final audioServiceProvider = Provider<AudioService>((ref) {
  final config = ref.watch(configProvider);
  return AudioService(audioEnabled: config.audioEnabled);
});

/// Provider for Logger Service
final loggerServiceProvider = Provider<LoggerService>((ref) {
  final service = LoggerService();
  service.initialize();
  return service;
});

/// Provider for scan state
final scanProvider = NotifierProvider<ScanNotifier, ScanState>(() {
  return ScanNotifier();
});

