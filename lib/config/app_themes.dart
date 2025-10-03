import 'package:flutter/material.dart';

/// Premium theme presets for the app - Dashboard inspired
class AppThemes {
  // Default theme - Modern Purple/Indigo (Dashboard style)
  static final AppThemeColors purple = AppThemeColors(
    primary: const Color(0xFF6366F1),    // Indigo
    secondary: const Color(0xFF64748B),   // Slate
    accent: const Color(0xFFEC4899),      // Pink
    success: const Color(0xFF10B981),     // Emerald
    warning: const Color(0xFFF59E0B),     // Amber
    error: const Color(0xFFEF4444),       // Red
    surface: const Color(0xFF161C2D),     // Surface
    card: const Color(0xFF1E2435),        // Card
    text: const Color(0xFFF1F5F9),        // Main text
    muted: const Color(0xFF94A3B8),       // Muted text
  );
  
  // Blue theme - Modern blue variant
  static final AppThemeColors blue = AppThemeColors(
    primary: const Color(0xFF3B82F6),    // Blue
    secondary: const Color(0xFF64748B),   // Slate
    accent: const Color(0xFF06B6D4),      // Cyan
    success: const Color(0xFF10B981),     // Emerald
    warning: const Color(0xFFF59E0B),     // Amber
    error: const Color(0xFFEF4444),       // Red
    surface: const Color(0xFF161C2D),     // Surface
    card: const Color(0xFF1E2435),        // Card
    text: const Color(0xFFF1F5F9),        // Main text
    muted: const Color(0xFF94A3B8),       // Muted text
  );
  
  // Green theme - Modern emerald variant
  static final AppThemeColors green = AppThemeColors(
    primary: const Color(0xFF10B981),     // Emerald
    secondary: const Color(0xFF64748B),   // Slate
    accent: const Color(0xFF34D399),      // Light emerald
    success: const Color(0xFF10B981),     // Emerald
    warning: const Color(0xFFF59E0B),     // Amber
    error: const Color(0xFFEF4444),       // Red
    surface: const Color(0xFF161C2D),     // Surface
    card: const Color(0xFF1E2435),        // Card
    text: const Color(0xFFF1F5F9),        // Main text
    muted: const Color(0xFF94A3B8),       // Muted text
  );
  
  // Cyan theme - Modern cyan variant
  static final AppThemeColors cyan = AppThemeColors(
    primary: const Color(0xFF06B6D4),     // Cyan
    secondary: const Color(0xFF64748B),   // Slate
    accent: const Color(0xFF22D3EE),      // Light cyan
    success: const Color(0xFF10B981),     // Emerald
    warning: const Color(0xFFF59E0B),     // Amber
    error: const Color(0xFFEF4444),       // Red
    surface: const Color(0xFF161C2D),     // Surface
    card: const Color(0xFF1E2435),        // Card
    text: const Color(0xFFF1F5F9),        // Main text
    muted: const Color(0xFF94A3B8),       // Muted text
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
  
  /// Get theme colors by name - Purple is now default
  static AppThemeColors getThemeColors(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'blue':
        return AppThemes.blue;
      case 'cyan':
        return AppThemes.cyan;
      case 'green':
        return AppThemes.green;
      case 'purple':
      default:
        return AppThemes.purple; // Purple is now default
    }
  }
  
  /// Get list of available themes
  List<String> get availableThemes => ['purple', 'blue', 'cyan', 'green'];
  
  /// Get theme icon
  static IconData getThemeIcon(String theme) {
    switch (theme) {
      case 'purple':
        return Icons.star;
      case 'blue':
        return Icons.water_drop;
      case 'cyan':
        return Icons.circle;
      case 'green':
        return Icons.eco;
      default:
        return Icons.star;
    }
  }
  
  /// Get theme display name
  static String getThemeDisplayName(String theme) {
    switch (theme) {
      case 'purple':
        return 'Modern Purple';
      case 'blue':
        return 'Ocean Blue';
      case 'cyan':
        return 'Cyan';
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
  
  /// Background decoration - Dashboard style gradient
  BoxDecoration getBackgroundDecoration() {
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topLeft,
        radius: 3.0,
        colors: [
          const Color(0xFF1E293B).withValues(alpha: 0.8),
          const Color(0xFF0F172A),
          const Color(0xFF0A0E1A),
        ],
      ),
      color: const Color(0xFF0A0E1A),
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
