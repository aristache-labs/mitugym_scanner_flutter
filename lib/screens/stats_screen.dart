import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../providers/scan_provider.dart';

/// Check-ins Analytics Screen - Modern design
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);
    
    // Calculate all statistics
    final todayActivities = scanState.recentActivity
        .where((a) => a.time.day == DateTime.now().day);
    
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
    
    final successRate = totalScans > 0 
        ? ((checkIns + checkOuts) / totalScans * 100) 
        : 0.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          _buildStatsCards(totalScans, checkIns, checkOuts, denied),
          const SizedBox(height: 20),
          
          // Charts and analytics section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success rate chart
              Expanded(
                child: _buildSuccessRateCard(successRate, checkIns, checkOuts, denied),
              ),
              const SizedBox(width: 16),
              
              // Peak hours
              Expanded(
                child: _buildPeakHoursCard(todayActivities.toList()),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Recent check-ins list
          _buildRecentCheckIns(todayActivities.toList()),
        ],
      ),
    );
  }

  /// Build stats cards row
  Widget _buildStatsCards(int total, int checkIns, int checkOuts, int denied) {
    return Row(
      children: [
        Expanded(
          child: _buildCompactStatCard(
            'Total',
            '$total',
            Icons.qr_code_scanner_rounded,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCompactStatCard(
            'Check-ins',
            '$checkIns',
            Icons.login_rounded,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCompactStatCard(
            'Check-outs',
            '$checkOuts',
            Icons.logout_rounded,
            AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCompactStatCard(
            'Denied',
            '$denied',
            Icons.block_rounded,
            AppColors.error,
          ),
        ),
      ],
    );
  }

  /// Build compact stat card
  Widget _buildCompactStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.8), color],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
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

  /// Build success rate card
  Widget _buildSuccessRateCard(double rate, int checkIns, int checkOuts, int denied) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Success Rate',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${rate.toStringAsFixed(1)}%',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: rate / 100,
              minHeight: 10,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                rate >= 80 ? AppColors.success :
                rate >= 50 ? AppColors.warning :
                AppColors.error,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Stats breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Check-ins', '$checkIns', AppColors.success),
              _buildStatItem('Check-outs', '$checkOuts', AppColors.warning),
              _buildStatItem('Denied', '$denied', AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Build peak hours card
  Widget _buildPeakHoursCard(List activities) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Peak Hours',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (activities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'No data yet',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...['Morning', 'Afternoon', 'Evening'].map((time) {
              final count = _getCountByPeriod(activities, time);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      time,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$count',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  int _getCountByPeriod(List activities, String period) {
    return activities.where((a) {
      // Only count successful check-ins
      if (!a.success) return false;
      if (!a.action.toLowerCase().contains('in')) return false;
      
      final hour = a.time.hour;
      if (period == 'Morning') return hour >= 6 && hour < 12;
      if (period == 'Afternoon') return hour >= 12 && hour < 18;
      return hour >= 18 || hour < 6;
    }).length;
  }

  /// Build recent check-ins list
  Widget _buildRecentCheckIns(List activities) {
    final recent = activities.take(5).toList();
    
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
          const SizedBox(height: 16),
          
          if (recent.isEmpty)
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
          else
            ...recent.map((activity) {
              final isCheckIn = activity.action.toLowerCase().contains('in');
              final isSuccess = activity.success;
              final time = DateFormat('HH:mm').format(activity.time);
              
              // Determine badge
              String badgeLabel;
              Color badgeColor;
              
              if (!isSuccess) {
                badgeLabel = 'Denied';
                badgeColor = AppColors.error;
              } else if (isCheckIn) {
                badgeLabel = 'Check-in';
                badgeColor = AppColors.primary;
              } else {
                badgeLabel = 'Check-out';
                badgeColor = AppColors.warning;
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Avatar with status indicator
                    Stack(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: activity.success ? AppColors.success : AppColors.error,
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeLabel,
                        style: GoogleFonts.inter(
                          color: badgeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
