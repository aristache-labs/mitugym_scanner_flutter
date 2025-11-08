import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_colors.dart';
import '../models/activity_log.dart';
import 'member_avatar_modal.dart';
import 'member_details_modal.dart';

/// Unified table widget for displaying activity logs with consistent design
class UnifiedActivityTable extends StatelessWidget {
  final List<ActivityLog> activities;
  final String sortBy;
  final bool sortAscending;
  final Function(String) onSort;
  final String title;
  final bool showHeader;

  const UnifiedActivityTable({
    super.key,
    required this.activities,
    required this.sortBy,
    required this.sortAscending,
    required this.onSort,
    this.title = 'Activity',
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          _buildTableHeader(),
          const SizedBox(height: 1),
        ],
        ...activities.asMap().entries.map((entry) => 
          _buildActivityRow(entry.value, context, isFirst: entry.key == 0 && !showHeader)),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Member column
          SizedBox(
            width: 220,
            child: _buildSortableHeader('MEMBER', 'member'),
          ),
          
          // Checked In column
          Expanded(
            flex: 2,
            child: _buildSortableHeader('CHECKED IN', 'checkIn'),
          ),
          
          // Checked Out column
          Expanded(
            flex: 2,
            child: _buildSortableHeader('CHECKED OUT', 'checkOut'),
          ),
          
          // Duration column
          SizedBox(
            width: 160,
            child: _buildSortableHeader('DURATION', 'duration'),
          ),
        ],
      ),
    );
  }

  Widget _buildSortableHeader(String label, String sortKey) {
    final isActive = sortBy == sortKey;
    
    return InkWell(
      onTap: () => onSort(sortKey),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
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
    );
  }

  Widget _buildActivityRow(ActivityLog activity, BuildContext context, {bool isFirst = false}) {
    final isSuccess = activity.success;
    final statusColor = isSuccess ? AppColors.success : AppColors.error;
    
    final card = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.7),
            AppColors.surface.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: isFirst 
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            )
          : BorderRadius.circular(8),
        border: isFirst
          ? Border(
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
            )
          : Border.all(
              color: AppColors.border.withValues(alpha: 0.3),
              width: 1,
            ),
      ),
      child: Row(
        children: [
          // Member column (avatar + name)
          SizedBox(
            width: 200,
            child: Row(
              children: [
                // Avatar with status indicator
                GestureDetector(
                  onTap: () {
                    MemberAvatarModal.show(
                      context,
                      avatarUrl: activity.avatarUrl,
                      memberName: activity.memberName,
                      memberId: activity.memberId,
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: activity.hasAvatar ? null : AppColors.primaryGradient,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          image: activity.hasAvatar
                              ? DecorationImage(
                                  image: NetworkImage(activity.avatarUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: activity.hasAvatar
                            ? null
                            : Center(
                                child: Text(
                                  activity.initials,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                            border: Border.all(
                              color: AppColors.card,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (activity.memberData != null) {
                        MemberDetailsModal.show(context, member: activity.memberData!);
                      }
                    },
                    child: Text(
                      activity.memberName,
                      style: GoogleFonts.inter(
                        color: activity.memberData != null 
                            ? AppColors.primary 
                            : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 10),
          
          // Checked In column
          Expanded(
            flex: 3,
            child: _buildCheckInCell(activity),
          ),
          
          const SizedBox(width: 10),
          
          // Checked Out column
          Expanded(
            flex: 2,
            child: _buildCheckOutCell(activity),
          ),
          
          const SizedBox(width: 10),
          
          // Duration column
          SizedBox(
            width: 120,
            child: _buildDurationCell(activity),
          ),
        ],
      ),
    );
    
    // If this is the first card after a header, shift it up to connect seamlessly
    if (isFirst) {
      return Transform.translate(
        offset: const Offset(0, -1),
        child: card,
      );
    }
    
    return card;
  }

  Widget _buildCheckInCell(ActivityLog activity) {
    if (activity.checkInTime != null) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: DateFormat('h:mm a').format(activity.checkInTime!),
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' - ',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                TextSpan(
                  text: DateFormat('MMM d, yyyy').format(activity.checkInTime!),
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (!activity.success) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.xCircle,
                size: 13,
                color: AppColors.error,
              ),
              const SizedBox(width: 5),
              Text(
                'Plan Expired',
                style: GoogleFonts.inter(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Text(
      '--',
      style: GoogleFonts.inter(
        color: AppColors.textMuted,
        fontSize: 13,
      ),
    );
  }

  Widget _buildCheckOutCell(ActivityLog activity) {
    if (activity.checkOutTime != null) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: DateFormat('h:mm a').format(activity.checkOutTime!),
                  style: GoogleFonts.inter(
                    color: AppColors.warning,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' - ',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                TextSpan(
                  text: DateFormat('MMM d, yyyy').format(activity.checkOutTime!),
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (!activity.success) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.shieldAlert,
                size: 13,
                color: AppColors.error,
              ),
              const SizedBox(width: 5),
              Text(
                'Access Denied',
                style: GoogleFonts.inter(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (activity.checkInTime != null) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.dumbbell,
                size: 13,
                color: AppColors.success,
              ),
              const SizedBox(width: 5),
              Text(
                'Still in GYM',
                style: GoogleFonts.inter(
                  color: AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )
          .animate(onPlay: (controller) => controller.repeat())
          .fadeIn(duration: 800.ms, curve: Curves.easeInOut)
          .then()
          .fadeOut(duration: 800.ms, curve: Curves.easeInOut),
      );
    }
    
    return Text(
      '--',
      style: GoogleFonts.inter(
        color: AppColors.textMuted,
        fontSize: 13,
      ),
    );
  }

  Widget _buildDurationCell(ActivityLog activity) {
    if (activity.checkInTime != null && activity.checkOutTime != null) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            activity.formattedDuration,
            style: GoogleFonts.inter(
              color: AppColors.success,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    
    if (activity.checkInTime != null && activity.checkOutTime == null) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.trendingUp,
                size: 13,
                color: AppColors.warning,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Active Session',
                  style: GoogleFonts.inter(
                    color: AppColors.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Text(
      '--',
      style: GoogleFonts.inter(
        color: AppColors.textMuted,
        fontSize: 13,
      ),
    );
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
        child: Text(
          'No activity to display',
          style: GoogleFonts.inter(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

