import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scan_result.dart';
import '../models/activity_log.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/logger_service.dart';
import 'config_provider.dart';

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
class ScanNotifier extends StateNotifier<ScanState> {
  final ApiService _apiService;
  final AudioService _audioService;
  final LoggerService _loggerService;
  final Ref _ref;
  
  Timer? _cooldownTimer;

  ScanNotifier(
    this._apiService,
    this._audioService,
    this._loggerService,
    this._ref,
  ) : super(const ScanState());

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

    // Get config
    final config = _ref.read(configProvider);
    
    // Update status
    state = state.copyWith(statusMessage: 'Processing...');

    try {
      // Call API
      final result = await _apiService.checkInOut(qrCode, config.apiKey);
      
      // Update state with result
      state = state.copyWith(lastResult: result);

      // Play audio feedback
      if (result.success) {
        await _audioService.playSuccess();
        
        // Log success
        final memberName = result.data?.memberName ?? 'Unknown';
        final action = result.message;
        await _loggerService.logSuccess(memberName, action);
        
        // Add to activity log
        _addActivityLog(ActivityLog(
          memberName: memberName,
          action: action,
          time: DateTime.now(),
          success: true,
        ));
        
        state = state.copyWith(statusMessage: result.message);
      } else {
        await _audioService.playError();
        
        // Log error
        await _loggerService.logError(
          result.error ?? 'Unknown error',
          'QR Code: $qrCode',
        );
        
        // Add to activity log
        _addActivityLog(ActivityLog(
          memberName: 'Error',
          action: result.error ?? result.message,
          time: DateTime.now(),
          success: false,
        ));
        
        state = state.copyWith(statusMessage: result.error ?? result.message);
      }

      // Start cooldown
      _startCooldown(config.debounceDuration);
    } catch (e) {
      await _audioService.playError();
      await _loggerService.logError('Exception during scan', e.toString());
      
      state = state.copyWith(
        lastResult: ScanResult.error('Error processing scan: $e'),
        statusMessage: 'Error: $e',
      );
      
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

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}

/// Provider for API Service
final apiServiceProvider = Provider<ApiService>((ref) {
  final config = ref.watch(configProvider);
  return ApiService(baseUrl: config.apiUrl);
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
final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final audioService = ref.watch(audioServiceProvider);
  final loggerService = ref.watch(loggerServiceProvider);
  
  return ScanNotifier(apiService, audioService, loggerService, ref);
});

