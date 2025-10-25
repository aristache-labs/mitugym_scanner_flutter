import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';

/// USB Scanner Service
/// Connects to a local daemon that listens for USB scanner input
/// This service communicates with the daemon via named pipe (Windows) or Unix socket
class UsbScannerService {
  final Logger _logger = Logger();
  
  final StreamController<String> _scanController = StreamController<String>.broadcast();
  Socket? _socket;
  String? _lastScannedCode;
  DateTime? _lastScanTime;
  int _debounceDuration = 5; // seconds
  bool _isActive = false;
  bool _isConnecting = false;
  
  // Daemon connection settings
  final String _daemonHost;
  final int _daemonPort;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  UsbScannerService({
    int? debounceDuration,
    String daemonHost = 'localhost',
    int daemonPort = 9876,
  })  : _daemonHost = daemonHost,
        _daemonPort = daemonPort {
    if (debounceDuration != null) {
      _debounceDuration = debounceDuration;
    }
  }

  /// Stream of scanned codes
  Stream<String> get scanStream => _scanController.stream;

  /// Check if scanner is active and connected
  bool get isActive => _isActive && _socket != null;

  /// Check if currently attempting to connect
  bool get isConnecting => _isConnecting;

  /// Get connection status
  String get connectionStatus {
    if (_socket != null && _isActive) {
      return 'Connected to USB scanner daemon';
    } else if (_isConnecting) {
      return 'Connecting to daemon... (Attempt $_reconnectAttempts/$_maxReconnectAttempts)';
    } else if (_reconnectAttempts >= _maxReconnectAttempts) {
      return 'Connection failed - daemon not available';
    } else {
      return 'Disconnected';
    }
  }

  /// Update debounce duration
  void setDebounceDuration(int seconds) {
    _debounceDuration = seconds;
    _logger.i('USB Scanner: Debounce duration updated to $seconds seconds');
  }

  /// Connect to the USB scanner daemon
  Future<bool> connect() async {
    if (_socket != null) {
      _logger.w('USB Scanner: Already connected');
      return true;
    }

    if (_isConnecting) {
      _logger.w('USB Scanner: Connection already in progress');
      return false;
    }

    _isConnecting = true;
    _reconnectAttempts++;

    try {
      _logger.i('USB Scanner: Connecting to daemon at $_daemonHost:$_daemonPort (Attempt $_reconnectAttempts)...');
      
      _socket = await Socket.connect(
        _daemonHost,
        _daemonPort,
        timeout: const Duration(seconds: 5),
      );

      _logger.i('USB Scanner: Connected to daemon successfully');
      _reconnectAttempts = 0;
      _isConnecting = false;

      // Listen for incoming data
      _socket!.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      // Start heartbeat
      _startHeartbeat();

      // Send initial handshake
      _sendCommand('HELLO');

      return true;
    } catch (e) {
      _logger.e('USB Scanner: Failed to connect to daemon: $e');
      _isConnecting = false;
      _socket = null;

      // Schedule reconnection if we haven't exceeded max attempts
      if (_reconnectAttempts < _maxReconnectAttempts) {
        _scheduleReconnect();
      } else {
        _logger.e('USB Scanner: Max reconnection attempts reached');
      }

      return false;
    }
  }

  /// Disconnect from the daemon
  Future<void> disconnect() async {
    _logger.i('USB Scanner: Disconnecting from daemon...');
    
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    
    if (_socket != null) {
      try {
        _sendCommand('BYE');
        await _socket!.flush();
        await _socket!.close();
      } catch (e) {
        _logger.w('USB Scanner: Error during disconnect: $e');
      }
      _socket = null;
    }
    
    _isActive = false;
    _isConnecting = false;
    _reconnectAttempts = 0;
    _logger.i('USB Scanner: Disconnected');
  }

