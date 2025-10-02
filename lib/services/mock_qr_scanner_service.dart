import 'dart:async';
import 'package:logger/logger.dart';

/// Mock QR Scanner Service for Windows testing
/// This simulates QR code scanning without camera access
class MockQRScannerService {
  final Logger _logger = Logger();
  
  final StreamController<String> _qrCodeController = StreamController<String>.broadcast();
  Timer? _debounceTimer;
  String? _lastScannedCode;
  DateTime? _lastScanTime;
  int _debounceDuration = 5; // seconds
  bool _isActive = false;

  MockQRScannerService({int? debounceDuration}) {
    if (debounceDuration != null) {
      _debounceDuration = debounceDuration;
    }
  }

  /// Stream of debounced QR codes
  Stream<String> get qrCodeStream => _qrCodeController.stream;

  /// Check if scanner is active
  bool get isActive => _isActive;

  /// Update debounce duration
  void setDebounceDuration(int seconds) {
    _debounceDuration = seconds;
    _logger.i('Debounce duration updated to $seconds seconds');
  }

  /// Simulate QR code scan (call this manually for testing)
  void simulateScan(String qrCode) {
    if (!_isActive) {
      _logger.w('Scanner not active, ignoring simulated scan');
      return;
    }
    _processQRCode(qrCode);
  }

  /// Process QR code with debouncing
  void _processQRCode(String code) {
    final now = DateTime.now();
    
    // Check if this is the same code and within debounce period
    if (_lastScannedCode == code && _lastScanTime != null) {
      final timeSinceLastScan = now.difference(_lastScanTime!).inSeconds;
      
      if (timeSinceLastScan < _debounceDuration) {
        _logger.d('Code debounced: $code (${_debounceDuration - timeSinceLastScan}s remaining)');
        return;
      }
    }

    // New code or debounce period expired
    _logger.i('QR Code detected: $code');
    _lastScannedCode = code;
    _lastScanTime = now;
    
    // Emit the code
    _qrCodeController.add(code);
  }

  /// Start scanning
  Future<void> startScanning() async {
    _isActive = true;
    _logger.i('Mock scanner started (waiting for manual input)');
  }

  /// Stop scanning
  Future<void> stopScanning() async {
    _isActive = false;
    _logger.i('Mock scanner stopped');
  }

  /// Reset debounce state
  void resetDebounce() {
    _lastScannedCode = null;
    _lastScanTime = null;
    _debounceTimer?.cancel();
    _logger.d('Debounce state reset');
  }

  /// Dispose resources
  void dispose() {
    _debounceTimer?.cancel();
    _qrCodeController.close();
    _logger.i('Mock QR Scanner Service disposed');
  }
}

