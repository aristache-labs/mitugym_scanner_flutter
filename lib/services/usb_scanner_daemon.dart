import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// USB Scanner Daemon
/// Background service that listens for USB scanner input and forwards to clients
/// 
/// This daemon can work in two modes:
/// 1. Real USB mode: Listens for actual USB HID scanner input (requires hardware)
/// 2. Mock mode: Accepts simulated scan input via TCP socket for testing
/// 
/// Protocol:
/// - Client sends: START_SCAN, STOP_SCAN, PING, HELLO, BYE
/// - Daemon sends: SCAN:<code>, PONG, OK, ERROR:<message>
class UsbScannerDaemon {
  final int port;
  final bool mockMode;
  ServerSocket? _server;
  final List<Socket> _clients = [];
  bool _isRunning = false;
  
  // For real USB mode (to be implemented when hardware is available)
  RandomAccessFile? _hidDevice;
  Timer? _usbPollTimer;
  
  // Mock mode - accepts test input via separate port
  ServerSocket? _mockInputServer;
  final int _mockInputPort;
  
  UsbScannerDaemon({
    this.port = 9876,
    this.mockMode = true,
    int mockInputPort = 9877,
  }) : _mockInputPort = mockInputPort;

  /// Start the daemon
  Future<void> start() async {
    if (_isRunning) {
      print('Daemon already running');
      return;
    }

    try {
      // Start main server for client connections
      _server = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
      _isRunning = true;
      
      print('═══════════════════════════════════════════════════════════');
      print('USB Scanner Daemon Started');
      print('═══════════════════════════════════════════════════════════');
      print('Mode: ${mockMode ? "MOCK (Testing)" : "REAL USB"}');
      print('Listening on: localhost:$port');
      
      if (mockMode) {
        print('Mock input on: localhost:$_mockInputPort');
        print('');
        print('To simulate a scan, connect to port $_mockInputPort and send:');
        print('  SCAN:<your-qr-code-data>');
        print('');
        print('Example using PowerShell:');
        print('  \$client = New-Object System.Net.Sockets.TcpClient("localhost", $_mockInputPort)');
        print('  \$stream = \$client.GetStream()');
        print('  \$writer = New-Object System.IO.StreamWriter(\$stream)');
        print('  \$writer.WriteLine("SCAN:MEMBER12345")');
        print('  \$writer.Flush()');
        print('  \$client.Close()');
      }
      print('═══════════════════════════════════════════════════════════');
      print('');

      // Listen for client connections
      _server!.listen(_handleClient);

      // Start mock input server if in mock mode
      if (mockMode) {
        await _startMockInputServer();
      } else {
        // In real mode, start USB polling
        await _startUsbPolling();
      }

      print('[${_timestamp()}] Daemon ready and waiting for connections...');
    } catch (e) {
      print('[${_timestamp()}] ERROR: Failed to start daemon: $e');
      rethrow;
    }
  }

  /// Stop the daemon
  Future<void> stop() async {
    print('[${_timestamp()}] Shutting down daemon...');
    
    _isRunning = false;
    _usbPollTimer?.cancel();
    
    // Close all client connections
    for (final client in _clients) {
      try {
        client.write('BYE\n');
        await client.flush();
        await client.close();
      } catch (e) {
        // Ignore errors during shutdown
      }
    }
    _clients.clear();
    
    // Close servers
    await _server?.close();
    await _mockInputServer?.close();
    
    // Close USB device if open
    await _hidDevice?.close();
    
    print('[${_timestamp()}] Daemon stopped');
  }

  /// Handle new client connection
  void _handleClient(Socket client) {
    final clientAddr = '${client.remoteAddress.address}:${client.remotePort}';
    print('[${_timestamp()}] Client connected: $clientAddr');
    
    _clients.add(client);
    
    client.listen(
      (data) => _handleClientData(client, data),
      onError: (error) {
        print('[${_timestamp()}] Client error ($clientAddr): $error');
        _removeClient(client);
      },
      onDone: () {
        print('[${_timestamp()}] Client disconnected: $clientAddr');
        _removeClient(client);
      },
      cancelOnError: true,
    );

    // Send welcome message
    _sendToClient(client, 'OK:Connected to USB Scanner Daemon');
  }

  /// Handle data from client
  void _handleClientData(Socket client, List<int> data) {
    try {
      final message = utf8.decode(data).trim();
      if (message.isEmpty) return;

      final clientAddr = '${client.remoteAddress.address}:${client.remotePort}';
      print('[${_timestamp()}] Client command ($clientAddr): $message');

      final parts = message.split(':');
      final command = parts[0];

      switch (command) {
        case 'HELLO':
          _sendToClient(client, 'OK:Hello from daemon');
          break;
        case 'START_SCAN':
          _sendToClient(client, 'OK:Scanning started');
          break;
        case 'STOP_SCAN':
          _sendToClient(client, 'OK:Scanning stopped');
          break;
        case 'PING':
          _sendToClient(client, 'PONG');
          break;
        case 'BYE':
          _sendToClient(client, 'OK:Goodbye');
          _removeClient(client);
          break;
        default:
          _sendToClient(client, 'ERROR:Unknown command: $command');
      }
    } catch (e) {
      print('[${_timestamp()}] Error handling client data: $e');
      _sendToClient(client, 'ERROR:$e');
    }
  }

