import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State notifier for managing locale changes and persistence
class LanguageNotifier extends Notifier<Locale> {
  static const String _localeKey = 'app_locale';
  
  // Supported locales
  static const Locale englishLocale = Locale('en');
  static const Locale romanianLocale = Locale('ro');
  
  static const List<Locale> supportedLocales = [
    englishLocale,
    romanianLocale,
  ];

  @override
  Locale build() {
    // Load saved locale asynchronously
    _loadSavedLocale();
    // Return default while loading
    return englishLocale;
  }

  /// Load saved locale from SharedPreferences
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);
      
      if (savedLocaleCode != null) {
        final locale = _localeFromCode(savedLocaleCode);
        if (locale != null) {
          state = locale;
        }
      }
    } catch (e) {
      // If loading fails, keep default English locale
      debugPrint('Failed to load saved locale: $e');
    }
  }
  
  /// Get saved locale synchronously (for initial load)
  static Future<Locale> getSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);
      
      if (savedLocaleCode != null) {
        switch (savedLocaleCode) {
          case 'en':
            return englishLocale;
          case 'ro':
            return romanianLocale;
        }
      }
    } catch (e) {
      debugPrint('Failed to load saved locale: $e');
    }
    return englishLocale;
  }

  /// Change the application locale
  Future<void> changeLocale(Locale newLocale) async {
    if (!supportedLocales.contains(newLocale)) {
      debugPrint('Unsupported locale: ${newLocale.languageCode}');
      return;
    }

    try {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, newLocale.languageCode);
      
      // Update state
      state = newLocale;
    } catch (e) {
      debugPrint('Failed to save locale: $e');
    }
  }

  /// Get locale from language code
  Locale? _localeFromCode(String code) {
    switch (code) {
      case 'en':
        return englishLocale;
      case 'ro':
        return romanianLocale;
      default:
        return null;
    }
  }

  /// Get display name for a locale
  static String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ro':
        return 'Romanian';
      default:
        return locale.languageCode;
    }
  }
}

/// Language notifier with initial locale (for overriding default)
class LanguageNotifierWithInitial extends LanguageNotifier {
  final Locale _initialLocale;
  
  LanguageNotifierWithInitial(this._initialLocale);
  
  @override
  Locale build() {
    return _initialLocale;
  }
}

/// Provider for managing application locale/language
final languageProvider = NotifierProvider<LanguageNotifier, Locale>(() {
  return LanguageNotifier();
});

