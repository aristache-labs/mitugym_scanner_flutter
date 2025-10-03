import 'package:flutter/material.dart';

/// Premium application color scheme - Cyan/Turquoise modern design
class AppColors {
  // Base colors - Very dark backgrounds matching admin panel
  static const Color background = Color(0xFF0A0F0F);     // Very dark teal/black
  static const Color surface = Color(0xFF141A1A);        // Surface layer
  static const Color card = Color(0xFF1A2222);           // Card background
  static const Color cardHover = Color(0xFF1F2828);      // Hover state
  
  // Primary colors - Cyan/Turquoise theme from admin panel
  static const Color primary = Color(0xFF4DD4D4);        // Primary cyan
  static const Color primaryLight = Color(0xFF5CDFDF);   // Secondary cyan
  static const Color primaryDark = Color(0xFF3BC5C5);    // Darker cyan
  
  // Secondary & accent - Cyan variations
  static const Color secondary = Color(0xFF5CDFDF);      // Secondary cyan
  static const Color accent = Color(0xFF44E4E4);         // Accent cyan
  
  // Text colors - Admin panel inspired contrast
  static const Color textPrimary = Color(0xFFF0FEFE);    // Main text - very light cyan tint
  static const Color textSecondary = Color(0xFFB3D9D9);  // Muted cyan tint
  static const Color textMuted = Color(0xFF8AB3B3);      // More muted cyan
  static const Color textWhite = Color(0xFFFFFFFF);      // Pure white for emphasis
  
  // Keep old names for compatibility
  static const Color text = textPrimary;
  static const Color muted = textSecondary;
  
  // Status colors - Matching admin panel
  static const Color success = Color(0xFF00E6A6);        // Bright green (admin panel)
  static const Color successLight = Color(0xFF33EDB8);   // Light green
  static const Color warning = Color(0xFFFFD93D);        // Yellow (admin panel)
  static const Color warningLight = Color(0xFFFFE367);   // Light yellow
  static const Color error = Color(0xFFFF6B6B);          // Red (admin panel)
  static const Color errorLight = Color(0xFFFF8989);     // Light red
  
  // UI element colors - Dark theme borders
  static const Color border = Color(0xFF2A3535);         // Border color (dark cyan tint)
  static const Color borderHover = Color(0xFF354545);    // Hover border
  static const Color divider = Color(0xFF1F2828);        // Divider lines
  
  // Transparent overlays
  static final Color overlay = const Color(0xFF000000).withValues(alpha: 0.5);
  static final Color overlayLight = const Color(0xFF000000).withValues(alpha: 0.2);
  
  // Gradients - Cyan/turquoise modern gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4DD4D4), Color(0xFF5CDFDF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF44E4E4), Color(0xFF5CDFDF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00E6A6), Color(0xFF33EDB8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8989)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFFD93D), Color(0xFFFFE367)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Dark cyan background gradient matching admin panel
  static BoxDecoration getBackgroundDecoration() {
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
