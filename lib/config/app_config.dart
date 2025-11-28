import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Application configuration class
/// Manages app settings with persistence via SharedPreferences
class AppConfig {
  final String apiUrl;
  final String apiKey;
  final int cameraIndex;
  final int debounceDuration; // in seconds
  final bool audioEnabled;
  
  // New settings
  final double fontSize;
  final double animationSpeed;
  final double soundVolume;
  final int logRetentionDays;
  final String exportFormat;
  final String exportPath;
  final bool autoStartScanning;
  final bool minimizeToTray;
  final bool cameraVisible;
  final bool startWithWindows;
  final String theme;
  final int cameraFrameRate;
  
  // Logging settings
  final bool verboseLogging;
  
  // History settings
  final int historyRetentionDays;
  final DateTime? lastHistorySync;

  const AppConfig({
    required this.apiUrl,
    required this.apiKey,
    this.cameraIndex = 0,
    this.debounceDuration = 5,
    this.audioEnabled = true,
    this.fontSize = 14.0,
    this.animationSpeed = 1.0,
    this.soundVolume = 1.0,
    this.logRetentionDays = 30,
    this.exportFormat = 'csv',
    this.exportPath = '',
    this.autoStartScanning = false,
    this.minimizeToTray = false,
    this.cameraVisible = true,
    this.startWithWindows = false,
    this.theme = 'cyan',
    this.cameraFrameRate = 10,
    this.verboseLogging = false,
    this.historyRetentionDays = 90,
    this.lastHistorySync,
  });

  /// Default configuration
  factory AppConfig.defaults() {
    return const AppConfig(
      apiUrl: 'https://mitugym-app-webpanel.vercel.app',
      apiKey: '847a6e2605d0674043fd8c6fef6e4f2ffb34fcfe8d5cd772636da8fc4b42bb78',
      cameraIndex: 0,
      debounceDuration: 5,
      audioEnabled: true,
      fontSize: 14.0,
      animationSpeed: 1.0,
      soundVolume: 1.0,
      logRetentionDays: 30,
      exportFormat: 'csv',
      exportPath: '',
      autoStartScanning: false,
      minimizeToTray: false,
      cameraVisible: true,
      startWithWindows: false,
      theme: 'cyan',
      cameraFrameRate: 10,
      verboseLogging: false,
      historyRetentionDays: 90,
      lastHistorySync: null,
    );
  }

