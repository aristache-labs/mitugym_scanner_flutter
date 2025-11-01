import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_colors.dart';
import '../providers/scan_provider.dart';
import '../providers/windows_scanner_provider.dart';
import '../widgets/collapsible_camera_widget.dart';
import '../widgets/member_info_card.dart';
import '../widgets/countdown_timer.dart';

/// Scanner screen - QR Code scanning interface with modern, compact design
class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);
    final scannerState = ref.watch(windowsScannerControllerProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - Scanner and controls (more compact)
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Scanner card with compact design
                _buildScannerCard(scannerState, scanState, ref),
                const SizedBox(height: 12),
                
                // Start/Stop scanner button
                _buildScannerButton(scannerState, ref),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Right column - Member details or placeholder
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Member info card or placeholder
                if (scanState.lastResult != null)
                  _buildMemberInfoCard(scanState)
                else
                  _buildPlaceholderCard(),
                
                const SizedBox(height: 12),
                
                // Countdown timer
                if (scanState.cooldownActive)
                  _buildCountdownCard(scanState),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build scanner card with modern, compact design matching app style
  Widget _buildScannerCard(
    WindowsScannerControllerState scannerState,
    ScanState scanState,
    WidgetRef ref,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.85),
            AppColors.surface.withValues(alpha: 0.65),
          ],
        ),
        borderRadius: BorderRadius.circular(AppColors.radiusMedium),
        border: Border.all(
          color: scannerState.isActive 
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compact header with status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (scannerState.isActive ? AppColors.success : AppColors.primary)
                      .withValues(alpha: 0.12),
                  const Color(0xFF0D0D0D).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: (scannerState.isActive ? AppColors.success : AppColors.primary)
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Icon with subtle styling
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (scannerState.isActive 
                        ? AppColors.success
                        : AppColors.primary).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    scannerState.isActive ? LucideIcons.scan : LucideIcons.camera,
                    color: scannerState.isActive 
                        ? AppColors.success
                        : AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Camera Preview',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scannerState.isActive
                                  ? AppColors.success
                                  : AppColors.textMuted,
                              boxShadow: scannerState.isActive
                                  ? [
                                      BoxShadow(
                                        color: AppColors.success.withValues(alpha: 0.5),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          )
                              .animate(
                                onPlay: (controller) => scannerState.isActive 
                                    ? controller.repeat(reverse: true) 
                                    : controller.stop(),
                              )
                              .fadeIn(duration: 600.ms)
                              .then()
                              .fadeOut(duration: 600.ms),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              scanState.statusMessage ?? 'Ready to scan',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
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
          
          // Camera preview - compact padding
          Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppColors.radiusSmall),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: scannerState.isActive 
                          ? AppColors.success.withValues(alpha: 0.3)
                          : AppColors.border.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(AppColors.radiusSmall),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppColors.radiusSmall - 2),
                    child: CollapsibleCameraWidget(
                      scannerService: scannerState.service,
                      isScanning: scannerState.isActive,
                      statusMessage: scanState.statusMessage ?? 'Ready',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build member info card with modern, compact design
  Widget _buildMemberInfoCard(ScanState scanState) {
    final isSuccess = scanState.lastResult?.success ?? false;
    final statusColor = isSuccess ? AppColors.success : AppColors.error;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.85),
            AppColors.surface.withValues(alpha: 0.65),
          ],
        ),
        borderRadius: BorderRadius.circular(AppColors.radiusMedium),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compact header with status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  statusColor.withValues(alpha: 0.12),
                  const Color(0xFF0D0D0D).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: statusColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSuccess ? LucideIcons.userCheck : LucideIcons.userX,
                    color: statusColor,
                    size: 16,
                  ),
                )
                    .animate()
                    .scale(
                      duration: 300.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 200.ms),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Member Details',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isSuccess ? 'Access Granted' : 'Access Denied',
                        style: GoogleFonts.inter(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Member info content
          Padding(
            padding: const EdgeInsets.all(16),
            child: MemberInfoCard(
              scanResult: scanState.lastResult!,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuart);
  }

  /// Build placeholder card when no member scanned - compact design
  Widget _buildPlaceholderCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.6),
            AppColors.surface.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(AppColors.radiusMedium),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Icon(
              LucideIcons.qrCode,
              size: 40,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                duration: 2000.ms,
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.05, 1.05),
                curve: Curves.easeInOut,
              )
              .then()
              .scale(
                duration: 2000.ms,
                begin: const Offset(1.05, 1.05),
                end: const Offset(1.0, 1.0),
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 16),
          Text(
            'Waiting for scan...',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Scan a QR code to view member details',
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 12,
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build countdown card with compact design
  Widget _buildCountdownCard(ScanState scanState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withValues(alpha: 0.12),
            AppColors.warningLight.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(AppColors.radiusMedium),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: CountdownTimer(
        remainingSeconds: scanState.cooldownRemaining,
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuart);
  }

  /// Build scanner control button with compact design and smooth animations
  Widget _buildScannerButton(
    WindowsScannerControllerState scannerState,
    WidgetRef ref,
  ) {
    final isScanning = scannerState.isActive;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (isScanning) {
              await ref.read(windowsScannerControllerProvider.notifier).stopScanner();
            } else {
              await ref.read(windowsScannerControllerProvider.notifier).startScanner();
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              gradient: isScanning
                  ? LinearGradient(
                      colors: [
                        AppColors.error,
                        AppColors.errorLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: (isScanning ? AppColors.error : AppColors.primary)
                      .withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                  spreadRadius: -1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    isScanning ? LucideIcons.square : LucideIcons.play,
                    key: ValueKey(isScanning),
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  child: Text(
                    isScanning ? 'STOP SCANNER' : 'START SCANNER',
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

