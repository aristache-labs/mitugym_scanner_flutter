import 'dart:io';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// Logger Service
/// Handles logging to daily log files
/// Supports both standard logging and verbose logging modes
class LoggerService {
  final Logger _logger = Logger();
  String? _logDirectory;
  bool _verboseLoggingEnabled = false;

  /// Initialize the logger service
  Future<void> initialize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logDirectory = '${directory.path}/mitugym_logs';
      
      // Create logs directory if it doesn't exist
      final logDir = Directory(_logDirectory!);
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      
      _logger.i('Logger Service initialized. Log directory: $_logDirectory');
    } catch (e) {
      _logger.e('Failed to initialize logger service: $e');
    }
  }

  /// Enable or disable verbose logging
  void setVerboseLogging(bool enabled) {
    _verboseLoggingEnabled = enabled;
    _logger.i('Verbose logging ${enabled ? "enabled" : "disabled"}');
  }

  /// Check if verbose logging is enabled
  bool get isVerboseLoggingEnabled => _verboseLoggingEnabled;

  /// Get today's log file path
  String _getTodayLogFilePath() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return '$_logDirectory/mitugym_$today.log';
  }

  /// Write to log file
  Future<void> _writeToFile(String message) async {
    if (_logDirectory == null) {
      await initialize();
    }

    try {
      final logFile = File(_getTodayLogFilePath());
      final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final logEntry = '[$timestamp] $message\n';
      
      await logFile.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      _logger.e('Failed to write to log file: $e');
    }
  }

  /// Log a successful check-in/check-out
  Future<void> logSuccess(String memberName, String action) async {
    final message = 'SUCCESS - Member: $memberName, Action: $action';
    _logger.i(message);
    await _writeToFile(message);
  }

  /// Log an error
  Future<void> logError(String error, String details) async {
    final message = 'ERROR - $error | Details: $details';
    _logger.e(message);
    await _writeToFile(message);
  }

  /// Log general information
  Future<void> logInfo(String message) async {
    _logger.i(message);
    await _writeToFile('INFO - $message');
  }

  /// Log debug information (only when verbose logging is enabled)
  Future<void> logDebug(String message, {String? source}) async {
    final formattedMessage = source != null ? '[$source] $message' : message;
    _logger.d(formattedMessage);
    
    if (_verboseLoggingEnabled) {
      await _writeToFile('DEBUG - $formattedMessage');
    }
  }

  /// Log warning (only when verbose logging is enabled)
  Future<void> logWarning(String message, {String? source}) async {
    final formattedMessage = source != null ? '[$source] $message' : message;
    _logger.w(formattedMessage);
    
    if (_verboseLoggingEnabled) {
      await _writeToFile('WARNING - $formattedMessage');
    }
  }

  /// Log trace information (only when verbose logging is enabled)
  Future<void> logTrace(String message, {String? source}) async {
    final formattedMessage = source != null ? '[$source] $message' : message;
    _logger.t(formattedMessage);
    
    if (_verboseLoggingEnabled) {
      await _writeToFile('TRACE - $formattedMessage');
    }
  }

  /// Get log file for a specific date
  Future<String?> getLogFileContent(DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final logFile = File('$_logDirectory/mitugym_$dateStr.log');
      
      if (await logFile.exists()) {
        return await logFile.readAsString();
      }
      return null;
    } catch (e) {
      _logger.e('Failed to read log file: $e');
      return null;
    }
  }

  /// Get list of all log files
  Future<List<File>> getLogFiles() async {
    if (_logDirectory == null) {
      await initialize();
    }

    try {
      final logDir = Directory(_logDirectory!);
      final files = await logDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.log'))
          .cast<File>()
          .toList();
      
      return files;
    } catch (e) {
      _logger.e('Failed to get log files: $e');
      return [];
    }
  }

  /// Delete old log files (older than specified days)
  Future<void> cleanOldLogs({int daysToKeep = 30}) async {
    try {
      final files = await getLogFiles();
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      for (final file in files) {
        final stat = await file.stat();
        if (stat.modified.isBefore(cutoffDate)) {
          await file.delete();
          _logger.i('Deleted old log file: ${file.path}');
        }
      }
    } catch (e) {
      _logger.e('Failed to clean old logs: $e');
    }
  }
}

