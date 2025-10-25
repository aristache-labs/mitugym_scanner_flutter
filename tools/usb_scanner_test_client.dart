import 'dart:io';
import 'dart:convert';

/// USB Scanner Test Client
/// Utility to simulate USB scanner input for testing
/// Sends SCAN commands to the USB scanner daemon's mock input port
void main(List<String> args) async {
  final host = args.contains('--host') 
      ? args[args.indexOf('--host') + 1] 
      : 'localhost';
  final port = args.contains('--port') 
      ? int.parse(args[args.indexOf('--port') + 1]) 
      : 9877; // Default mock input port

  if (args.contains('--help') || args.contains('-h') || args.isEmpty) {
    _printHelp();
    
    if (args.isEmpty) {
      print('\nERROR: QR code is required\n');
    }
    return;
  }

  // Get QR code from arguments
  final qrCode = args.where((arg) => !arg.startsWith('--')).join(' ');
  
  if (qrCode.isEmpty) {
    print('ERROR: No QR code provided');
    return;
  }

  await sendScan(host, port, qrCode);
}

/// Send a scan command to the daemon
Future<void> sendScan(String host, int port, String qrCode) async {
  Socket? socket;
  
  try {
    print('═══════════════════════════════════════════════════════════');
    print('USB Scanner Test Client');
    print('═══════════════════════════════════════════════════════════');
    print('Connecting to: $host:$port');
    print('QR Code: $qrCode');
    print('');

    // Connect to daemon
    socket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));
    print('[✓] Connected to daemon');

    // Send scan command
    final message = 'SCAN:$qrCode\n';
    socket.write(message);
    await socket.flush();
    print('[✓] Sent scan command');
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('Scan simulated successfully!');
    print('═══════════════════════════════════════════════════════════');

    // Wait a moment for transmission
    await Future.delayed(const Duration(milliseconds: 100));

    // Close connection
    await socket.close();
    print('[✓] Connection closed');
    
  } catch (e) {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('ERROR: Failed to send scan');
    print('═══════════════════════════════════════════════════════════');
    print('Error: $e');
    print('');
    print('Make sure the USB scanner daemon is running:');
    print('  dart run lib/services/usb_scanner_daemon.dart');
    print('═══════════════════════════════════════════════════════════');
    exit(1);
  } finally {
    await socket?.close();
  }
}

void _printHelp() {
  print('''
USB Scanner Test Client - Simulate USB scanner input

USAGE:
  dart run tools/usb_scanner_test_client.dart <QR_CODE> [OPTIONS]

ARGUMENTS:
  <QR_CODE>           The QR code or barcode data to simulate

OPTIONS:
  --help, -h          Show this help message
  --host <HOST>       Daemon host (default: localhost)
  --port <PORT>       Daemon mock input port (default: 9877)

EXAMPLES:
  # Simulate scanning a member QR code
  dart run tools/usb_scanner_test_client.dart MEMBER12345

  # Simulate with custom host/port
  dart run tools/usb_scanner_test_client.dart MEMBER12345 --host 192.168.1.100 --port 8889

  # Simulate multiple scans in sequence
  dart run tools/usb_scanner_test_client.dart MEMBER001
  timeout /t 6 /nobreak > nul
  dart run tools/usb_scanner_test_client.dart MEMBER002

NOTES:
  - The USB scanner daemon must be running in mock mode
  - Wait for the debounce period between scans (default: 5 seconds)
  - Use this tool to test your app without physical scanner hardware

QUICK START:
  1. Start the daemon:
     dart run lib/services/usb_scanner_daemon.dart

  2. Start your Flutter app with USB scanner mode enabled

  3. Send test scans:
     dart run tools/usb_scanner_test_client.dart TESTCODE123
''');
}
