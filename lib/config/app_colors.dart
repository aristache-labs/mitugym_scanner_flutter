import 'package:flutter/material.dart';

/// App color palette matching the admin panel design
/// Based on the MituGym admin panel color scheme
class AppColors {
  // Base colors
  static const Color background = Color(0xFF0a0f0f);
  static const Color surface = Color(0xFF141a1a);
  static const Color card = Color(0xFF1a2222);
  
  // Brand colors
  static const Color primary = Color(0xFF4dd4d4);
  static const Color secondary = Color(0xFF5cdfdf);
  static const Color accent = Color(0xFF44e4e4);
  
  // Text colors
  static const Color text = Color(0xFFf0fefe);
  static const Color muted = Color(0xFFb3d9d9);
  
  // Status colors
  static const Color success = Color(0xFF00e6a6);
  static const Color warning = Color(0xFFffd93d);
  static const Color error = Color(0xFFff6b6b);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF00cc8f)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, Color(0xFFff5252)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Radial gradients for background
  static BoxDecoration getBackgroundDecoration() {
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topLeft,
        radius: 1.5,
        colors: [
          accent.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55],
      ),
      color: background,
    );
  }
}

