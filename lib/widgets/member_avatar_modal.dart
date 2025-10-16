import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

/// Modal popup to show expanded member avatar
class MemberAvatarModal {
  static void show(BuildContext context, {
    required String? avatarUrl,
    required String memberName,
    String? memberId,
    String? planName,
    String? expiresAt,
    String? membershipStatus,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: _MemberAvatarModalContent(
          avatarUrl: avatarUrl,
          memberName: memberName,
          memberId: memberId,
          planName: planName,
          expiresAt: expiresAt,
          membershipStatus: membershipStatus,
        ),
      ),
    );
  }
}

class _MemberAvatarModalContent extends StatelessWidget {
  final String? avatarUrl;
  final String memberName;
  final String? memberId;
  final String? planName;
  final String? expiresAt;
  final String? membershipStatus;

  const _MemberAvatarModalContent({
    required this.avatarUrl,
    required this.memberName,
    this.memberId,
    this.planName,
    this.expiresAt,
    this.membershipStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with member name and close button
          Row(
            children: [
              // Spacer for balance (same width as close button)
              const SizedBox(width: 48),
              // Member name (centered)
              Expanded(
                child: Text(
                  memberName,
                  style: GoogleFonts.inter(
                    color: AppColors.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Close button
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.text,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Avatar image (centered)
          Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? Image.network(
                      avatarUrl!,
                      width: 400,
                      height: 400,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar(400);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 400,
                          height: 400,
                          color: AppColors.background,
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),
                        );
                      },
                    )
                  : _buildDefaultAvatar(400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.3),
            AppColors.primary.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Center(
        child: Text(
          memberName.isNotEmpty ? memberName[0].toUpperCase() : '?',
          style: GoogleFonts.inter(
            color: AppColors.primary,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

