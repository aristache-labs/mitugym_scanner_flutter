import 'package:flutter/material.dart';

/// Premium theme presets for the app
class AppThemes {
  // Default theme - Professional Blue
  static final AppThemeColors blue = AppThemeColors(
    primary: const Color(0xFF58A6FF),
    secondary: const Color(0xFF8B949E),
    accent: const Color(0xFF79C0FF),
    success: const Color(0xFF3FB950),
    warning: const Color(0xFFD29922),
    error: const Color(0xFFDA3633),
    surface: const Color(0xFF161B22),
    card: const Color(0xFF1C2128),
    text: const Color(0xFFC9D1D9),
    muted: const Color(0xFF8B949E),
  );
  
  // Cyan theme - Softer cyan (original but toned down)
  static final AppThemeColors cyan = AppThemeColors(
    primary: const Color(0xFF3DCCC7),
    secondary: const Color(0xFF8B949E),
    accent: const Color(0xFF4DE0D9),
    success: const Color(0xFF3FB950),
    warning: const Color(0xFFD29922),
    error: const Color(0xFFDA3633),
    surface: const Color(0xFF161B22),
    card: const Color(0xFF1C2128),
    text: const Color(0xFFC9D1D9),
    muted: const Color(0xFF8B949E),
  );
  
  // Green theme
  static final AppThemeColors green = AppThemeColors(
    primary: const Color(0xFF3FB950),
    secondary: const Color(0xFF8B949E),
    accent: const Color(0xFF56D364),
    success: const Color(0xFF3FB950),
    warning: const Color(0xFFD29922),
    error: const Color(0xFFDA3633),
    surface: const Color(0xFF161B22),
    card: const Color(0xFF1C2128),
    text: const Color(0xFFC9D1D9),
    muted: const Color(0xFF8B949E),
  );
  
  // Purple theme
  static final AppThemeColors purple = AppThemeColors(
    primary: const Color(0xFFBC8CFF),
    secondary: const Color(0xFF8B949E),
    accent: const Color(0xFFD2A8FF),
    success: const Color(0xFF3FB950),
    warning: const Color(0xFFD29922),
    error: const Color(0xFFDA3633),
    surface: const Color(0xFF161B22),
    card: const Color(0xFF1C2128),
    text: const Color(0xFFC9D1D9),
    muted: const Color(0xFF8B949E),
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
  
  /// Get theme colors by name
  static AppThemeColors getThemeColors(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'cyan':
        return AppThemes.cyan;
      case 'green':
        return AppThemes.green;
      case 'purple':
        return AppThemes.purple;
      case 'blue':
      default:
        return AppThemes.blue;
    }
  }
  
  /// Get list of available themes
  List<String> get availableThemes => ['blue', 'cyan', 'green', 'purple'];
  
  /// Get theme icon
  static IconData getThemeIcon(String theme) {
    switch (theme) {
      case 'blue':
        return Icons.water_drop;
      case 'cyan':
        return Icons.circle;
      case 'green':
        return Icons.eco;
      case 'purple':
        return Icons.star;
      default:
        return Icons.circle;
    }
  }
  
  /// Get theme display name
  static String getThemeDisplayName(String theme) {
    switch (theme) {
      case 'blue':
        return 'Professional Blue';
      case 'cyan':
        return 'Cyan';
      case 'green':
        return 'Green';
      case 'purple':
        return 'Purple';
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
  
  /// Background decoration
  BoxDecoration getBackgroundDecoration() {
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topLeft,
        radius: 2.0,
        colors: [
          surface.withValues(alpha: 0.6),
          const Color(0xFF0D1117),
        ],
      ),
      color: const Color(0xFF0D1117),
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
