import 'package:shared_preferences/shared_preferences.dart';

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
  final bool autoStartScanning;
  final bool minimizeToTray;
  final bool cameraVisible;
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
    this.autoStartScanning = false,
    this.minimizeToTray = false,
    this.cameraVisible = true,
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
      autoStartScanning: false,
      minimizeToTray: false,
      cameraVisible: true,
      theme: 'cyan',
      cameraFrameRate: 10,
      verboseLogging: false,
      historyRetentionDays: 90,
      lastHistorySync: null,
    );
  }

  /// Load configuration from SharedPreferences
  static Future<AppConfig> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load last history sync timestamp
    final lastSyncMillis = prefs.getInt('last_history_sync');
    final lastHistorySync = lastSyncMillis != null 
        ? DateTime.fromMillisecondsSinceEpoch(lastSyncMillis)
        : null;
    
    return AppConfig(
      apiUrl: prefs.getString('apiUrl') ?? 'https://mitugym-app-webpanel.vercel.app',
      apiKey: prefs.getString('apiKey') ?? '847a6e2605d0674043fd8c6fef6e4f2ffb34fcfe8d5cd772636da8fc4b42bb78',
      cameraIndex: prefs.getInt('cameraIndex') ?? 0,
      debounceDuration: prefs.getInt('debounceDuration') ?? 5,
      audioEnabled: prefs.getBool('audioEnabled') ?? true,
      fontSize: prefs.getDouble('fontSize') ?? 14.0,
      animationSpeed: prefs.getDouble('animationSpeed') ?? 1.0,
      soundVolume: prefs.getDouble('soundVolume') ?? 1.0,
      logRetentionDays: prefs.getInt('logRetentionDays') ?? 30,
      exportFormat: prefs.getString('exportFormat') ?? 'csv',
      autoStartScanning: prefs.getBool('autoStartScanning') ?? false,
      minimizeToTray: prefs.getBool('minimizeToTray') ?? false,
      cameraVisible: prefs.getBool('cameraVisible') ?? true,
      theme: prefs.getString('theme') ?? 'cyan',
      cameraFrameRate: prefs.getInt('cameraFrameRate') ?? 10,
      verboseLogging: prefs.getBool('verboseLogging') ?? false,
      historyRetentionDays: prefs.getInt('history_retention_days') ?? 90,
      lastHistorySync: lastHistorySync,
    );
  }

  /// Save configuration to SharedPreferences
  Future<void> saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('apiUrl', apiUrl);
    await prefs.setString('apiKey', apiKey);
    await prefs.setInt('cameraIndex', cameraIndex);
    await prefs.setInt('debounceDuration', debounceDuration);
    await prefs.setBool('audioEnabled', audioEnabled);
    await prefs.setDouble('fontSize', fontSize);
    await prefs.setDouble('animationSpeed', animationSpeed);
    await prefs.setDouble('soundVolume', soundVolume);
    await prefs.setInt('logRetentionDays', logRetentionDays);
    await prefs.setString('exportFormat', exportFormat);
    await prefs.setBool('autoStartScanning', autoStartScanning);
    await prefs.setBool('minimizeToTray', minimizeToTray);
    await prefs.setBool('cameraVisible', cameraVisible);
    await prefs.setString('theme', theme);
    await prefs.setInt('cameraFrameRate', cameraFrameRate);
    await prefs.setBool('verboseLogging', verboseLogging);
    await prefs.setInt('history_retention_days', historyRetentionDays);
    if (lastHistorySync != null) {
      await prefs.setInt('last_history_sync', lastHistorySync!.millisecondsSinceEpoch);
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
    bool? autoStartScanning,
    bool? minimizeToTray,
    bool? cameraVisible,
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
      autoStartScanning: autoStartScanning ?? this.autoStartScanning,
      minimizeToTray: minimizeToTray ?? this.minimizeToTray,
      cameraVisible: cameraVisible ?? this.cameraVisible,
      theme: theme ?? this.theme,
      cameraFrameRate: cameraFrameRate ?? this.cameraFrameRate,
      verboseLogging: verboseLogging ?? this.verboseLogging,
      historyRetentionDays: historyRetentionDays ?? this.historyRetentionDays,
      lastHistorySync: lastHistorySync ?? this.lastHistorySync,
    );
  }
}

