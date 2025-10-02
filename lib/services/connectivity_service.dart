import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

/// Connectivity service for monitoring online/offline status
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final Logger _logger = Logger();
  
  StreamController<bool>? _connectionStatusController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  bool _isOnline = true;
  
  /// Get current online status
  bool get isOnline => _isOnline;
  
  /// Stream of connection status changes
  Stream<bool> get connectionStatus => _connectionStatusController!.stream;
  
  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    _connectionStatusController = StreamController<bool>.broadcast();
    
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);
    _logger.i('Initial connectivity status: ${_isOnline ? "Online" : "Offline"}');
    
    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasOnline = _isOnline;
        _isOnline = !results.contains(ConnectivityResult.none);
        
        if (wasOnline != _isOnline) {
          _logger.i('Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
          _connectionStatusController?.add(_isOnline);
        }
      },
      onError: (error) {
        _logger.e('Connectivity error: $error');
      },
    );
  }
  
  /// Check if device has internet connection
  Future<bool> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline = !result.contains(ConnectivityResult.none);
      return _isOnline;
    } catch (e) {
      _logger.e('Failed to check connection: $e');
      return false;
    }
  }
  
  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController?.close();
  }
}

