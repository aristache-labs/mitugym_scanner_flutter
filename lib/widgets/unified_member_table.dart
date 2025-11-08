import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config/app_colors.dart';
import '../models/member_data.dart';
import 'member_avatar_modal.dart';
import 'member_details_modal.dart';

/// Unified table widget for displaying members with consistent design
class UnifiedMemberTable extends StatelessWidget {
  final List<MemberData> members;
  final String sortBy;
  final bool sortAscending;
  final Function(String) onSort;
  final bool showHeader;

  const UnifiedMemberTable({
    super.key,
    required this.members,
    required this.sortBy,
    required this.sortAscending,
    required this.onSort,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          _buildTableHeader(),
        ],
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: members.length,
            itemBuilder: (context, index) {
              return _buildMemberRow(members[index], context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
          left: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
          right: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Member column
          SizedBox(
            width: 200,
            child: _buildSortableHeader(
              'MEMBER',
              'member',
              padding: const EdgeInsets.only(
                left: 56,
                right: 4,
                top: 6,
                bottom: 6,
              ),
            ),
          ),
          
          const SizedBox(width: 20),
          
          // Plan column
          Expanded(
            flex: 3,
            child: _buildSortableHeader(
              'PLAN',
              'plan',
              padding: const EdgeInsets.only(
                left: 170,
                right: 4,
                top: 6,
                bottom: 6,
              ),
            ),
          ),
          
          const SizedBox(width: 20),
          
          // Expires column
          Expanded(
            flex: 2,
            child: _buildSortableHeader(
              'EXPIRES',
              'expires',
              padding: const EdgeInsets.only(
                left: 2,
                right: 4,
                top: 6,
                bottom: 6,
              ),
            ),
          ),
          
          const SizedBox(width: 20),
          
          // Status column
          SizedBox(
            width: 120,
            child: _buildSortableHeader(
              'STATUS',
              'status',
              padding: const EdgeInsets.only(
                left: 8,
                right: 4,
                top: 6,
                bottom: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortableHeader(String label, String sortKey, {required EdgeInsets padding}) {
    final isActive = sortBy == sortKey;
    
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => onSort(sortKey),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: isActive ? AppColors.primary : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isActive
                    ? (sortAscending ? LucideIcons.arrowUp : LucideIcons.arrowDown)
                    : LucideIcons.arrowUpDown,
                size: 14,
                color: isActive ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberRow(MemberData member, BuildContext context) {
    final statusColor = _getStatusColor(member.membershipStatus);
    final isActive = member.membershipStatus.toLowerCase() == 'active';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.7),
            AppColors.surface.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => MemberDetailsModal.show(context, member: member),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Member column (with avatar)
                SizedBox(
                  width: 200,
                  child: Row(
                    children: [
                      // Avatar (clickable to expand)
                      GestureDetector(
                        onTap: () {
                          MemberAvatarModal.show(
                            context,
                            avatarUrl: member.avatarUrl,
                            memberName: member.memberName,
                            memberId: member.memberId,
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: member.hasAvatar ? null : AppColors.primaryGradient,
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Member name
                      Expanded(
                        child: Text(
                          member.memberName,
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Plan column
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 150),
                    child: Text(
                      member.planName,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Expires column
                Expanded(
                  flex: 2,
                  child: Text(
                    member.formattedExpiryDate,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Status column
                SizedBox(
                  width: 120,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isActive ? LucideIcons.checkCircle : LucideIcons.xCircle,
                          size: 12,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            member.membershipStatus.toUpperCase(),
                            style: GoogleFonts.inter(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'expired':
        return AppColors.error;
      case 'inactive':
        return AppColors.warning;
      default:
        return AppColors.muted;
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
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
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              LucideIcons.users,
              size: 48,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No members to display',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

