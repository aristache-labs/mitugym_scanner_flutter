import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/scan_result.dart';
import '../models/member_data.dart';
import '../config/app_colors.dart';

/// Modern member info card widget - Dashboard style
/// Displays scan result with elegant card design and animations
class MemberInfoCard extends StatelessWidget {
  final ScanResult scanResult;

  const MemberInfoCard({
    super.key,
    required this.scanResult,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = scanResult.success;
    final data = scanResult.data;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.95),
            AppColors.surface.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.2),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            // Subtle gradient overlay for depth
            gradient: LinearGradient(
              colors: [
                (isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.08),
                Colors.transparent,
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and message
              _buildHeader(isSuccess),
              
              if (data != null) ...[
                const SizedBox(height: 24),
                _buildDivider(),
                const SizedBox(height: 24),
                
                // Member info section
                _buildMemberInfo(data, isSuccess),
              ],

              // Error section
              if (!isSuccess && scanResult.error != null) ...[
                const SizedBox(height: 20),
                _buildErrorSection(),
              ],
            ],
          ),
        ),
      ),
    )
        .animate()
        .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 300.ms);
  }

  /// Build header with status indicator and message
  Widget _buildHeader(bool isSuccess) {
    return Row(
      children: [
        // Status indicator with pulse animation
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSuccess
                  ? [AppColors.success, AppColors.successLight]
                  : [AppColors.error, AppColors.errorLight],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.4),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Icon(
            isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
            color: Colors.white,
            size: 24,
          ),
        ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.3)),
        
        const SizedBox(width: 16),
        
        // Message
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSuccess ? 'Scan Successful' : 'Scan Failed',
                style: GoogleFonts.inter(
                  color: isSuccess ? AppColors.success : AppColors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                scanResult.message,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build elegant divider
  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.border.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  /// Build member information section
  Widget _buildMemberInfo(MemberData data, bool isSuccess) {
    return Column(
      children: [
        // Profile section with avatar and basic info
        Row(
          children: [
            _buildModernAvatar(data, isSuccess),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.memberName,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusBadge(data),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Info grid
        _buildInfoGrid(data),
      ],
    );
  }

  /// Build modern avatar with better styling
  Widget _buildModernAvatar(MemberData data, bool isSuccess) {
    final borderGradient = LinearGradient(
      colors: isSuccess 
          ? [AppColors.success, AppColors.successLight]
          : [AppColors.error, AppColors.errorLight],
    );

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: borderGradient,
        boxShadow: [
          BoxShadow(
            color: (isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3), // Use margin instead of padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: AppColors.surface,
        ),
        child: data.hasAvatar
            ? ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: CachedNetworkImage(
                  imageUrl: data.avatarUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: AppColors.surface,
                    highlightColor: AppColors.primary.withValues(alpha: 0.3),
                    child: Container(color: AppColors.surface),
                  ),
                  errorWidget: (context, url, error) => _buildFallbackAvatar(data),
                ),
              )
            : _buildFallbackAvatar(data),
      ),
    );
  }

  /// Build fallback avatar with initials
  Widget _buildFallbackAvatar(MemberData data) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        gradient: AppColors.primaryGradient,
      ),
      child: Center(
        child: Text(
          data.initials,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Build modern status badge
  Widget _buildStatusBadge(MemberData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.isActive
              ? [AppColors.success.withValues(alpha: 0.2), AppColors.successLight.withValues(alpha: 0.1)]
              : [AppColors.error.withValues(alpha: 0.2), AppColors.errorLight.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: data.isActive ? AppColors.success : AppColors.error,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.isActive ? AppColors.success : AppColors.error,
              boxShadow: [
                BoxShadow(
                  color: (data.isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            data.membershipStatus.toUpperCase(),
            style: GoogleFonts.inter(
              color: data.isActive ? AppColors.success : AppColors.error,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Build information grid with modern cards
  Widget _buildInfoGrid(MemberData data) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.card_membership_rounded,
            label: 'Plan',
            value: data.planName,
            gradient: AppColors.primaryGradient,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.calendar_today_rounded,
            label: 'Expires',
            value: data.formattedExpiryDate,
            gradient: AppColors.accentGradient,
          ),
        ),
      ],
    );
  }

  /// Build individual info card
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface.withValues(alpha: 0.8),
            AppColors.surface.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  /// Build error section
  Widget _buildErrorSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.error.withValues(alpha: 0.1),
            AppColors.errorLight.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              scanResult.error ?? 'Unknown error occurred',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



