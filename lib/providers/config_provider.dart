import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';

/// Config notifier to manage application configuration
class ConfigNotifier extends StateNotifier<AppConfig> {
  ConfigNotifier() : super(AppConfig.defaults()) {
    _loadConfig();
  }

  /// Load configuration from SharedPreferences
  Future<void> _loadConfig() async {
    final config = await AppConfig.loadFromPreferences();
    state = config;
  }

  /// Update API URL
  Future<void> updateApiUrl(String url) async {
    state = state.copyWith(apiUrl: url);
    await state.saveToPreferences();
  }

  /// Update API Key
  Future<void> updateApiKey(String key) async {
    state = state.copyWith(apiKey: key);
    await state.saveToPreferences();
  }

  /// Update camera index
  Future<void> updateCameraIndex(int index) async {
    state = state.copyWith(cameraIndex: index);
    await state.saveToPreferences();
  }

  /// Update debounce duration
  Future<void> updateDebounceDuration(int duration) async {
    state = state.copyWith(debounceDuration: duration);
    await state.saveToPreferences();
  }

  /// Update audio enabled state
  Future<void> updateAudioEnabled(bool enabled) async {
    state = state.copyWith(audioEnabled: enabled);
    await state.saveToPreferences();
  }

  /// Update entire configuration
  Future<void> updateConfig(AppConfig config) async {
    state = config;
    await state.saveToPreferences();
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    state = AppConfig.defaults();
    await state.saveToPreferences();
  }
}

/// Provider for application configuration
final configProvider = StateNotifierProvider<ConfigNotifier, AppConfig>((ref) {
  return ConfigNotifier();
});

