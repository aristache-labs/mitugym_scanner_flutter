import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../providers/scan_provider.dart';

/// Modern, compact statistics screen
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);
    final totalScans = scanState.recentActivity.length;
    final successfulScans = scanState.recentActivity.where((log) => log.success).length;
    final failedScans = totalScans - successfulScans;
    final successRate = totalScans > 0 ? (successfulScans / totalScans * 100) : 0.0;
    
    // Today's stats
    final now = DateTime.now();
    final todayScans = scanState.recentActivity.where((log) {
      return log.time.year == now.year &&
             log.time.month == now.month &&
             log.time.day == now.day;
    }).toList();
    final todayCount = todayScans.length;
    final todaySuccess = todayScans.where((log) => log.success).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Statistics',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main stats grid - compact 2x2
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildStatCard(
                  icon: Icons.qr_code_scanner,
                  label: 'Total Scans',
                  value: totalScans.toString(),
                  color: AppColors.primary,
                  trend: null,
                ),
                _buildStatCard(
                  icon: Icons.today,
                  label: 'Today',
                  value: todayCount.toString(),
                  color: AppColors.accent,
                  trend: todaySuccess > 0 ? '+$todaySuccess' : null,
                ),
                _buildStatCard(
                  icon: Icons.check_circle,
                  label: 'Successful',
                  value: successfulScans.toString(),
                  color: AppColors.success,
                  trend: '${successRate.toStringAsFixed(0)}%',
                ),
                _buildStatCard(
                  icon: Icons.error,
                  label: 'Failed',
                  value: failedScans.toString(),
                  color: AppColors.error,
                  trend: null,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Success rate bar
            _buildSuccessRateSection(successRate, successfulScans, failedScans),
            
            const SizedBox(height: 24),
            
            // Quick insights
            _buildInsightsSection(todayCount, totalScans, successRate),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRateSection(double rate, int success, int failed) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Success Rate',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${rate.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: rate / 100,
              minHeight: 8,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                rate >= 80 ? AppColors.success :
                rate >= 50 ? AppColors.warning :
                AppColors.error,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Legend
          Row(
            children: [
              _buildLegendItem(AppColors.success, 'Success', success.toString()),
              const SizedBox(width: 20),
              _buildLegendItem(AppColors.error, 'Failed', failed.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsSection(int todayCount, int totalScans, double successRate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.insights,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Quick Insights',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildInsightRow(
            Icons.trending_up,
            'Activity',
            todayCount > 0 ? 'Active today' : 'No activity today',
            todayCount > 0 ? AppColors.success : AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          _buildInsightRow(
            Icons.assessment,
            'Performance',
            successRate >= 80 ? 'Excellent' : successRate >= 50 ? 'Good' : 'Needs attention',
            successRate >= 80 ? AppColors.success : successRate >= 50 ? AppColors.warning : AppColors.error,
          ),
          const SizedBox(height: 12),
          _buildInsightRow(
            Icons.history,
            'Total Records',
            '$totalScans scan${totalScans != 1 ? 's' : ''} recorded',
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
