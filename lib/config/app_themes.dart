import 'package:flutter/material.dart';

/// Theme color definitions for the application
class AppThemeColors {
  final Color background;
  final Color surface;
  final Color card;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color text;
  final Color muted;
  final Color success;
  final Color warning;
  final Color error;

  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.card,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.text,
    required this.muted,
    required this.success,
    required this.warning,
    required this.error,
  });

  /// Cyan theme (default)
  static const AppThemeColors cyan = AppThemeColors(
    background: Color(0xFF0a0f0f),
    surface: Color(0xFF141a1a),
    card: Color(0xFF1a2222),
    primary: Color(0xFF4dd4d4),
    secondary: Color(0xFF5cdfdf),
    accent: Color(0xFF44e4e4),
    text: Color(0xFFf0fefe),
    muted: Color(0xFFb3d9d9),
    success: Color(0xFF00e6a6),
    warning: Color(0xFFffd93d),
    error: Color(0xFFff6b6b),
  );

  /// Green theme
  static const AppThemeColors green = AppThemeColors(
    background: Color(0xFF0a0f0a),
    surface: Color(0xFF141a14),
    card: Color(0xFF1a221a),
    primary: Color(0xFF1e9b71),
    secondary: Color(0xFF26b584),
    accent: Color(0xFF1ed18a),
    text: Color(0xFFf0fef0),
    muted: Color(0xFFb3d9c4),
    success: Color(0xFF00e6a6),
    warning: Color(0xFFffd93d),
    error: Color(0xFFff6b6b),
  );

  /// Purple theme
  static const AppThemeColors purple = AppThemeColors(
    background: Color(0xFF0f0a14),
    surface: Color(0xFF1a1420),
    card: Color(0xFF221a28),
    primary: Color(0xFFa855f7),
    secondary: Color(0xFFc084fc),
    accent: Color(0xFFd8b4fe),
    text: Color(0xFFfef0fe),
    muted: Color(0xFFd9b3d9),
    success: Color(0xFF00e6a6),
    warning: Color(0xFFffd93d),
    error: Color(0xFFff6b6b),
  );

  /// Blue theme
  static const AppThemeColors blue = AppThemeColors(
    background: Color(0xFF0a0e14),
    surface: Color(0xFF14181f),
    card: Color(0xFF1a1f2a),
    primary: Color(0xFF3b82f6),
    secondary: Color(0xFF60a5fa),
    accent: Color(0xFF93c5fd),
    text: Color(0xFFf0f5fe),
    muted: Color(0xFFb3c5d9),
    success: Color(0xFF00e6a6),
    warning: Color(0xFFffd93d),
    error: Color(0xFFff6b6b),
  );

  /// Get theme colors by name
  static AppThemeColors getThemeColors(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'green':
        return green;
      case 'purple':
        return purple;
      case 'blue':
        return blue;
      case 'cyan':
      default:
        return cyan;
    }
  }

  /// Get background gradient for the theme
  LinearGradient getBackgroundGradient() {
    return LinearGradient(
      colors: [
        primary.withValues(alpha: 0.08),
        Colors.transparent,
      ],
      begin: Alignment.topLeft,
      end: Alignment.center,
    );
  }

  /// Get background decoration gradient
  LinearGradient getBackgroundDecoration() {
    return LinearGradient(
      colors: [
        primary.withValues(alpha: 0.08),
        Colors.transparent,
        secondary.withValues(alpha: 0.08),
      ],
      stops: const [0.0, 0.55, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Get success gradient
  LinearGradient get successGradient => LinearGradient(
        colors: [success, success.withValues(alpha: 0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get error gradient
  LinearGradient get errorGradient => LinearGradient(
        colors: [error, error.withValues(alpha: 0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get primary gradient
  LinearGradient get primaryGradient => LinearGradient(
        colors: [primary, secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get shimmer base color
  Color get shimmerBase => surface;

  /// Get shimmer highlight color
  Color get shimmerHighlight => primary.withValues(alpha: 0.15);

  /// Get glassmorphism color
  Color get glassBackground => card.withValues(alpha: 0.7);

  /// Get card shadow color
  Color get cardShadow => primary.withValues(alpha: 0.1);
}

/// Theme helper class
class AppThemes {
  /// Get all available themes
  static const List<String> availableThemes = ['cyan', 'green', 'purple', 'blue'];

  /// Get theme display name
  static String getThemeDisplayName(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'cyan':
        return 'Cyan';
      case 'green':
        return 'Green';
      case 'purple':
        return 'Purple';
      case 'blue':
        return 'Blue';
      default:
        return 'Cyan';
    }
  }

  /// Get theme icon
  static IconData getThemeIcon(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'cyan':
        return Icons.water_drop;
      case 'green':
        return Icons.eco;
      case 'purple':
        return Icons.auto_awesome;
      case 'blue':
        return Icons.wb_twilight;
      default:
        return Icons.palette;
    }
  }
}

