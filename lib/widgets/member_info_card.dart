import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/scan_result.dart';
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
        gradient: isSuccess
            ? AppColors.successGradient
            : AppColors.errorGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and status
            Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    scanResult.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // Member details (only if success)
            if (isSuccess && data != null) ...[
              const SizedBox(height: 16),
              const Divider(color: Colors.white54),
              const SizedBox(height: 12),

              // Member name
              _buildInfoRow(
                icon: Icons.person,
                label: 'Member',
                value: data.memberName,
              ),
              const SizedBox(height: 8),

              // Plan name
              _buildInfoRow(
                icon: Icons.card_membership,
                label: 'Plan',
                value: data.planName,
              ),
              const SizedBox(height: 8),

              // Expiry date
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Expires',
                value: data.formattedExpiryDate,
              ),
              const SizedBox(height: 8),

              // Status badge
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: data.isActive
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data.membershipStatus.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Error message (only if failed)
            if (!isSuccess) ...[
              const SizedBox(height: 12),
              Text(
                scanResult.error ?? 'Unknown error occurred',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

