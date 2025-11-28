import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import '../config/app_config.dart';

/// Config notifier to manage application configuration
class ConfigNotifier extends Notifier<AppConfig> {
  @override
  AppConfig build() {
    _loadConfig();
    return AppConfig.defaults();
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

  /// Update history retention days
  Future<void> updateHistoryRetentionDays(int days) async {
    state = state.copyWith(historyRetentionDays: days);
    await state.saveToPreferences();
  }

  /// Update last history sync timestamp
  Future<void> updateLastHistorySync(DateTime timestamp) async {
    state = state.copyWith(lastHistorySync: timestamp);
    await state.saveToPreferences();
  }

  /// Update font size
  Future<void> updateFontSize(double size) async {
    state = state.copyWith(fontSize: size);
    await state.saveToPreferences();
  }

  /// Update animation speed
  Future<void> updateAnimationSpeed(double speed) async {
    state = state.copyWith(animationSpeed: speed);
    await state.saveToPreferences();
  }

  /// Update camera visible state
  Future<void> updateCameraVisible(bool visible) async {
    state = state.copyWith(cameraVisible: visible);
    await state.saveToPreferences();
  }

  /// Update auto start scanning state
  Future<void> updateAutoStartScanning(bool autoStart) async {
    state = state.copyWith(autoStartScanning: autoStart);
    await state.saveToPreferences();
  }

  /// Update start with Windows setting
  Future<void> updateStartWithWindows(bool startWithWindows) async {
    state = state.copyWith(startWithWindows: startWithWindows);
    await state.saveToPreferences();
    
    // Enable or disable launch at startup
    // Wrap in try-catch because registry keys might not exist on clean Windows installations
    try {
      if (startWithWindows) {
        await launchAtStartup.enable();
      } else {
        await launchAtStartup.disable();
      }
    } catch (e) {
      debugPrint('⚠️ Failed to update launch at startup setting: $e');
      debugPrint('ℹ️ This is normal on clean Windows installations. Setting saved to config.');
      // Don't rethrow - the setting is saved in config.json, just the registry update failed
    }
  }

  /// Update sound volume
  Future<void> updateSoundVolume(double volume) async {
    state = state.copyWith(soundVolume: volume);
    await state.saveToPreferences();
  }

  /// Update camera frame rate
  Future<void> updateCameraFrameRate(int frameRate) async {
    state = state.copyWith(cameraFrameRate: frameRate);
    await state.saveToPreferences();
  }

  /// Update log retention days
  Future<void> updateLogRetentionDays(int days) async {
    state = state.copyWith(logRetentionDays: days);
    await state.saveToPreferences();
  }

  /// Update export format
  Future<void> updateExportFormat(String format) async {
    state = state.copyWith(exportFormat: format);
    await state.saveToPreferences();
  }

  /// Update export path
  Future<void> updateExportPath(String path) async {
    state = state.copyWith(exportPath: path);
    await state.saveToPreferences();
  }

  /// Update verbose logging
  Future<void> updateVerboseLogging(bool enabled) async {
    state = state.copyWith(verboseLogging: enabled);
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
final configProvider = NotifierProvider<ConfigNotifier, AppConfig>(() {
  return ConfigNotifier();
});

