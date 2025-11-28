import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Safe wrapper for SharedPreferences that handles errors gracefully
/// Falls back to default values if SharedPreferences fails (e.g., on clean VMs)
class SafePreferences {
  static SharedPreferences? _instance;
  static bool _initFailed = false;

  /// Get SharedPreferences instance, returns null if initialization fails
  static Future<SharedPreferences?> getInstance() async {
    if (_initFailed) {
      debugPrint('⚠️ SharedPreferences previously failed, skipping');
      return null;
    }

    if (_instance != null) {
      return _instance;
    }

    try {
      _instance = await SharedPreferences.getInstance();
      debugPrint('✅ SharedPreferences initialized successfully');
      return _instance;
    } catch (e) {
      debugPrint('❌ SharedPreferences failed to initialize: $e');
      debugPrint('ℹ️ Continuing without SharedPreferences (will use defaults)');
      _initFailed = true;
      return null;
    }
  }

  /// Safely get a string value
  static Future<String?> getString(String key) async {
    try {
      final prefs = await getInstance();
      return prefs?.getString(key);
    } catch (e) {
      debugPrint('⚠️ Failed to get string for key $key: $e');
      return null;
    }
  }

  /// Safely set a string value
  static Future<bool> setString(String key, String value) async {
    try {
      final prefs = await getInstance();
      if (prefs == null) return false;
      return await prefs.setString(key, value);
    } catch (e) {
      debugPrint('⚠️ Failed to set string for key $key: $e');
      return false;
    }
  }

  /// Safely get an int value
  static Future<int?> getInt(String key) async {
    try {
      final prefs = await getInstance();
      return prefs?.getInt(key);
    } catch (e) {
      debugPrint('⚠️ Failed to get int for key $key: $e');
      return null;
    }
  }

  /// Safely set an int value
  static Future<bool> setInt(String key, int value) async {
    try {
      final prefs = await getInstance();
      if (prefs == null) return false;
      return await prefs.setInt(key, value);
    } catch (e) {
      debugPrint('⚠️ Failed to set int for key $key: $e');
      return false;
    }
  }

  /// Safely get a bool value
  static Future<bool?> getBool(String key) async {
    try {
      final prefs = await getInstance();
      return prefs?.getBool(key);
    } catch (e) {
      debugPrint('⚠️ Failed to get bool for key $key: $e');
      return null;
    }
  }

  /// Safely set a bool value
  static Future<bool> setBool(String key, bool value) async {
    try {
      final prefs = await getInstance();
      if (prefs == null) return false;
      return await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('⚠️ Failed to set bool for key $key: $e');
      return false;
    }
  }

  /// Safely remove a value
  static Future<bool> remove(String key) async {
    try {
      final prefs = await getInstance();
      if (prefs == null) return false;
      return await prefs.remove(key);
    } catch (e) {
      debugPrint('⚠️ Failed to remove key $key: $e');
      return false;
    }
  }

  /// Reset the initialization state (useful for testing)
  static void reset() {
    _instance = null;
    _initFailed = false;
  }
}

