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
        // More subtle background with dark base
        color: isSuccess ? AppColors.card : AppColors.card,
        border: Border.all(
          color: isSuccess ? AppColors.success : AppColors.error,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        // Subtle gradient overlay
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.08),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSuccess ? Icons.check_circle : Icons.error,
                      color: isSuccess ? AppColors.success : AppColors.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    scanResult.message,
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // Member details (show if we have member data)
            if (data != null) ...[
              const SizedBox(height: 16),
              const Divider(color: Colors.white54),
              const SizedBox(height: 12),

              // Member name
              _buildInfoRow(
                icon: Icons.person,
                label: 'Member',
                value: data.memberName,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),

              // Plan name
              _buildInfoRow(
                icon: Icons.card_membership,
                label: 'Plan',
                value: data.planName,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),

              // Expiry date
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Expires',
                value: data.formattedExpiryDate,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),

              // Status badge
              Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.muted, size: 18),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: data.isActive
                          ? AppColors.success.withValues(alpha: 0.2)
                          : AppColors.error.withValues(alpha: 0.2),
                      border: Border.all(
                        color: data.isActive ? AppColors.success : AppColors.error,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data.membershipStatus.toUpperCase(),
                      style: TextStyle(
                        color: data.isActive ? AppColors.success : AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}



