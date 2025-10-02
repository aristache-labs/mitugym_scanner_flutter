import 'package:flutter/material.dart';

/// Premium application color scheme - Modern, professional, easy on the eyes
class AppColors {
  // Base colors - darker, more neutral
  static const Color background = Color(0xFF0D1117);     // Deep dark blue-gray
  static const Color surface = Color(0xFF161B22);        // Slightly lighter
  static const Color card = Color(0xFF1C2128);           // Card background
  static const Color cardHover = Color(0xFF21262D);      // Hover state
  
  // Primary colors - softer cyan/teal (less bright)
  static const Color primary = Color(0xFF58A6FF);        // Soft blue
  static const Color primaryLight = Color(0xFF79C0FF);   // Lighter blue
  static const Color primaryDark = Color(0xFF388BFD);    // Darker blue
  
  // Secondary & accent - subtle
  static const Color secondary = Color(0xFF8B949E);      // Neutral gray
  static const Color accent = Color(0xFF58A6FF);         // Same as primary for consistency
  
  // Text colors - proper contrast
  static const Color textPrimary = Color(0xFFC9D1D9);    // Main text (excellent contrast)
  static const Color textSecondary = Color(0xFF8B949E);  // Secondary text
  static const Color textMuted = Color(0xFF6E7681);      // Muted text
  static const Color textWhite = Color(0xFFFFFFFF);      // Pure white for emphasis
  
  // Keep old names for compatibility
  static const Color text = textPrimary;
  static const Color muted = textSecondary;
  
  // Status colors - softer, professional
  static const Color success = Color(0xFF3FB950);        // Softer green
  static const Color successLight = Color(0xFF56D364);   // Light green
  static const Color warning = Color(0xFFD29922);        // Softer yellow
  static const Color warningLight = Color(0xFFE3B341);   // Light yellow
  static const Color error = Color(0xFFDA3633);          // Softer red
  static const Color errorLight = Color(0xFFFF7B72);     // Light red
  
  // UI element colors
  static const Color border = Color(0xFF30363D);         // Border color
  static const Color borderHover = Color(0xFF484F58);    // Hover border
  static const Color divider = Color(0xFF21262D);        // Divider lines
  
  // Transparent overlays
  static final Color overlay = const Color(0xFF000000).withValues(alpha: 0.5);
  static final Color overlayLight = const Color(0xFF000000).withValues(alpha: 0.2);
  
  // Gradients - subtle, professional
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF388BFD), Color(0xFF58A6FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF2EA043), Color(0xFF3FB950)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFDA3633), Color(0xFFFF7B72)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFD29922), Color(0xFFE3B341)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Subtle background gradient
  static BoxDecoration getBackgroundDecoration() {
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topLeft,
        radius: 2.0,
        colors: [
          const Color(0xFF161B22).withValues(alpha: 0.6),
          const Color(0xFF0D1117),
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
