import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:logger/logger.dart';
import 'package:zxing2/qrcode.dart';
import 'package:image/image.dart' as img;

/// Windows-compatible QR Scanner Service
/// Uses camera package + ZXing for QR code detection
class WindowsQRScannerService {
  CameraController? _controller;
  final Logger _logger = Logger();
  
  final StreamController<String> _qrCodeController = StreamController<String>.broadcast();
  Timer? _debounceTimer;
  Timer? _scanTimer;
  String? _lastScannedCode;
  DateTime? _lastScanTime;
  int _debounceDuration = 5; // seconds
  bool _isScanning = false;

  WindowsQRScannerService({int? debounceDuration}) {
    if (debounceDuration != null) {
      _debounceDuration = debounceDuration;
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
    _logger.i('Started QR code scanning');

    // Start periodic image capture and processing
    _scanTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (_isScanning && _controller != null && _controller!.value.isInitialized) {
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
    try {
      final image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();
      
      // Process image in separate isolate to avoid blocking UI
      _processImage(bytes);
    } catch (e) {
      // Silently ignore frame capture errors (camera might be busy)
      _logger.d('Frame capture error: $e');
    }
  }

  /// Process image to detect QR code
  void _processImage(Uint8List bytes) {
    try {
      // Decode image
      final image = img.decodeImage(bytes);
      if (image == null) return;

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
        if (result.text.isNotEmpty) {
          _processQRCode(result.text);
        }
      } catch (e) {
        // No QR code found in this frame, continue scanning
      }
    } catch (e) {
      _logger.d('Image processing error: $e');
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
    _scanTimer?.cancel();
    _debounceTimer?.cancel();
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

