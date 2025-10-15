import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../providers/history_provider.dart';

/// Dashboard screen - Overview and quick stats
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats overview
          _buildStatsOverview(historyState),
          const SizedBox(height: 16),
          
          // Recent activity
          _buildRecentActivity(historyState),
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
    
    final checkIns = todayActivities
        .where((a) => a.success && a.action.toLowerCase().contains('in'))
        .length;
    
    final checkOuts = todayActivities
        .where((a) => a.success && !a.action.toLowerCase().contains('in'))
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
            Icons.qr_code_scanner_rounded,
            AppColors.primary,
            'All scans today',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPremiumStatCard(
            'Check-ins',
            '$checkIns',
            Icons.login_rounded,
            AppColors.success,
            'Successful entries',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPremiumStatCard(
            'Check-outs',
            '$checkOuts',
            Icons.logout_rounded,
            AppColors.warning,
            'Successful exits',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPremiumStatCard(
            'Denied',
            '$denied',
            Icons.block_rounded,
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
      padding: const EdgeInsets.all(20),
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
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with gradient background
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.8),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              // Trend indicator (optional decoration)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Value
          Text(
            value,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              height: 1.0,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          
          // Label
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          
          // Subtitle
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(HistoryState historyState) {
    // Get the 10 most recent activities from history
    final recentActivities = historyState.items.take(10).toList();

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
            'Recent Activity',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (recentActivities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'No recent activity',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else ...[
            _buildActivityTableHeader(),
            ...recentActivities.map((activity) => _buildActivityItem(activity)),
          ],
        ],
      ),
    );
  }

  /// Build activity table header (matching history page)
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
            child: Text(
              'MEMBER',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          
          // Checked In column
          Expanded(
            flex: 2,
            child: Text(
              'CHECKED IN',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          
          // Checked Out column
          Expanded(
            flex: 2,
            child: Text(
              'CHECKED OUT',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          
          // Duration column
          SizedBox(
            width: 120,
            child: Text(
              'DURATION',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build activity item (matching history page layout)
  Widget _buildActivityItem(dynamic activity) {
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
                // Avatar with status indicator
                Stack(
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
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    activity.memberName,
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
          
          // Checked In column
          Expanded(
            flex: 2,
            child: activity.checkInTime != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMM d, yyyy').format(activity.checkInTime!),
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('h:mm a').format(activity.checkInTime!),
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMM d, yyyy').format(activity.checkOutTime!),
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('h:mm a').format(activity.checkOutTime!),
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : activity.checkInTime != null
                    ? Text(
                        'Still in the GYM',
                        style: GoogleFonts.inter(
                          color: AppColors.success,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
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
            child: Text(
              activity.checkInTime != null && activity.checkOutTime == null
                  ? 'Pending'
                  : activity.formattedDuration,
              style: GoogleFonts.inter(
                color: activity.checkInTime != null && activity.checkOutTime == null
                    ? AppColors.warning
                    : AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontStyle: activity.checkInTime != null && activity.checkOutTime == null
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