  /// Get config file path
  static Future<String> _getConfigFilePath() async {
    try {
      debugPrint('🔍 [CONFIG] Getting application documents directory...');
      final appDir = await getApplicationDocumentsDirectory();
      debugPrint('✅ [CONFIG] App documents dir: ${appDir.path}');
      
      final configDir = path.join(appDir.path, 'MituGym Scanner');
      debugPrint('🔍 [CONFIG] Config directory will be: $configDir');
      
      // Ensure directory exists
      final dir = Directory(configDir);
      final exists = await dir.exists();
      debugPrint('🔍 [CONFIG] Config directory exists: $exists');
      
      if (!exists) {
        debugPrint('📁 [CONFIG] Creating config directory...');
        await dir.create(recursive: true);
        debugPrint('✅ [CONFIG] Created config directory: $configDir');
      }
      
      final filePath = path.join(configDir, 'config.json');
      debugPrint('✅ [CONFIG] Final config file path: $filePath');
      return filePath;
    } catch (e, stackTrace) {
      debugPrint('❌ [CONFIG] Error in _getConfigFilePath: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Load configuration from JSON file
  static Future<AppConfig> loadFromPreferences() async {
    try {
      debugPrint('📖 [CONFIG] Loading configuration...');
      final filePath = await _getConfigFilePath();
      final file = File(filePath);
      
      final fileExists = await file.exists();
      debugPrint('🔍 [CONFIG] Config file exists: $fileExists');
      
      if (!fileExists) {
        debugPrint('ℹ️ [CONFIG] Config file not found, using defaults');
        return AppConfig.defaults();
      }
      
      debugPrint('📖 [CONFIG] Reading config file...');
      final jsonString = await file.readAsString();
      debugPrint('✅ [CONFIG] File read successfully (${jsonString.length} bytes)');
      
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      debugPrint('✅ [CONFIG] JSON parsed successfully');
      
      // Load last history sync timestamp
      final lastSyncMillis = jsonData['last_history_sync'] as int?;
      final lastHistorySync = lastSyncMillis != null 
          ? DateTime.fromMillisecondsSinceEpoch(lastSyncMillis)
          : null;
      
      debugPrint('✅ [CONFIG] Configuration loaded successfully from: $filePath');
      
      return AppConfig(
        apiUrl: jsonData['apiUrl'] as String? ?? 'https://mitugym-app-webpanel.vercel.app',
        apiKey: jsonData['apiKey'] as String? ?? '847a6e2605d0674043fd8c6fef6e4f2ffb34fcfe8d5cd772636da8fc4b42bb78',
        cameraIndex: jsonData['cameraIndex'] as int? ?? 0,
        debounceDuration: jsonData['debounceDuration'] as int? ?? 5,
        audioEnabled: jsonData['audioEnabled'] as bool? ?? true,
        fontSize: (jsonData['fontSize'] as num?)?.toDouble() ?? 14.0,
        animationSpeed: (jsonData['animationSpeed'] as num?)?.toDouble() ?? 1.0,
        soundVolume: (jsonData['soundVolume'] as num?)?.toDouble() ?? 1.0,
        logRetentionDays: jsonData['logRetentionDays'] as int? ?? 30,
        exportFormat: jsonData['exportFormat'] as String? ?? 'csv',
        exportPath: jsonData['exportPath'] as String? ?? '',
        autoStartScanning: jsonData['autoStartScanning'] as bool? ?? false,
        minimizeToTray: jsonData['minimizeToTray'] as bool? ?? false,
        cameraVisible: jsonData['cameraVisible'] as bool? ?? true,
        startWithWindows: jsonData['startWithWindows'] as bool? ?? false,
        theme: jsonData['theme'] as String? ?? 'cyan',
        cameraFrameRate: jsonData['cameraFrameRate'] as int? ?? 10,
        verboseLogging: jsonData['verboseLogging'] as bool? ?? false,
        historyRetentionDays: jsonData['history_retention_days'] as int? ?? 90,
        lastHistorySync: lastHistorySync,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [CONFIG] Error loading config: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('ℹ️ [CONFIG] Using default configuration');
      return AppConfig.defaults();
    }
  }

  /// Save configuration to JSON file
  Future<void> saveToPreferences() async {
    try {
      final filePath = await _getConfigFilePath();
      final file = File(filePath);
      
      // Create JSON object with all settings
      final jsonData = {
        'apiUrl': apiUrl,
        'apiKey': apiKey,
        'cameraIndex': cameraIndex,
        'debounceDuration': debounceDuration,
        'audioEnabled': audioEnabled,
        'fontSize': fontSize,
        'animationSpeed': animationSpeed,
        'soundVolume': soundVolume,
        'logRetentionDays': logRetentionDays,
        'exportFormat': exportFormat,
        'exportPath': exportPath,
        'autoStartScanning': autoStartScanning,
        'minimizeToTray': minimizeToTray,
        'cameraVisible': cameraVisible,
        'startWithWindows': startWithWindows,
        'theme': theme,
        'cameraFrameRate': cameraFrameRate,
        'verboseLogging': verboseLogging,
        'history_retention_days': historyRetentionDays,
        if (lastHistorySync != null)
          'last_history_sync': lastHistorySync!.millisecondsSinceEpoch,
      };
      
      // Write JSON to file with pretty print
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      await file.writeAsString(jsonString);
      
      debugPrint('✅ Settings saved successfully to: $filePath');
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving settings: $e');
      debugPrint('Stack trace: $stackTrace');
      // Don't rethrow - we don't want to show error to user
    }
  }

  /// Create a copy with updated fields
  AppConfig copyWith({
    String? apiUrl,
    String? apiKey,
    int? cameraIndex,
    int? debounceDuration,
    bool? audioEnabled,
    double? fontSize,
    double? animationSpeed,
    double? soundVolume,
    int? logRetentionDays,
    String? exportFormat,
    String? exportPath,
    bool? autoStartScanning,
    bool? minimizeToTray,
    bool? cameraVisible,
    bool? startWithWindows,
    String? theme,
    int? cameraFrameRate,
    bool? verboseLogging,
    int? historyRetentionDays,
    DateTime? lastHistorySync,
  }) {
    return AppConfig(
      apiUrl: apiUrl ?? this.apiUrl,
      apiKey: apiKey ?? this.apiKey,
      cameraIndex: cameraIndex ?? this.cameraIndex,
      debounceDuration: debounceDuration ?? this.debounceDuration,
      audioEnabled: audioEnabled ?? this.audioEnabled,
      fontSize: fontSize ?? this.fontSize,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      soundVolume: soundVolume ?? this.soundVolume,
      logRetentionDays: logRetentionDays ?? this.logRetentionDays,
      exportFormat: exportFormat ?? this.exportFormat,
      exportPath: exportPath ?? this.exportPath,
      autoStartScanning: autoStartScanning ?? this.autoStartScanning,
      minimizeToTray: minimizeToTray ?? this.minimizeToTray,
      cameraVisible: cameraVisible ?? this.cameraVisible,
      startWithWindows: startWithWindows ?? this.startWithWindows,
      theme: theme ?? this.theme,
      cameraFrameRate: cameraFrameRate ?? this.cameraFrameRate,
      verboseLogging: verboseLogging ?? this.verboseLogging,
      historyRetentionDays: historyRetentionDays ?? this.historyRetentionDays,
      lastHistorySync: lastHistorySync ?? this.lastHistorySync,
    );
  }
}

