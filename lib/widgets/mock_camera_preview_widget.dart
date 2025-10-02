import 'package:flutter/material.dart';
import '../services/mock_qr_scanner_service.dart';

/// Mock camera preview widget for Windows testing
/// Shows a QR code input field instead of camera
class MockCameraPreviewWidget extends StatefulWidget {
  final MockQRScannerService? scannerService;
  final bool isScanning;
  final String statusMessage;

  const MockCameraPreviewWidget({
    super.key,
    required this.scannerService,
    required this.isScanning,
    required this.statusMessage,
  });

  @override
  State<MockCameraPreviewWidget> createState() => _MockCameraPreviewWidgetState();
}

class _MockCameraPreviewWidgetState extends State<MockCameraPreviewWidget> {
  final TextEditingController _qrController = TextEditingController();

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }

  void _simulateScan() {
    final qrCode = _qrController.text.trim();
    if (qrCode.isNotEmpty && widget.scannerService != null) {
      widget.scannerService!.simulateScan(qrCode);
      _qrController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.scannerService == null) {
      return _buildPlaceholder('Initializing mock scanner...');
    }

    if (!widget.isScanning) {
      return _buildPlaceholder('Scanner stopped\nPress START to begin');
    }

    return Container(
      color: const Color(0xFF1a1a1a),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mock camera icon
          const Icon(
            Icons.qr_code_scanner,
            size: 120,
            color: Color(0xFF1e9b71),
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            'Mock QR Scanner',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Info text
          const Text(
            'Windows camera not available\nEnter QR code manually for testing',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),

          // QR Code input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: TextField(
              controller: _qrController,
              decoration: InputDecoration(
                labelText: 'QR Code',
                hintText: 'member_id:totp_code',
                prefixIcon: const Icon(Icons.qr_code_2),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _simulateScan,
                  tooltip: 'Simulate Scan',
                ),
                filled: true,
                fillColor: const Color(0xFF2d2d2d),
              ),
              onSubmitted: (_) => _simulateScan(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Quick test buttons
          Wrap(
            spacing: 12,
            children: [
              ElevatedButton(
                onPressed: () {
                  _qrController.text = 'test_member_123:456789';
                  _simulateScan();
                },
                child: const Text('Test Valid'),
              ),
              ElevatedButton(
                onPressed: () {
                  _qrController.text = 'invalid_qr_code';
                  _simulateScan();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text('Test Invalid'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Status message
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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

