import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_colors.dart';
import '../models/member_data.dart';
import '../providers/config_provider.dart';
import '../l10n/app_localizations.dart';
import 'member_avatar_modal.dart';

/// Modal dialog to show full member details
class MemberDetailsModal {
  static void show(BuildContext context, {
    required MemberData member,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: _MemberDetailsModalContent(member: member),
      ),
    );
  }
}

class _MemberDetailsModalContent extends ConsumerWidget {
  final MemberData member;

  const _MemberDetailsModalContent({required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _getStatusColor(member.membershipStatus);
    final isActive = member.isActive;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        maxWidth: 600,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface.withValues(alpha: 0.98),
            AppColors.card.withValues(alpha: 0.98),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
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
                            l10n.tapToEnlarge,
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
                    _translateStatus(member.membershipStatus, l10n).toUpperCase(),
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
            
            // Two-column layout for details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT COLUMN: Membership Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.membership,
                        style: GoogleFonts.inter(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCompactDetailRow(context, Icons.card_membership_rounded, l10n.planLabel, member.planName),
                      const SizedBox(height: 8),
                      _buildCompactDetailRow(context, Icons.calendar_today_rounded, l10n.expiresLabel, member.formattedExpiryDate),
                      if (member.dateOfBirth != null) ...[
                        const SizedBox(height: 8),
                        _buildCompactDetailRow(context, Icons.cake_rounded, l10n.birthDateLabel, member.formattedBirthDate ?? member.dateOfBirth!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // RIGHT COLUMN: Contact & Address
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.contactAndAddress,
                        style: GoogleFonts.inter(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (member.email != null) ...[
                        _buildCompactDetailRow(context, Icons.email_rounded, l10n.emailLabel, member.email!),
                        const SizedBox(height: 8),
                      ],
                      if (member.phone != null) ...[
                        _buildCompactDetailRow(context, Icons.phone_rounded, l10n.phoneLabel, member.phone!),
                        const SizedBox(height: 8),
                      ],
                      if (member.hasAddressDetails) ...[
                        _buildCompactDetailRow(
                          context,
                          Icons.location_on_rounded, 
                          l10n.addressLabel, 
                          _buildAddressString(context, member),
                        ),
                      ],
                      // Show placeholder if no contact/address info
                      if (!member.hasContactDetails && !member.hasAddressDetails)
                        Text(
                          l10n.noContactInformation,
                          style: GoogleFonts.inter(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 28),
            
            // View Full Profile button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openMemberProfile(context, ref, member.memberId),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(
                  l10n.viewFullProfile,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  foregroundColor: AppColors.primary.withValues(alpha: 0.95),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: Text(
                    l10n.close,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.error.withValues(alpha: 0.08),
                    foregroundColor: AppColors.error.withValues(alpha: 0.9),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  void _openMemberProfile(BuildContext context, WidgetRef ref, String memberId) async {
    // Get the API URL from settings and derive the web panel URL
    final config = ref.read(configProvider);
    final apiUrl = config.apiUrl;
    
    // Extract base URL from API URL (remove /api/checkin or /api/history etc.)
    String webPanelUrl;
    if (apiUrl.contains('/api/')) {
      // Remove everything from /api/ onwards
      webPanelUrl = apiUrl.substring(0, apiUrl.indexOf('/api/'));
    } else {
      // If no /api/ found, use the URL as is
      webPanelUrl = apiUrl;
    }
    
    final profileUrl = Uri.parse('$webPanelUrl/members/$memberId/view');
    
    try {
      if (await canLaunchUrl(profileUrl)) {
        await launchUrl(profileUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.couldNotOpenProfile(profileUrl.toString())),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOpeningProfile(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildCompactDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildAddressString(BuildContext context, MemberData member) {
    final l10n = AppLocalizations.of(context)!;
    final parts = <String>[];
    if (member.address != null && member.address!.isNotEmpty) {
      parts.add(member.address!);
    }
    if (member.city != null && member.city!.isNotEmpty) {
      parts.add(member.city!);
    }
    if (member.county != null && member.county!.isNotEmpty) {
      parts.add(member.county!);
    }
    return parts.isEmpty ? l10n.notProvided : parts.join(', ');
  }
  
  String _translateStatus(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'active':
        return l10n.active;
      case 'inactive':
        return l10n.inactive;
      case 'expired':
        return l10n.expired;
      case 'pending':
        return l10n.pending;
      default:
        return status;
    }
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

