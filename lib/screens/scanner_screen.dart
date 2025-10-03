import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../providers/scan_provider.dart';
import '../providers/windows_scanner_provider.dart';
import '../widgets/collapsible_camera_widget.dart';
import '../widgets/member_info_card.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/control_buttons.dart';

/// Scanner screen - QR Code scanning interface
class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);
    final scannerState = ref.watch(windowsScannerControllerProvider);

    return Row(
      children: [
        // Left column - Scanner and controls
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // Scanner card
              _buildScannerCard(scannerState, scanState),
              const SizedBox(height: 16),
              
              // Member info card
              if (scanState.lastResult != null)
                _buildMemberInfoCard(scanState),
              
              // Countdown timer
              if (scanState.cooldownActive)
                _buildCountdownCard(scanState),
              
              const Spacer(),
              
              // Control buttons
              _buildControlButtonsCard(scannerState, ref),
            ],
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Right column - Status overview
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildStatusOverviewCard(scanState),
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }

  /// Build scanner card with modern design
  Widget _buildScannerCard(
    WindowsScannerControllerState scannerState,
    ScanState scanState,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.9),
            AppColors.surface.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Camera Preview',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scannerState.isActive
                                  ? AppColors.success
                                  : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            scanState.statusMessage ?? 'Ready to scan',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Camera preview
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: CollapsibleCameraWidget(
              scannerService: scannerState.service,
              isScanning: scannerState.isActive,
              statusMessage: scanState.statusMessage ?? 'Ready',
            ),
          ),
        ],
      ),
    );
  }

  /// Build member info card with modern design
  Widget _buildMemberInfoCard(ScanState scanState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.9),
            AppColors.surface.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: MemberInfoCard(
          scanResult: scanState.lastResult!,
        ),
      ),
    );
  }

  /// Build countdown card with modern design
  Widget _buildCountdownCard(ScanState scanState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withValues(alpha: 0.15),
            AppColors.warningLight.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: CountdownTimer(
          remainingSeconds: scanState.cooldownRemaining,
          totalSeconds: scanState.cooldownRemaining,
        ),
      ),
    );
  }

  /// Build control buttons card
  Widget _buildControlButtonsCard(
    WindowsScannerControllerState scannerState,
    WidgetRef ref,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.9),
            AppColors.surface.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ControlButtons(
        isScanning: scannerState.isActive,
        onStartStop: () async {
          if (scannerState.isActive) {
            await ref.read(windowsScannerControllerProvider.notifier).stopScanner();
          } else {
            await ref.read(windowsScannerControllerProvider.notifier).startScanner();
          }
        },
        onSettings: () {},
        onClearActivity: () {
          ref.read(scanProvider.notifier).clearActivity();
        },
      ),
    );
  }

  /// Build status overview card
  Widget _buildStatusOverviewCard(ScanState scanState) {
    final todayScans = scanState.recentActivity
        .where((a) => a.time.day == DateTime.now().day)
        .length;
    final todaySuccess = scanState.recentActivity
        .where((a) => a.time.day == DateTime.now().day && a.success)
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.9),
            AppColors.surface.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Today\'s Overview',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildStatusItem(
            label: 'Total Scans',
            value: '$todayScans',
            color: AppColors.primary,
            icon: Icons.qr_code_scanner,
          ),
          const SizedBox(height: 16),
          _buildStatusItem(
            label: 'Successful',
            value: '$todaySuccess',
            color: AppColors.success,
            icon: Icons.check_circle,
          ),
          const SizedBox(height: 16),
          _buildStatusItem(
            label: 'Errors',
            value: '${todayScans - todaySuccess}',
            color: AppColors.error,
            icon: Icons.error,
          ),
        ],
      ),
    );
  }

  /// Build status item
  Widget _buildStatusItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

