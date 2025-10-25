/// USB Scanner Integration Example
/// 
/// This file demonstrates how to integrate the USB scanner system
/// into your existing application.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lib/providers/usb_scanner_provider.dart';
import '../lib/providers/scan_provider.dart';

/// Example 1: Simple USB Scanner Screen
/// Shows basic integration with start/stop controls
class SimpleUsbScannerScreen extends ConsumerWidget {
  const SimpleUsbScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usbScanner = ref.watch(usbScannerControllerProvider);
    final scanState = ref.watch(scanProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('USB Scanner')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scanner Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Connection: ${usbScanner.connectionStatus}'),
                    Text('Mode: ${usbScanner.mode.name.toUpperCase()}'),
                    Text('Scanning: ${usbScanner.isActive ? "Active" : "Inactive"}'),
                    if (usbScanner.error != null)
                      Text(
                        'Error: ${usbScanner.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Control Buttons
            ElevatedButton.icon(
              onPressed: usbScanner.isActive ? null : () async {
                await ref.read(usbScannerControllerProvider.notifier).initialize(
                  mode: UsbScannerMode.mock, // Change to .real when you have hardware
                );
                await ref.read(usbScannerControllerProvider.notifier).connect();
                await ref.read(usbScannerControllerProvider.notifier).startScanner();
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Scanner'),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: !usbScanner.isActive ? null : () async {
                await ref.read(usbScannerControllerProvider.notifier).stopScanner();
              },
              icon: const Icon(Icons.stop),
              label: const Text('Stop Scanner'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Last Scan Result
            if (scanState.lastResult != null)
              Card(
                color: scanState.lastResult!.success ? Colors.green[50] : Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Scan',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(scanState.lastResult!.message),
                      if (scanState.lastResult!.data != null)
                        Text('Member: ${scanState.lastResult!.data!.memberName}'),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Mock Test Button (only in mock mode)
            if (usbScanner.mode == UsbScannerMode.mock && usbScanner.isActive)
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(usbScannerControllerProvider.notifier)
                      .simulateScan('MOCK_TEST_${DateTime.now().millisecondsSinceEpoch}');
                },
                icon: const Icon(Icons.bug_report),
                label: const Text('Simulate Scan (Mock Mode)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Example 2: Advanced USB Scanner Screen
/// Shows mode switching and advanced controls
class AdvancedUsbScannerScreen extends ConsumerStatefulWidget {
  const AdvancedUsbScannerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdvancedUsbScannerScreen> createState() => _AdvancedUsbScannerScreenState();
}

class _AdvancedUsbScannerScreenState extends ConsumerState<AdvancedUsbScannerScreen> {
  UsbScannerMode _selectedMode = UsbScannerMode.mock;

  @override
  Widget build(BuildContext context) {
    final usbScanner = ref.watch(usbScannerControllerProvider);
    final scanState = ref.watch(scanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced USB Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scanner Mode',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<UsbScannerMode>(
                      segments: const [
                        ButtonSegment(
                          value: UsbScannerMode.mock,
                          label: Text('Mock'),
                          icon: Icon(Icons.science),
                        ),
                        ButtonSegment(
                          value: UsbScannerMode.real,
                          label: Text('Real USB'),
                          icon: Icon(Icons.usb),
                        ),
                      ],
                      selected: {_selectedMode},
                      onSelectionChanged: (Set<UsbScannerMode> selection) {
                        setState(() {
                          _selectedMode = selection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedMode == UsbScannerMode.mock
                          ? 'Mock mode - Test without hardware'
                          : 'Real mode - Connect to physical USB scanner',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusRow('Connection', usbScanner.connectionStatus),
                    _buildStatusRow('Mode', usbScanner.mode.name.toUpperCase()),
                    _buildStatusRow('Connected', usbScanner.isConnected ? 'Yes' : 'No'),
                    _buildStatusRow('Scanning', usbScanner.isActive ? 'Active' : 'Inactive'),
                    if (scanState.cooldownActive)
                      _buildStatusRow('Cooldown', '${scanState.cooldownRemaining}s'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Control Buttons
            _buildControlButton(
              'Initialize',
              Icons.power_settings_new,
              Colors.blue,
              enabled: usbScanner.service == null,
              onPressed: () async {
                await ref.read(usbScannerControllerProvider.notifier)
                    .initialize(mode: _selectedMode);
              },
            ),
            
            const SizedBox(height: 8),
            
            _buildControlButton(
              'Connect',
              Icons.link,
              Colors.green,
              enabled: usbScanner.service != null && !usbScanner.isConnected,
              onPressed: () async {
                await ref.read(usbScannerControllerProvider.notifier).connect();
              },
            ),
            
            const SizedBox(height: 8),
            
            _buildControlButton(
              'Start Scanning',
              Icons.play_arrow,
              Colors.teal,
              enabled: usbScanner.isConnected && !usbScanner.isActive,
              onPressed: () async {
                await ref.read(usbScannerControllerProvider.notifier).startScanner();
              },
            ),
            
            const SizedBox(height: 8),
            
            _buildControlButton(
              'Stop Scanning',
              Icons.stop,
              Colors.orange,
              enabled: usbScanner.isActive,
              onPressed: () async {
                await ref.read(usbScannerControllerProvider.notifier).stopScanner();
              },
            ),
            
            const SizedBox(height: 8),
            
            _buildControlButton(
              'Disconnect',
              Icons.link_off,
              Colors.red,
              enabled: usbScanner.isConnected,
              onPressed: () async {
                await ref.read(usbScannerControllerProvider.notifier).disconnect();
              },
            ),
            
            const SizedBox(height: 16),
            
            // Recent Activity
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (scanState.recentActivity.isEmpty)
                      const Text('No recent scans')
                    else
                      ...scanState.recentActivity.take(5).map((activity) {
                        return ListTile(
                          leading: Icon(
                            activity.success ? Icons.check_circle : Icons.error,
                            color: activity.success ? Colors.green : Colors.red,
                          ),
                          title: Text(activity.memberName),
                          subtitle: Text(activity.action),
                          trailing: Text(
                            '${activity.time.hour}:${activity.time.minute.toString().padLeft(2, '0')}',
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    String label,
    IconData icon,
    Color color, {
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scanner Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Configure scanner settings here'),
            // Add your settings UI here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Example 3: Integration into Existing Scanner Screen
/// Shows how to add USB scanner as an option alongside camera
class HybridScannerScreen extends ConsumerStatefulWidget {
  const HybridScannerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HybridScannerScreen> createState() => _HybridScannerScreenState();
}

class _HybridScannerScreenState extends ConsumerState<HybridScannerScreen> {
  bool _useUsbScanner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner'),
        actions: [
          // Toggle between camera and USB
          Switch(
            value: _useUsbScanner,
            onChanged: (value) async {
              setState(() => _useUsbScanner = value);
              
              if (value) {
                // Switch to USB scanner
                await ref.read(usbScannerControllerProvider.notifier).initialize(
                  mode: UsbScannerMode.mock,
                );
                await ref.read(usbScannerControllerProvider.notifier).startScanner();
              } else {
                // Switch back to camera
                await ref.read(usbScannerControllerProvider.notifier).stopScanner();
                // Initialize camera scanner here
              }
            },
          ),
          const SizedBox(width: 8),
          Text(_useUsbScanner ? 'USB' : 'Camera'),
          const SizedBox(width: 16),
        ],
      ),
      body: _useUsbScanner
          ? const SimpleUsbScannerScreen()
          : const Center(child: Text('Camera Scanner (Your existing implementation)')),
    );
  }
}
