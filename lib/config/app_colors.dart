import 'package:flutter/material.dart';

/// Premium application color scheme - Modern dashboard design inspired
class AppColors {
  // Base colors - Deep navy like the dashboard
  static const Color background = Color(0xFF0A0E1A);     // Deep navy/dark blue
  static const Color surface = Color(0xFF161C2D);        // Surface layer
  static const Color card = Color(0xFF1E2435);           // Card background
  static const Color cardHover = Color(0xFF252B3E);      // Hover state
  
  // Primary colors - Purple/Pink gradients from dashboard
  static const Color primary = Color(0xFF6366F1);        // Indigo
  static const Color primaryLight = Color(0xFF8B5CF6);   // Purple
  static const Color primaryDark = Color(0xFF4F46E5);    // Darker indigo
  
  // Secondary & accent - Dashboard inspired
  static const Color secondary = Color(0xFF64748B);      // Slate gray  
  static const Color accent = Color(0xFFEC4899);         // Pink accent
  
  // Text colors - Dashboard inspired contrast
  static const Color textPrimary = Color(0xFFF1F5F9);    // Main text (excellent contrast)
  static const Color textSecondary = Color(0xFFCBD5E1);  // Secondary text
  static const Color textMuted = Color(0xFF94A3B8);      // Muted text
  static const Color textWhite = Color(0xFFFFFFFF);      // Pure white for emphasis
  
  // Keep old names for compatibility
  static const Color text = textPrimary;
  static const Color muted = textSecondary;
  
  // Status colors - Modern, vibrant like dashboard
  static const Color success = Color(0xFF10B981);        // Emerald green
  static const Color successLight = Color(0xFF34D399);   // Light emerald
  static const Color warning = Color(0xFFF59E0B);        // Amber
  static const Color warningLight = Color(0xFFFBBF24);   // Light amber
  static const Color error = Color(0xFFEF4444);          // Red
  static const Color errorLight = Color(0xFFF87171);     // Light red
  
  // UI element colors - Dashboard style
  static const Color border = Color(0xFF334155);         // Border color
  static const Color borderHover = Color(0xFF475569);    // Hover border
  static const Color divider = Color(0xFF1E293B);        // Divider lines
  
  // Transparent overlays
  static final Color overlay = const Color(0xFF000000).withValues(alpha: 0.5);
  static final Color overlayLight = const Color(0xFF000000).withValues(alpha: 0.2);
  
  // Gradients - Dashboard inspired modern gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Dashboard-style background gradient
  static BoxDecoration getBackgroundDecoration() {
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
      color: background,
    );
  }
  
  // Shadow for elevation - Premium smooth shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.4),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];
  
  static List<BoxShadow> cardShadowHover = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.5),
      blurRadius: 32,
      offset: const Offset(0, 12),
      spreadRadius: -4,
    ),
  ];
  
  static List<BoxShadow> cardShadowSubtle = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.2),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];
  
  // Premium border radius constants
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;
}
