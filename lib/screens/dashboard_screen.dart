import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config/app_colors.dart';
import '../providers/history_provider.dart';
import '../widgets/member_avatar_modal.dart';
import '../widgets/member_details_modal.dart';

/// Dashboard screen - Overview and quick stats
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _sortBy = ''; // No default sorting - clean state
  bool _sortAscending = true;

  void _toggleSort(String sortKey) {
    setState(() {
      if (_sortBy == sortKey) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = sortKey;
        _sortAscending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats overview
          _buildStatsOverview(historyState),
          const SizedBox(height: 16),
          
          // Recent activity
          _buildRecentActivity(historyState, context),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(HistoryState historyState) {
    // Filter for today's activities from the full history
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    final todayActivities = historyState.items.where((a) => 
        a.time.isAfter(todayStart) && a.time.isBefore(todayEnd));
    
    final totalScans = todayActivities.length;
    
    // Count check-ins: activities with checkInTime set and successful
    final checkIns = todayActivities
        .where((a) => a.success && a.checkInTime != null)
        .length;
    
    // Count check-outs: activities with checkOutTime set and successful
    final checkOuts = todayActivities
        .where((a) => a.success && a.checkOutTime != null)
        .length;
    
    final denied = todayActivities
        .where((a) => !a.success)
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildPremiumStatCard(
            'Total Scans',
            '$totalScans',
            LucideIcons.scanLine,
            AppColors.primary,
            'All scans today',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPremiumStatCard(
            'Check-ins',
            '$checkIns',
            LucideIcons.userCheck,
            AppColors.success,
            'Successful entries',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPremiumStatCard(
            'Check-outs',
            '$checkOuts',
            LucideIcons.userMinus,
            AppColors.warning,
            'Successful exits',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPremiumStatCard(
            'Denied',
            '$denied',
            LucideIcons.userX,
            AppColors.error,
            'Failed scans',
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String subtitle,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top header with gradient and centered icon
          Container(
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.18),
                  const Color(0xFF0D0D0D).withValues(alpha: 0.9),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: color.withValues(alpha: 0.16),
                  width: 1,
                ),
              ),
            ),
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D0D),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.35),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
            ),
          ),
          
          // Body with value and label
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.firaCode(
                    color: AppColors.textPrimary,
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.firaCode(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        color.withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(HistoryState historyState, BuildContext context) {
    // Get only today's activities (matching check-ins page)
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    var recentActivities = historyState.items
        .where((a) => a.time.isAfter(todayStart) && a.time.isBefore(todayEnd))
        .take(10)
        .toList();
    
    // Apply sorting
    final sortedActivities = _applySorting(recentActivities);

    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Activity',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (sortedActivities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'No activity today',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else ...[
            _buildActivityTableHeader(),
            ...sortedActivities.map((activity) => _buildActivityItem(activity, context)),
          ],
        ],
      ),
    );
  }

  /// Build activity table header (matching history page) with sorting
  Widget _buildActivityTableHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Member column (with avatar space)
          SizedBox(
            width: 200,
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
            width: 120,
            child: _buildSortableHeader('DURATION', 'duration'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSortableHeader(String label, String sortKey) {
    final isActive = _sortBy == sortKey;
    
    return InkWell(
      onTap: () => _toggleSort(sortKey),
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
                  ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                  : Icons.unfold_more,
              size: 14,
              color: isActive ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
  
  List<dynamic> _applySorting(List<dynamic> activities) {
    // If no sort is selected, return original order
    if (_sortBy.isEmpty) {
      return activities;
    }
    
    final sorted = List<dynamic>.from(activities);
    
    sorted.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'member':
          comparison = a.memberName.toLowerCase().compareTo(b.memberName.toLowerCase());
          break;
        case 'checkIn':
          final aTime = a.checkInTime ?? a.time;
          final bTime = b.checkInTime ?? b.time;
          comparison = aTime.compareTo(bTime);
          break;
        case 'checkOut':
          final aTime = a.checkOutTime ?? DateTime(2099);
          final bTime = b.checkOutTime ?? DateTime(2099);
          comparison = aTime.compareTo(bTime);
          break;
        case 'duration':
          final aDuration = a.durationMinutes ?? 0;
          final bDuration = b.durationMinutes ?? 0;
          comparison = aDuration.compareTo(bDuration);
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });
    
    return sorted;
  }

  /// Build activity item (matching history page layout)
  Widget _buildActivityItem(dynamic activity, BuildContext context) {
    final isSuccess = activity.success;
    final statusColor = isSuccess ? AppColors.success : AppColors.error;
    
    return Container(
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
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
                // Avatar with status indicator (clickable)
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
                      // Show member details modal if member data is available
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
          
          // Checked In column
          Expanded(
            flex: 2,
            child: activity.checkInTime != null
                ? Align(
                    alignment: Alignment.centerLeft,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('MMM d, yyyy').format(activity.checkInTime!),
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('h:mm a').format(activity.checkInTime!),
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : !activity.success
                    ? Align(
                        alignment: Alignment.centerLeft,
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
                                Icons.cancel_outlined,
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
                      )
                    : Text(
                        '--',
                        style: GoogleFonts.inter(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
          ),
          
          // Checked Out column
          Expanded(
            flex: 2,
            child: activity.checkOutTime != null
                ? Align(
                    alignment: Alignment.centerLeft,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('MMM d, yyyy').format(activity.checkOutTime!),
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('h:mm a').format(activity.checkOutTime!),
                            style: GoogleFonts.inter(
                              color: AppColors.warning,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                    : !activity.success
                        ? Align(
                            alignment: Alignment.centerLeft,
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
                                    Icons.block_rounded,
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
                          )
                        : activity.checkInTime != null
                            ? Align(
                                alignment: Alignment.centerLeft,
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
                                        Icons.fitness_center_rounded,
                                        size: 13,
                                        color: AppColors.success,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Active Session',
                                        style: GoogleFonts.inter(
                                          color: AppColors.success,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Text(
                                '--',
                                style: GoogleFonts.inter(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                ),
                              ),
          ),
          
          // Duration column
          SizedBox(
            width: 120,
            child: activity.checkInTime != null && activity.checkOutTime != null
                ? Align(
                    alignment: Alignment.centerLeft,
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
                  )
                : activity.checkInTime != null && activity.checkOutTime == null
                    ? Align(
                        alignment: Alignment.centerLeft,
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
                                Icons.access_time_rounded,
                                size: 13,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'In Progress',
                                style: GoogleFonts.inter(
                                  color: AppColors.warning,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Text(
                            '--',
                            style: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

