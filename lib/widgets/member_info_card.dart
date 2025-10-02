import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/scan_result.dart';
import '../models/member_data.dart';
import '../config/app_colors.dart';

/// Member info card widget
/// Displays scan result with animated gradient background
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        // Premium card background
        color: AppColors.card,
        border: Border.all(
          color: isSuccess ? AppColors.success : AppColors.error,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppColors.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: (isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          ...AppColors.cardShadow,
        ],
      ),
      child: Container(
        // Subtle gradient overlay
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppColors.radiusLarge),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon, Avatar and status
            Row(
              children: [
                // Avatar (if available)
                if (data != null) ...[
                  _buildAvatar(data, isSuccess),
                  const SizedBox(width: 12),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      isSuccess ? Icons.check_circle : Icons.error,
                      color: isSuccess ? AppColors.success : AppColors.error,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    scanResult.message,
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),

              // Member details (show if we have member data)
            if (data != null) ...[
              const SizedBox(height: 20),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.border,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Member name
              _buildInfoRow(
                icon: Icons.person,
                label: 'Member',
                value: data.memberName,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),

              // Plan name
              _buildInfoRow(
                icon: Icons.card_membership,
                label: 'Plan',
                value: data.planName,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),

              // Expiry date
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Expires',
                value: data.formattedExpiryDate,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),

              // Status badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: data.isActive
                            ? [AppColors.success, AppColors.successLight]
                            : [AppColors.error, AppColors.errorLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppColors.radiusMedium),
                      boxShadow: [
                        BoxShadow(
                          color: (data.isActive ? AppColors.success : AppColors.error)
                              .withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          data.isActive ? Icons.check_circle : Icons.error,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          data.membershipStatus.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            // Error message (only if failed and we have an error)
            if (!isSuccess && scanResult.error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  scanResult.error ?? 'Unknown error occurred',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    )
        .animate()
        .slideY(begin: 0.3, duration: 300.ms, curve: Curves.easeOut)
        .fadeIn(duration: 300.ms);
  }

  Widget _buildAvatar(MemberData data, bool isSuccess) {
    final borderColor = isSuccess ? AppColors.success : AppColors.error;
    
    if (data.hasAvatar) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 3),
        ),
        child: CachedNetworkImage(
          imageUrl: data.avatarUrl!,
          imageBuilder: (context, imageProvider) => CircleAvatar(
            radius: 40,
            backgroundImage: imageProvider,
          ),
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: AppColors.surface,
            highlightColor: AppColors.primary.withValues(alpha: 0.3),
            child: const CircleAvatar(radius: 40),
          ),
          errorWidget: (context, url, error) => _buildFallbackAvatar(data, borderColor),
        ),
      );
    } else {
      return _buildFallbackAvatar(data, borderColor);
    }
  }

  Widget _buildFallbackAvatar(MemberData data, Color borderColor) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            borderColor,
            borderColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: borderColor, width: 3),
      ),
      child: Center(
        child: Text(
          data.initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppColors.radiusSmall),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



