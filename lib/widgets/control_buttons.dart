import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

/// Modern control buttons widget - Dashboard style design
/// Contains Start/Stop, Settings, and Clear Activity buttons
class ControlButtons extends StatefulWidget {
  final bool isScanning;
  final VoidCallback onStartStop;
  final VoidCallback onSettings;
  final VoidCallback onClearActivity;

  const ControlButtons({
    super.key,
    required this.isScanning,
    required this.onStartStop,
    required this.onSettings,
    required this.onClearActivity,
  });

  @override
  State<ControlButtons> createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<ControlButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isScanning) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ControlButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !oldWidget.isScanning) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isScanning && oldWidget.isScanning) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main action button - Larger, prominent
        _buildMainActionButton(),
        const SizedBox(height: 16),
        
        // Secondary action buttons row
        Row(
          children: [
            Expanded(child: _buildSecondaryButton(
              icon: Icons.settings,
              label: 'Settings',
              onTap: widget.onSettings,
              gradient: AppColors.primaryGradient,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildSecondaryButton(
              icon: Icons.clear_all,
              label: 'Clear Activity',
              onTap: widget.onClearActivity,
              gradient: AppColors.warningGradient,
            )),
          ],
        ),
      ],
    );
  }

  /// Build main action button with modern design
  Widget _buildMainActionButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isScanning ? _pulseAnimation.value : 1.0,
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              gradient: widget.isScanning
                  ? AppColors.errorGradient
                  : AppColors.successGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (widget.isScanning 
                      ? AppColors.error 
                      : AppColors.success).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onStartStop,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.isScanning ? Icons.stop : Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.isScanning ? 'STOP SCANNER' : 'START SCANNER',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (widget.isScanning)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build secondary action button
  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required LinearGradient gradient,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.card.withValues(alpha: 0.9),
            AppColors.surface.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: gradient.colors.first.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

