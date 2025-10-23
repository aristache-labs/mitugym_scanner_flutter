import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/logger_service.dart';
import 'config_provider.dart';

/// Global singleton instance of LoggerService
final _globalLoggerService = LoggerService();

/// Provider for the logger service
/// Provides a singleton instance of LoggerService with verbose logging configured
final loggerServiceProvider = Provider<LoggerService>((ref) {
  // Watch config to update verbose logging when it changes
  final config = ref.watch(configProvider);
  _globalLoggerService.setVerboseLogging(config.verboseLogging);
  
  return _globalLoggerService;
});

/// Initialize the logger service (call this at app startup)
Future<void> initializeLoggerService() async {
  await _globalLoggerService.initialize();
}

