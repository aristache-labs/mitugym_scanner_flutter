import 'package:flutter/material.dart';

/// Premium theme presets for the app - Cyan/Turquoise inspired
class AppThemes {
  // Default theme - Modern Cyan/Turquoise (Admin panel style)
  static final AppThemeColors cyan = AppThemeColors(
    primary: const Color(0xFF4DD4D4),     // Primary cyan
    secondary: const Color(0xFF5CDFDF),   // Secondary cyan
    accent: const Color(0xFF44E4E4),      // Accent cyan
    success: const Color(0xFF00E6A6),     // Bright green
    warning: const Color(0xFFFFD93D),     // Yellow
    error: const Color(0xFFFF6B6B),       // Red
    surface: const Color(0xFF141A1A),     // Surface
    card: const Color(0xFF1A2222),        // Card
    text: const Color(0xFFF0FEFE),        // Main text
    muted: const Color(0xFFB3D9D9),       // Muted text
  );
  
  // Purple theme - Alternative
  static final AppThemeColors purple = AppThemeColors(
    primary: const Color(0xFF6366F1),    // Indigo
    secondary: const Color(0xFF64748B),   // Slate
    accent: const Color(0xFFEC4899),      // Pink
    success: const Color(0xFF00E6A6),     // Bright green
    warning: const Color(0xFFFFD93D),     // Yellow
    error: const Color(0xFFFF6B6B),       // Red
    surface: const Color(0xFF141A1A),     // Surface
    card: const Color(0xFF1A2222),        // Card
    text: const Color(0xFFF0FEFE),        // Main text
    muted: const Color(0xFFB3D9D9),       // Muted text
  );
  
  // Blue theme - Modern blue variant
  static final AppThemeColors blue = AppThemeColors(
    primary: const Color(0xFF3B82F6),    // Blue
    secondary: const Color(0xFF5CDFDF),   // Cyan
    accent: const Color(0xFF06B6D4),      // Cyan
    success: const Color(0xFF00E6A6),     // Bright green
    warning: const Color(0xFFFFD93D),     // Yellow
    error: const Color(0xFFFF6B6B),       // Red
    surface: const Color(0xFF141A1A),     // Surface
    card: const Color(0xFF1A2222),        // Card
    text: const Color(0xFFF0FEFE),        // Main text
    muted: const Color(0xFFB3D9D9),       // Muted text
  );
  
  // Green theme - Modern emerald variant
  static final AppThemeColors green = AppThemeColors(
    primary: const Color(0xFF00E6A6),     // Bright green
    secondary: const Color(0xFF33EDB8),   // Light green
    accent: const Color(0xFF33EDB8),      // Light emerald
    success: const Color(0xFF00E6A6),     // Bright green
    warning: const Color(0xFFFFD93D),     // Yellow
    error: const Color(0xFFFF6B6B),       // Red
    surface: const Color(0xFF141A1A),     // Surface
    card: const Color(0xFF1A2222),        // Card
    text: const Color(0xFFF0FEFE),        // Main text
    muted: const Color(0xFFB3D9D9),       // Muted text
  );
}

/// Theme color set
class AppThemeColors {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color success;
  final Color warning;
  final Color error;
  final Color surface;
  final Color card;
  final Color text;
  final Color muted;
  
  const AppThemeColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.surface,
    required this.card,
    required this.text,
    required this.muted,
  });
  
  /// Get theme colors by name - Cyan is now default
  static AppThemeColors getThemeColors(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'blue':
        return AppThemes.blue;
      case 'purple':
        return AppThemes.purple;
      case 'green':
        return AppThemes.green;
      case 'cyan':
      default:
        return AppThemes.cyan; // Cyan is now default
    }
  }
  
  /// Get list of available themes
  List<String> get availableThemes => ['cyan', 'purple', 'blue', 'green'];
  
  /// Get theme icon
  static IconData getThemeIcon(String theme) {
    switch (theme) {
      case 'cyan':
        return Icons.water_drop;
      case 'purple':
        return Icons.star;
      case 'blue':
        return Icons.circle;
      case 'green':
        return Icons.eco;
      default:
        return Icons.water_drop;
    }
  }
  
  /// Get theme display name
  static String getThemeDisplayName(String theme) {
    switch (theme) {
      case 'cyan':
        return 'Cyan Turquoise';
      case 'purple':
        return 'Modern Purple';
      case 'blue':
        return 'Ocean Blue';
      case 'green':
        return 'Emerald';
      default:
        return theme[0].toUpperCase() + theme.substring(1);
    }
  }
  
  /// Primary gradient
  LinearGradient get primaryGradient => LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Background decoration - Dark cyan gradient
  BoxDecoration getBackgroundDecoration() {
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topLeft,
        radius: 3.0,
        colors: [
          const Color(0xFF1A2222).withValues(alpha: 0.8),
          const Color(0xFF141A1A),
          const Color(0xFF0A0F0F),
        ],
      ),
      color: const Color(0xFF0A0F0F),
    );
  }
  
  /// Card shadow - Premium smooth shadows
  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.4),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];
  
  /// Subtle card shadow
  List<BoxShadow> get cardShadowSubtle => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.2),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];
  
  /// Premium border radius constants
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;
}
