import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_colors.dart';
import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import 'premium_license_page.dart';

/// Premium About Dialog for MituGym Scanner
class PremiumAboutDialog extends StatelessWidget {
  const PremiumAboutDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 560,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 40,
              spreadRadius: 0,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient background (full width)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.accent.withValues(alpha: 0.08),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                ),
              ),
              child: Column(
                children: [
                  // Logo with glow effect (larger)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          blurRadius: 60,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Container(
                        color: AppColors.background,
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),
                  
                  const SizedBox(height: 24),
                  
                  // App name with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.accent,
                        AppColors.primary,
                      ],
                    ).createShader(bounds),
                    child: Text(
                      l10n.aboutAppName,
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideY(begin: 0.2, duration: 400.ms, delay: 200.ms),
                  
                  const SizedBox(height: 12),
                  
                  // Version
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${l10n.aboutVersion} ${AppConstants.appVersion}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 300.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        duration: 400.ms,
                        delay: 300.ms,
                      ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  // Description
                  Text(
                    l10n.aboutDescription,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 400.ms)
                      .slideY(begin: 0.2, duration: 400.ms, delay: 400.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Built with Flutter badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF027DFD).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF027DFD).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Flutter logo icon
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF027DFD),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            LucideIcons.zap,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.aboutBuiltWith,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF027DFD),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 500.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        duration: 400.ms,
                        delay: 500.ms,
                      ),
                  
                  const SizedBox(height: 24),
                  
                  // Divider
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.border.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Copyright
                  Text(
                    l10n.aboutCopyright,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 600.ms),
                  
                  const SizedBox(height: 20),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Licenses button
                      _ActionButton(
                        label: l10n.aboutLicenses,
                        icon: LucideIcons.scroll,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PremiumLicensePage(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Close button
                      _ActionButton(
                        label: l10n.aboutClose,
                        icon: LucideIcons.x,
                        isPrimary: false,
                        isClose: true,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 700.ms)
                      .slideY(begin: 0.2, duration: 400.ms, delay: 700.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Action button for the about dialog
class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool isClose;
  final VoidCallback onPressed;
  
  const _ActionButton({
    required this.label,
    required this.icon,
    this.isPrimary = false,
    this.isClose = false,
    required this.onPressed,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Define colors based on button type
    Color getBackgroundColor() {
      if (widget.isPrimary) {
        return _isHovered 
            ? AppColors.primary 
            : AppColors.primary.withValues(alpha: 0.9);
      } else if (widget.isClose) {
        return AppColors.error.withValues(alpha: 0.08);
      } else {
        return _isHovered
            ? AppColors.surface.withValues(alpha: 0.8)
            : AppColors.surface;
      }
    }
    
    Color getBorderColor() {
      if (widget.isPrimary) {
        return Colors.transparent;
      } else if (widget.isClose) {
        return AppColors.error.withValues(alpha: 0.3);
      } else {
        return _isHovered
            ? AppColors.primary.withValues(alpha: 0.3)
            : AppColors.border;
      }
    }
    
    Color getIconColor() {
      if (widget.isPrimary) {
        return Colors.white;
      } else if (widget.isClose) {
        return AppColors.error.withValues(alpha: 0.9);
      } else {
        return _isHovered ? AppColors.primary : AppColors.textSecondary;
      }
    }
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: getBackgroundColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: getBorderColor(),
              width: 1.5,
            ),
            boxShadow: _isHovered && widget.isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : _isHovered && widget.isClose
                ? [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: getIconColor(),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: getIconColor(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Show the premium about dialog
void showPremiumAboutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const PremiumAboutDialog(),
  );
}