  /// Start scanning (must be connected first)
  Future<bool> startScanning() async {
    if (_socket == null && !await connect()) {
      _logger.e('USB Scanner: Cannot start scanning - not connected');
      return false;
    }

    _isActive = true;
    _sendCommand('START_SCAN');
    _logger.i('USB Scanner: Started scanning');
    return true;
  }

  /// Stop scanning
  Future<void> stopScanning() async {
    _isActive = false;
    
    if (_socket != null) {
      _sendCommand('STOP_SCAN');
    }
    
    _logger.i('USB Scanner: Stopped scanning');
  }

  /// Reset debounce state
  void resetDebounce() {
    _lastScannedCode = null;
    _lastScanTime = null;
    _logger.d('USB Scanner: Debounce state reset');
  }

  /// Handle incoming data from daemon
  void _onData(List<int> data) {
    try {
      final message = utf8.decode(data).trim();
      _logger.d('USB Scanner: Received from daemon: $message');

      // Parse command
      final parts = message.split(':');
      if (parts.isEmpty) return;

      final command = parts[0];
      final payload = parts.length > 1 ? parts.sublist(1).join(':') : '';

      switch (command) {
        case 'SCAN':
          if (payload.isNotEmpty) {
            _handleScan(payload);
          }
          break;
        case 'PONG':
          _logger.d('USB Scanner: Heartbeat acknowledged');
          break;
        case 'ERROR':
          _logger.e('USB Scanner: Daemon error: $payload');
          break;
        case 'OK':
          _logger.d('USB Scanner: Command acknowledged');
          break;
        default:
          _logger.w('USB Scanner: Unknown command: $command');
      }
    } catch (e) {
      _logger.e('USB Scanner: Error processing data: $e');
    }
  }

  /// Handle scan data
  void _handleScan(String code) {
    if (!_isActive) {
      _logger.d('USB Scanner: Scan ignored - scanner not active');
      return;
    }

    final now = DateTime.now();

    // Check debounce
    if (_lastScannedCode == code && _lastScanTime != null) {
      final timeSinceLastScan = now.difference(_lastScanTime!).inSeconds;
      
      if (timeSinceLastScan < _debounceDuration) {
        _logger.d('USB Scanner: Code debounced: $code (${_debounceDuration - timeSinceLastScan}s remaining)');
        return;
      }
    }

    // New code or debounce period expired
    _logger.i('USB Scanner: Code scanned: $code');
    _lastScannedCode = code;
    _lastScanTime = now;

    // Emit the code
    _scanController.add(code);
  }

  /// Handle socket error
  void _onError(dynamic error) {
    _logger.e('USB Scanner: Socket error: $error');
    _socket = null;
    _scheduleReconnect();
  }

  /// Handle socket closure
  void _onDone() {
    _logger.w('USB Scanner: Socket closed by daemon');
    _socket = null;
    _heartbeatTimer?.cancel();
    
    if (_isActive) {
      _scheduleReconnect();
    }
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (_reconnectTimer != null && _reconnectTimer!.isActive) {
      return; // Already scheduled
    }

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _logger.e('USB Scanner: Max reconnection attempts reached - giving up');
      _isActive = false;
      return;
    }

    _logger.i('USB Scanner: Scheduling reconnection in ${_reconnectDelay.inSeconds}s...');
    _reconnectTimer = Timer(_reconnectDelay, () async {
      if (_isActive) {
        await connect();
      }
    });
  }

  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_socket != null) {
        _sendCommand('PING');
      }
    });
  }

  /// Send command to daemon
  void _sendCommand(String command) {
    if (_socket == null) {
      _logger.w('USB Scanner: Cannot send command - not connected');
      return;
    }

    try {
      _socket!.write('$command\n');
      _logger.d('USB Scanner: Sent command: $command');
    } catch (e) {
      _logger.e('USB Scanner: Failed to send command: $e');
      _onError(e);
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    _logger.i('USB Scanner: Disposing service...');
    
    await stopScanning();
    await disconnect();
    
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    
    await _scanController.close();
    _logger.i('USB Scanner: Service disposed');
  }
}