  /// Start mock input server for testing
  Future<void> _startMockInputServer() async {
    try {
      _mockInputServer = await ServerSocket.bind(
        InternetAddress.loopbackIPv4,
        _mockInputPort,
      );

      print('[${_timestamp()}] Mock input server started on port $_mockInputPort');

      _mockInputServer!.listen((socket) {
        print('[${_timestamp()}] Mock input connection received');
        
        socket.listen(
          (data) {
            final message = utf8.decode(data).trim();
            print('[${_timestamp()}] Mock input received: $message');
            
            // Forward to all connected clients
            _broadcastToClients(message);
          },
          onDone: () {
            socket.close();
          },
          onError: (error) {
            print('[${_timestamp()}] Mock input error: $error');
            socket.close();
          },
        );
      });
    } catch (e) {
      print('[${_timestamp()}] Failed to start mock input server: $e');
    }
  }

  /// Start USB device polling (for real USB scanner)
  Future<void> _startUsbPolling() async {
    print('[${_timestamp()}] USB polling not yet implemented - waiting for hardware');
    print('[${_timestamp()}] When you get the USB scanner, implement HID reading here');
    
    // TODO: Implement real USB HID scanning when hardware is available
    // Example structure:
    // 
    // 1. Detect USB HID device (scanner)
    //    - Use Win32 API or libusb bindings
    //    - Match vendor ID / product ID
    // 
    // 2. Open HID device for reading
    //    - _hidDevice = await File(devicePath).open()
    // 
    // 3. Poll for input in a timer
    //    _usbPollTimer = Timer.periodic(Duration(milliseconds: 100), (_) async {
    //      final data = await _hidDevice!.read(64);
    //      if (data.isNotEmpty) {
    //        final scanCode = _parseHidData(data);
    //        if (scanCode != null) {
    //          _broadcastToClients('SCAN:$scanCode');
    //        }
    //      }
    //    });
    //
    // 4. Parse HID data to extract barcode/QR data
    //    Most USB scanners send keyboard scancodes
    //    Map scancodes to characters, buffer until Enter key
  }

  /// Broadcast message to all connected clients
  void _broadcastToClients(String message) {
    print('[${_timestamp()}] Broadcasting to ${_clients.length} client(s): $message');
    
    for (final client in List<Socket>.from(_clients)) {
      _sendToClient(client, message);
    }
  }

  /// Send message to specific client
  void _sendToClient(Socket client, String message) {
    try {
      client.write('$message\n');
    } catch (e) {
      print('[${_timestamp()}] Failed to send to client: $e');
      _removeClient(client);
    }
  }

  /// Remove client from list
  void _removeClient(Socket client) {
    _clients.remove(client);
    try {
      client.close();
    } catch (e) {
      // Ignore errors during close
    }
  }

  /// Get timestamp string
  String _timestamp() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
           '${now.minute.toString().padLeft(2, '0')}:'
           '${now.second.toString().padLeft(2, '0')}';
  }
}

/// Main entry point for running daemon standalone
void main(List<String> args) async {
  final mockMode = !args.contains('--real');
  final port = _parseArg(args, '--port', 9876);
  final mockInputPort = _parseArg(args, '--mock-port', 9877);

  if (args.contains('--help') || args.contains('-h')) {
    _printHelp();
    return;
  }

  final daemon = UsbScannerDaemon(
    port: port,
    mockMode: mockMode,
    mockInputPort: mockInputPort,
  );

  // Handle Ctrl+C gracefully
  ProcessSignal.sigint.watch().listen((_) async {
    print('\n[SHUTDOWN] Received interrupt signal');
    await daemon.stop();
    exit(0);
  });

  try {
    await daemon.start();
    
    // Keep running
    await Future.delayed(const Duration(days: 365));
  } catch (e) {
    print('FATAL ERROR: $e');
    exit(1);
  }
}

int _parseArg(List<String> args, String flag, int defaultValue) {
  final index = args.indexOf(flag);
  if (index != -1 && index + 1 < args.length) {
    return int.tryParse(args[index + 1]) ?? defaultValue;
  }
  return defaultValue;
}

void _printHelp() {
  print('''
USB Scanner Daemon - Background service for USB barcode/QR scanners

USAGE:
  dart run lib/services/usb_scanner_daemon.dart [OPTIONS]

OPTIONS:
  --help, -h           Show this help message
  --real               Run in real USB mode (default: mock mode)
  --port <PORT>        Main server port (default: 9876)
  --mock-port <PORT>   Mock input port (default: 9877)

EXAMPLES:
  # Run in mock mode for testing (default)
  dart run lib/services/usb_scanner_daemon.dart

  # Run in real USB mode (when you have the scanner)
  dart run lib/services/usb_scanner_daemon.dart --real

  # Use custom ports
  dart run lib/services/usb_scanner_daemon.dart --port 8888 --mock-port 8889

MOCK MODE:
  In mock mode, the daemon accepts simulated scan input on the mock-port.
  Use the test utility script to send test scans without hardware.

REAL MODE:
  In real mode, the daemon will attempt to connect to a USB HID scanner.
  This requires the physical scanner to be connected.
''');
}
