import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../models/member_data.dart';
import 'member_avatar_modal.dart';

/// Modal bottom sheet to show full member details
class MemberDetailsModal {
  static void show(BuildContext context, {
    required MemberData member,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MemberDetailsModalContent(member: member),
    );
  }
}

class _MemberDetailsModalContent extends StatelessWidget {
  final MemberData member;

  const _MemberDetailsModalContent({required this.member});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(member.membershipStatus);
    final isActive = member.isActive;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface.withValues(alpha: 0.95),
            AppColors.card.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Avatar (large) with status - Clickable to expand
            GestureDetector(
              onTap: () {
                // Close current modal first
                Navigator.pop(context);
                // Show avatar modal
                MemberAvatarModal.show(
                  context,
                  avatarUrl: member.avatarUrl,
                  memberName: member.memberName,
                  memberId: member.memberId,
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: member.hasAvatar ? null : AppColors.primaryGradient,
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.5),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      image: member.hasAvatar
                          ? DecorationImage(
                              image: NetworkImage(member.avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: member.hasAvatar
                        ? null
                        : Center(
                            child: Text(
                              member.initials,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                        border: Border.all(
                          color: AppColors.card,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        isActive ? Icons.check_rounded : Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  // Hint overlay for clicking
                  Positioned(
                    bottom: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.zoom_in,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tap to enlarge',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Name
            Text(
              member.memberName,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    size: 16,
                    color: statusColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    member.membershipStatus.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            
            // Member ID and Plan
            _buildDetailRow(Icons.badge_rounded, 'Member ID', member.memberId),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.card_membership_rounded, 'Plan', member.planName),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.calendar_today_rounded, 'Expires', member.formattedExpiryDate),
            
            // Birth Date (if available)
            if (member.dateOfBirth != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(Icons.cake_rounded, 'Birth Date', member.formattedBirthDate ?? member.dateOfBirth!),
            ],
            
            // Contact Information Section
            if (member.hasContactDetails) ...[
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CONTACT INFORMATION',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (member.email != null)
                _buildDetailRow(Icons.email_rounded, 'Email', member.email!),
              if (member.phone != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.phone_rounded, 'Phone', member.phone!),
              ],
            ],
            
            // Address Information Section
            if (member.hasAddressDetails) ...[
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ADDRESS',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (member.address != null)
                _buildDetailRow(Icons.home_rounded, 'Street', member.address!),
              if (member.city != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.location_city_rounded, 'City', member.city!),
              ],
              if (member.county != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.map_rounded, 'County', member.county!),
              ],
            ],
            
            // Gender (if available)
            if (member.gender != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(Icons.person_outline_rounded, 'Gender', member.gender!.toUpperCase()),
            ],
            
            const SizedBox(height: 28),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Close',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'expired':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.textMuted;
    }
  }
}

