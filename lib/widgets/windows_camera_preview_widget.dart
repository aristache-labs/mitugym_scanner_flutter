import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/windows_qr_scanner_service.dart';

/// Windows-compatible camera preview widget with QR scanner
class WindowsCameraPreviewWidget extends StatelessWidget {
  final WindowsQRScannerService? scannerService;
  final bool isScanning;
  final String statusMessage;

  const WindowsCameraPreviewWidget({
    super.key,
    required this.scannerService,
    required this.isScanning,
    required this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (scannerService == null || scannerService!.controller == null) {
      return _buildPlaceholder('Initializing camera...');
    }

    if (!scannerService!.controller!.value.isInitialized) {
      return _buildPlaceholder('Camera starting...');
    }

    if (!isScanning) {
      return _buildPlaceholder('Scanner stopped\nPress START to begin');
    }

    return Stack(
      children: [
        // Camera Preview
        Center(
          child: AspectRatio(
            aspectRatio: scannerService!.controller!.value.aspectRatio,
            child: CameraPreview(scannerService!.controller!),
          ),
        ),

        // Detection box overlay
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.green,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              painter: CornerPainter(),
            ),
          ),
        ),

        // Status text
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String message) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 80,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for corner decorations
class CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top-right corner
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom-left corner
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Bottom-right corner
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

