import 'package:shared_preferences/shared_preferences.dart';

/// Application configuration class
/// Manages app settings with persistence via SharedPreferences
class AppConfig {
  final String apiUrl;
  final String apiKey;
  final int cameraIndex;
  final int debounceDuration; // in seconds
  final bool audioEnabled;

  const AppConfig({
    required this.apiUrl,
    required this.apiKey,
    this.cameraIndex = 0,
    this.debounceDuration = 5,
    this.audioEnabled = true,
  });

  /// Default configuration
  factory AppConfig.defaults() {
    return const AppConfig(
      apiUrl: 'https://mitugym-app-webpanel.vercel.app',
      apiKey: '847a6e2605d0674043fd8c6fef6e4f2ffb34fcfe8d5cd772636da8fc4b42bb78',
      cameraIndex: 0,
      debounceDuration: 5,
      audioEnabled: true,
    );
  }

  /// Load configuration from SharedPreferences
  static Future<AppConfig> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    return AppConfig(
      apiUrl: prefs.getString('apiUrl') ?? 'https://mitugym-app-webpanel.vercel.app',
      apiKey: prefs.getString('apiKey') ?? '847a6e2605d0674043fd8c6fef6e4f2ffb34fcfe8d5cd772636da8fc4b42bb78',
      cameraIndex: prefs.getInt('cameraIndex') ?? 0,
      debounceDuration: prefs.getInt('debounceDuration') ?? 5,
      audioEnabled: prefs.getBool('audioEnabled') ?? true,
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
  }

  /// Create a copy with updated fields
  AppConfig copyWith({
    String? apiUrl,
    String? apiKey,
    int? cameraIndex,
    int? debounceDuration,
    bool? audioEnabled,
  }) {
    return AppConfig(
      apiUrl: apiUrl ?? this.apiUrl,
      apiKey: apiKey ?? this.apiKey,
      cameraIndex: cameraIndex ?? this.cameraIndex,
      debounceDuration: debounceDuration ?? this.debounceDuration,
      audioEnabled: audioEnabled ?? this.audioEnabled,
    );
  }
}

