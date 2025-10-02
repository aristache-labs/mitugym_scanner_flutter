import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:logger/logger.dart';
import 'package:zxing2/qrcode.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

/// Windows-compatible QR Scanner Service
/// Uses camera package + ZXing for QR code detection
/// Optimized with isolate-based processing and configurable frame rate
class WindowsQRScannerService {
  CameraController? _controller;
  final Logger _logger = Logger();
  
  final StreamController<String> _qrCodeController = StreamController<String>.broadcast();
  Timer? _debounceTimer;
  Timer? _scanTimer;
  String? _lastScannedCode;
  DateTime? _lastScanTime;
  int _debounceDuration = 5; // seconds
  int _frameRate = 10; // frames per second
  bool _isScanning = false;
  bool _isProcessing = false; // Flag to prevent concurrent processing
  
  // Cache for recently decoded QR codes (prevents duplicate processing)
  final Map<String, DateTime> _qrCache = {};
  static const int _cacheDurationMs = 100;

  WindowsQRScannerService({int? debounceDuration, int? frameRate}) {
    if (debounceDuration != null) {
      _debounceDuration = debounceDuration;
    }
    if (frameRate != null && frameRate >= 5 && frameRate <= 30) {
      _frameRate = frameRate;
    }
  }

  /// Stream of debounced QR codes
  Stream<String> get qrCodeStream => _qrCodeController.stream;

  /// Get camera controller for preview
  CameraController? get controller => _controller;

  /// Check if scanning is active
  bool get isScanning => _isScanning;

  /// Update debounce duration
  void setDebounceDuration(int seconds) {
    _debounceDuration = seconds;
    _logger.i('Debounce duration updated to $seconds seconds');
  }

  /// Update frame rate
  void setFrameRate(int fps) {
    if (fps >= 5 && fps <= 30) {
      _frameRate = fps;
      _logger.i('Frame rate updated to $fps fps');
      
      // Restart scanning if active to apply new frame rate
      if (_isScanning) {
        stopScanning();
        startScanning();
      }
    }
  }

  /// Initialize camera
  Future<void> initialize() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras found');
      }

      // Use first camera
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      _logger.i('Camera initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize camera: $e');
      rethrow;
    }
  }

  /// Start scanning for QR codes
  Future<void> startScanning() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      await initialize();
    }

    _isScanning = true;
    _logger.i('Started QR code scanning at $_frameRate fps');

    // Calculate interval based on frame rate
    final intervalMs = (1000 / _frameRate).round();
    
    // Start periodic image capture and processing
    _scanTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) async {
      if (_isScanning && 
          _controller != null && 
          _controller!.value.isInitialized &&
          !_isProcessing) { // Skip if still processing previous frame
        await _captureAndProcessFrame();
      }
    });
  }

  /// Stop scanning
  Future<void> stopScanning() async {
    _isScanning = false;
    _scanTimer?.cancel();
    _logger.i('Stopped QR code scanning');
  }

  /// Capture and process camera frame
  Future<void> _captureAndProcessFrame() async {
    if (_isProcessing) return; // Skip if already processing
    
    _isProcessing = true;
    
    try {
      final image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();
      
      // Process image using compute (isolate) to avoid blocking UI
      final qrCode = await compute(_decodeQRFromImage, bytes);
      
      if (qrCode != null && qrCode.isNotEmpty) {
        // Check cache to prevent duplicate processing
        if (_isCachedRecently(qrCode)) {
          _logger.d('QR code in cache, skipping: $qrCode');
        } else {
          _updateCache(qrCode);
          _processQRCode(qrCode);
        }
      }
    } catch (e) {
      // Silently ignore frame capture errors (camera might be busy)
      _logger.d('Frame capture error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Check if QR code was decoded recently
  bool _isCachedRecently(String code) {
    final cachedTime = _qrCache[code];
    if (cachedTime == null) return false;
    
    final now = DateTime.now();
    final diff = now.difference(cachedTime).inMilliseconds;
    
    if (diff > _cacheDurationMs) {
      _qrCache.remove(code); // Clean up old entry
      return false;
    }
    
    return true;
  }

  /// Update QR code cache
  void _updateCache(String code) {
    _qrCache[code] = DateTime.now();
    
    // Clean up old cache entries (keep max 10)
    if (_qrCache.length > 10) {
      final oldestKey = _qrCache.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _qrCache.remove(oldestKey);
    }
  }

  /// Static method to decode QR from image (runs in isolate)
  static String? _decodeQRFromImage(Uint8List bytes) {
    try {
      // Decode image
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      // Convert to grayscale for better QR detection
      final grayscale = img.grayscale(image);
      
      // Create luminance source
      final width = grayscale.width;
      final height = grayscale.height;
      final luminances = Uint8List(width * height);
      
      for (var y = 0; y < height; y++) {
        for (var x = 0; x < width; x++) {
          final pixel = grayscale.getPixel(x, y);
          luminances[y * width + x] = pixel.r.toInt();
        }
      }

      // Try to decode QR code
      final reader = QRCodeReader();
      final source = RGBLuminanceSource(width, height, luminances);
      final bitmap = BinaryBitmap(HybridBinarizer(source));
      
      try {
        final result = reader.decode(bitmap);
        return result.text.isNotEmpty ? result.text : null;
      } catch (e) {
        // No QR code found in this frame
        return null;
      }
    } catch (e) {
      // Image processing error
      return null;
    }
  }

  /// Process detected QR code with debouncing
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

  /// Reset debounce state
  void resetDebounce() {
    _lastScannedCode = null;
    _lastScanTime = null;
    _debounceTimer?.cancel();
    _logger.d('Debounce state reset');
  }

  /// Dispose resources
  Future<void> dispose() async {
    _isScanning = false;
    _isProcessing = false;
    _scanTimer?.cancel();
    _debounceTimer?.cancel();
    _qrCache.clear();
    await _controller?.dispose();
    await _qrCodeController.close();
    _logger.i('Windows QR Scanner Service disposed');
  }
}

/// RGB Luminance Source for ZXing
class RGBLuminanceSource extends LuminanceSource {
  final Int8List _luminances;

  RGBLuminanceSource(super.width, super.height, Uint8List luminances)
      : _luminances = Int8List.fromList(luminances);

  @override
  Int8List getRow(int y, Int8List? row) {
    final width = this.width;
    row ??= Int8List(width);
    final offset = y * width;
    for (var x = 0; x < width; x++) {
      row[x] = _luminances[offset + x];
    }
    return row;
  }

  @override
  Int8List getMatrix() => _luminances;
}

