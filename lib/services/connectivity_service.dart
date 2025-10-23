import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'logger_service.dart';

/// Connectivity service for monitoring online/offline status
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final Logger _logger = Logger();
  final LoggerService? _verboseLogger;
  
  StreamController<bool>? _connectionStatusController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  bool _isOnline = true;
  
  ConnectivityService({LoggerService? verboseLogger}) : _verboseLogger = verboseLogger {
    _verboseLogger?.logDebug('ConnectivityService created', source: 'ConnectivityService');
  }
  
  /// Get current online status
  bool get isOnline => _isOnline;
  
  /// Stream of connection status changes
  Stream<bool> get connectionStatus => _connectionStatusController!.stream;
  
  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    _verboseLogger?.logDebug('Initializing connectivity monitoring', source: 'ConnectivityService');
    _connectionStatusController = StreamController<bool>.broadcast();
    
    // Check initial connectivity
    _verboseLogger?.logDebug('Checking initial connectivity status', source: 'ConnectivityService');
    final result = await _connectivity.checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);
    _logger.i('Initial connectivity status: ${_isOnline ? "Online" : "Offline"}');
    _verboseLogger?.logDebug('Initial connectivity: ${_isOnline ? "Online" : "Offline"} (${result.join(", ")})', source: 'ConnectivityService');
    
    // Listen for connectivity changes
    _verboseLogger?.logDebug('Starting connectivity change listener', source: 'ConnectivityService');
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasOnline = _isOnline;
        _isOnline = !results.contains(ConnectivityResult.none);
        
        _verboseLogger?.logTrace('Connectivity check: ${results.join(", ")} -> ${_isOnline ? "Online" : "Offline"}', source: 'ConnectivityService');
        
        if (wasOnline != _isOnline) {
          _logger.i('Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
          _verboseLogger?.logDebug('Connectivity STATE CHANGED: ${wasOnline ? "Online" : "Offline"} -> ${_isOnline ? "Online" : "Offline"}', source: 'ConnectivityService');
          _connectionStatusController?.add(_isOnline);
        }
      },
      onError: (error) {
        _logger.e('Connectivity error: $error');
        _verboseLogger?.logDebug('Connectivity listener error: $error', source: 'ConnectivityService');
      },
    );
  }
  
  /// Check if device has internet connection
  Future<bool> checkConnection() async {
    try {
      _verboseLogger?.logTrace('Manually checking connection', source: 'ConnectivityService');
      final result = await _connectivity.checkConnectivity();
      _isOnline = !result.contains(ConnectivityResult.none);
      _verboseLogger?.logTrace('Connection check result: ${_isOnline ? "Online" : "Offline"}', source: 'ConnectivityService');
      return _isOnline;
    } catch (e) {
      _logger.e('Failed to check connection: $e');
      _verboseLogger?.logDebug('Connection check error: $e', source: 'ConnectivityService');
      return false;
    }
  }
  
  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController?.close();
  }
}

