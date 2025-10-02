import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Control buttons widget - Premium smooth design
/// Contains Start/Stop, Settings, and Clear Activity buttons
class ControlButtons extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Start/Stop button - Premium gradient design
        Expanded(
          flex: 2,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isScanning
                    ? [AppColors.error, AppColors.errorLight]
                    : [AppColors.success, AppColors.successLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppColors.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: (isScanning ? AppColors.error : AppColors.success)
                      .withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: onStartStop,
              icon: Icon(
                isScanning ? Icons.stop_circle : Icons.play_circle_filled,
                size: 28,
              ),
              label: Text(
                isScanning ? 'STOP SCANNER' : 'START SCANNER',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppColors.radiusMedium),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Settings button - Premium design
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.card,
                AppColors.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppColors.radiusMedium),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: AppColors.cardShadowSubtle,
          ),
          child: IconButton(
            onPressed: onSettings,
            icon: Icon(Icons.settings, color: AppColors.primary),
            iconSize: 28,
            tooltip: 'Settings',
          ),
        ),
        const SizedBox(width: 16),

        // Clear activity button - Premium design
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.card,
                AppColors.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppColors.radiusMedium),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: AppColors.cardShadowSubtle,
          ),
          child: IconButton(
            onPressed: onClearActivity,
            icon: Icon(Icons.clear_all, color: AppColors.warning),
            iconSize: 28,
            tooltip: 'Clear Activity',
          ),
        ),
      ],
    );
  }
}

