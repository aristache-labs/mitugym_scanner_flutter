import 'dart:async';
import 'package:logger/logger.dart';

/// Mock USB Scanner Service
/// Simulates a USB scanner without requiring the daemon or hardware
/// Useful for UI testing and development
class MockUsbScannerService {
  final Logger _logger = Logger();
  
  final StreamController<String> _scanController = StreamController<String>.broadcast();
  String? _lastScannedCode;
  DateTime? _lastScanTime;
  int _debounceDuration = 5; // seconds
  bool _isActive = false;

  MockUsbScannerService({int? debounceDuration}) {
    if (debounceDuration != null) {
      _debounceDuration = debounceDuration;
    }
  }

  /// Stream of scanned codes
  Stream<String> get scanStream => _scanController.stream;

  /// Check if scanner is active
  bool get isActive => _isActive;

  /// Get connection status (always shows mock status)
  String get connectionStatus => 'Mock USB Scanner (No hardware required)';

  /// Update debounce duration
  void setDebounceDuration(int seconds) {
    _debounceDuration = seconds;
    _logger.i('Mock USB Scanner: Debounce duration updated to $seconds seconds');
  }

  /// Connect (mock - always succeeds)
  Future<bool> connect() async {
    _logger.i('Mock USB Scanner: Connected (simulated)');
    return true;
  }

  /// Disconnect (mock)
  Future<void> disconnect() async {
    _logger.i('Mock USB Scanner: Disconnected (simulated)');
  }

  /// Start scanning
  Future<bool> startScanning() async {
    _isActive = true;
    _logger.i('Mock USB Scanner: Started scanning (waiting for manual input)');
    return true;
  }

  /// Stop scanning
  Future<void> stopScanning() async {
    _isActive = false;
    _logger.i('Mock USB Scanner: Stopped scanning');
  }

  /// Simulate a scan (call this manually for testing)
  void simulateScan(String code) {
    if (!_isActive) {
      _logger.w('Mock USB Scanner: Scanner not active, ignoring simulated scan');
      return;
    }

    final now = DateTime.now();

    // Check debounce
    if (_lastScannedCode == code && _lastScanTime != null) {
      final timeSinceLastScan = now.difference(_lastScanTime!).inSeconds;
      
      if (timeSinceLastScan < _debounceDuration) {
        _logger.d('Mock USB Scanner: Code debounced: $code (${_debounceDuration - timeSinceLastScan}s remaining)');
        return;
      }
    }

    // New code or debounce period expired
    _logger.i('Mock USB Scanner: Code scanned: $code');
    _lastScannedCode = code;
    _lastScanTime = now;

    // Emit the code
    _scanController.add(code);
  }

  /// Reset debounce state
  void resetDebounce() {
    _lastScannedCode = null;
    _lastScanTime = null;
    _logger.d('Mock USB Scanner: Debounce state reset');
  }

  /// Dispose resources
  Future<void> dispose() async {
    _logger.i('Mock USB Scanner: Disposing service...');
    _isActive = false;
    await _scanController.close();
    _logger.i('Mock USB Scanner: Service disposed');
  }
}
