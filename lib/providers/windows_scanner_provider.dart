import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/windows_qr_scanner_service.dart';
import 'config_provider.dart';
import 'scan_provider.dart';

/// Windows Scanner controller state
class WindowsScannerControllerState {
  final WindowsQRScannerService? service;
  final bool isActive;
  final String? error;

  const WindowsScannerControllerState({
    this.service,
    this.isActive = false,
    this.error,
  });

  WindowsScannerControllerState copyWith({
    WindowsQRScannerService? service,
    bool? isActive,
    String? error,
  }) {
    return WindowsScannerControllerState(
      service: service ?? this.service,
      isActive: isActive ?? this.isActive,
      error: error ?? this.error,
    );
  }
}

/// Windows Scanner controller notifier
class WindowsScannerControllerNotifier extends Notifier<WindowsScannerControllerState> {
  StreamSubscription<String>? _qrSubscription;

  @override
  WindowsScannerControllerState build() {
    return const WindowsScannerControllerState();
  }

  /// Initialize the scanner service
  Future<void> initialize() async {
    try {
      final config = ref.read(configProvider);
      final service = WindowsQRScannerService(debounceDuration: config.debounceDuration);
      
      // Initialize camera
      await service.initialize();
      
      state = state.copyWith(service: service, error: null);
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize camera: $e');
    }
  }

  /// Start the scanner
  Future<void> startScanner() async {
    if (state.service == null) {
      await initialize();
    }

    if (state.service == null) {
      return; // Failed to initialize
    }

    try {
      await state.service!.startScanning();
      
      // Subscribe to QR code stream
      _qrSubscription = state.service!.qrCodeStream.listen((qrCode) {
        // Process the scan through scan provider
        ref.read(scanProvider.notifier).processScan(qrCode);
      });

      // Update scan provider state
      ref.read(scanProvider.notifier).startScanning();
      
      state = state.copyWith(isActive: true, error: null);
    } catch (e) {
      state = state.copyWith(
        isActive: false,
        error: 'Failed to start scanner: $e',
      );
    }
  }

  /// Stop the scanner
  Future<void> stopScanner() async {
    if (state.service == null) return;

    try {
      await _qrSubscription?.cancel();
      await state.service!.stopScanning();
      
      // Update scan provider state
      ref.read(scanProvider.notifier).stopScanning();
      
      state = state.copyWith(isActive: false, error: null);
    } catch (e) {
      state = state.copyWith(error: 'Failed to stop scanner: $e');
    }
  }

  /// Update debounce duration
  void updateDebounceDuration(int seconds) {
    state.service?.setDebounceDuration(seconds);
  }

  /// Reset debounce state
  void resetDebounce() {
    state.service?.resetDebounce();
  }

}

/// Provider for Windows scanner controller
final windowsScannerControllerProvider = 
    NotifierProvider<WindowsScannerControllerNotifier, WindowsScannerControllerState>(() {
  return WindowsScannerControllerNotifier();
});

