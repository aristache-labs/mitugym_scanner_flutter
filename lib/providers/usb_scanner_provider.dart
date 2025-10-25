import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/usb_scanner_service.dart';
import '../services/mock_usb_scanner_service.dart';
import 'config_provider.dart';
import 'scan_provider.dart';

/// USB Scanner Mode
enum UsbScannerMode {
  real,  // Use real USB scanner service (requires daemon)
  mock,  // Use mock USB scanner (for testing without hardware)
}

/// USB Scanner controller state
class UsbScannerControllerState {
  final dynamic service; // Can be UsbScannerService or MockUsbScannerService
  final bool isActive;
  final bool isConnected;
  final String? error;
  final String connectionStatus;
  final UsbScannerMode mode;

  const UsbScannerControllerState({
    this.service,
    this.isActive = false,
    this.isConnected = false,
    this.error,
    this.connectionStatus = 'Not connected',
    this.mode = UsbScannerMode.mock,
  });

  UsbScannerControllerState copyWith({
    dynamic service,
    bool? isActive,
    bool? isConnected,
    String? error,
    String? connectionStatus,
    UsbScannerMode? mode,
  }) {
    return UsbScannerControllerState(
      service: service ?? this.service,
      isActive: isActive ?? this.isActive,
      isConnected: isConnected ?? this.isConnected,
      error: error ?? this.error,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      mode: mode ?? this.mode,
    );
  }
}

/// USB Scanner controller notifier
class UsbScannerControllerNotifier extends Notifier<UsbScannerControllerState> {
  StreamSubscription<String>? _scanSubscription;

  @override
  UsbScannerControllerState build() {
    return const UsbScannerControllerState();
  }

  /// Initialize the USB scanner service
  Future<void> initialize({UsbScannerMode mode = UsbScannerMode.mock}) async {
    try {
      final config = ref.read(configProvider);
      
      dynamic service;
      
      if (mode == UsbScannerMode.real) {
        // Real USB scanner service (connects to daemon)
        service = UsbScannerService(
          debounceDuration: config.debounceDuration,
          daemonHost: 'localhost',
          daemonPort: 9876,
        );
      } else {
        // Mock USB scanner service (for testing without hardware)
        service = MockUsbScannerService(
          debounceDuration: config.debounceDuration,
        );
      }
      
      state = state.copyWith(
        service: service,
        mode: mode,
        error: null,
        connectionStatus: mode == UsbScannerMode.mock 
            ? 'Mock mode (No hardware required)'
            : 'Disconnected',
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize USB scanner: $e');
    }
  }

  /// Connect to the USB scanner
  Future<void> connect() async {
    if (state.service == null) {
      await initialize();
    }

    if (state.service == null) {
      return; // Failed to initialize
    }

    try {
      state = state.copyWith(
        connectionStatus: 'Connecting...',
        error: null,
      );

      final connected = await state.service.connect();
      
      if (connected) {
        state = state.copyWith(
          isConnected: true,
          connectionStatus: state.service.connectionStatus,
          error: null,
        );
      } else {
        state = state.copyWith(
          isConnected: false,
          connectionStatus: state.service.connectionStatus,
          error: 'Failed to connect to USB scanner daemon',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isConnected: false,
        error: 'Failed to connect: $e',
        connectionStatus: 'Connection failed',
      );
    }
  }

  /// Disconnect from the USB scanner
  Future<void> disconnect() async {
    if (state.service == null) return;

    try {
      await _scanSubscription?.cancel();
      await state.service.disconnect();
      
      state = state.copyWith(
        isConnected: false,
        isActive: false,
        connectionStatus: 'Disconnected',
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to disconnect: $e');
    }
  }

  /// Start the scanner
  Future<void> startScanner() async {
    if (state.service == null) {
      await initialize();
      await connect();
    }

    if (!state.isConnected && state.mode == UsbScannerMode.real) {
      await connect();
    }

    if (state.service == null) {
      return; // Failed to initialize
    }

    try {
      final started = await state.service.startScanning();
      
      if (started) {
        // Subscribe to scan stream
        _scanSubscription = state.service.scanStream.listen((code) {
          // Process the scan through scan provider
          ref.read(scanProvider.notifier).processScan(code);
        });

        // Update scan provider state
        ref.read(scanProvider.notifier).startScanning();
        
        state = state.copyWith(
          isActive: true,
          error: null,
          connectionStatus: state.service.connectionStatus,
        );
      } else {
        state = state.copyWith(
          isActive: false,
          error: 'Failed to start scanner',
        );
      }
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
      await _scanSubscription?.cancel();
      await state.service.stopScanning();
      
      // Update scan provider state
      ref.read(scanProvider.notifier).stopScanning();
      
      state = state.copyWith(
        isActive: false,
        error: null,
      );
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

  /// Simulate a scan (only works in mock mode)
  void simulateScan(String code) {
    if (state.mode == UsbScannerMode.mock && state.service != null) {
      (state.service as MockUsbScannerService).simulateScan(code);
    }
  }

  /// Switch scanner mode
  Future<void> switchMode(UsbScannerMode newMode) async {
    if (state.mode == newMode) return;

    // Stop current scanner
    if (state.isActive) {
      await stopScanner();
    }
    
    if (state.isConnected) {
      await disconnect();
    }

    // Dispose current service
    if (state.service != null) {
      await state.service.dispose();
    }

    // Initialize with new mode
    await initialize(mode: newMode);
  }
}

/// Provider for USB scanner controller
final usbScannerControllerProvider = 
    NotifierProvider<UsbScannerControllerNotifier, UsbScannerControllerState>(() {
  return UsbScannerControllerNotifier();
});
