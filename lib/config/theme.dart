import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Material Design 3 theme matching modern dashboard design
/// Purple/Indigo color scheme with deep navy background

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  
  // Use Google Fonts - Inter for modern dashboard look
  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
  
  // Color scheme - Dashboard inspired
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.textPrimary,
    onError: Colors.white,
    tertiary: AppColors.accent,
  ),
  
  // Scaffold background - Deep navy
  scaffoldBackgroundColor: AppColors.background,
  
  // App bar theme - Gradient style like dashboard
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: GoogleFonts.inter(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    ),
  ),
  
  // Card theme - Modern dashboard style
  cardTheme: CardThemeData(
    color: AppColors.card,
    elevation: 0,
    shadowColor: Colors.black.withValues(alpha: 0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppColors.radiusMedium),
    ),
  ),
  
  // Elevated button theme - Dashboard style gradients
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusSmall),
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
  ),
  
  // Text button theme - Modern dashboard style
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    ),
  ),
  
  // Input decoration theme - Dashboard inspired
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppColors.radiusSmall),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppColors.radiusSmall),
      borderSide: BorderSide(
        color: AppColors.border,
        width: 1.5,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppColors.radiusSmall),
      borderSide: BorderSide(
        color: AppColors.primary,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppColors.radiusSmall),
      borderSide: BorderSide(
        color: AppColors.error,
        width: 1.5,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    labelStyle: GoogleFonts.inter(
      color: AppColors.textMuted,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: GoogleFonts.inter(
      color: AppColors.textMuted,
      fontSize: 14,
    ),
  ),
  
  // Icon theme - Dashboard style
  iconTheme: IconThemeData(
    color: AppColors.primary,
    size: 24,
  ),
  
  // Progress indicator theme
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: AppColors.surface,
    circularTrackColor: AppColors.surface,
  ),
  
  // Divider theme - Subtle lines
  dividerTheme: DividerThemeData(
    color: AppColors.divider,
    thickness: 1,
    space: 1,
  ),
  
  // Snackbar theme - Dashboard style
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.card,
    contentTextStyle: GoogleFonts.inter(
      color: AppColors.textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppColors.radiusSmall),
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 8,
  ),
);
