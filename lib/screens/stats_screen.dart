import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_colors.dart';
import '../providers/scan_provider.dart';

/// Modern statistics screen - Dashboard style
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
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 3.0,
            colors: [
              const Color(0xFF1E293B).withValues(alpha: 0.8),
              const Color(0xFF0F172A),
              const Color(0xFF0A0E1A),
            ],
          ),
          color: AppColors.background,
        ),
        child: Column(
          children: [
            // Modern app bar
            _buildModernAppBar(context),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 24),
                    
                    // Main stats grid
                    _buildStatsGrid(totalScans, todayCount, successfulScans, failedScans, todaySuccess, successRate),
                    const SizedBox(height: 24),
                    
                    // Success rate section
                    _buildSuccessRateSection(successRate, successfulScans, failedScans),
                    const SizedBox(height: 24),
                    
                    // Insights section
                    _buildInsightsSection(todayCount, totalScans, successRate),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build modern app bar
  Widget _buildModernAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.9),
            AppColors.accent.withValues(alpha: 0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistics',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Performance analytics',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: -0.3, duration: 400.ms, curve: Curves.easeOut);
  }

  /// Build header section
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Overview',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor your scanning performance and trends',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().slideX(begin: 0.1, duration: 300.ms, curve: Curves.easeOut);
  }

  /// Build stats grid
  Widget _buildStatsGrid(int totalScans, int todayCount, int successfulScans, int failedScans, int todaySuccess, double successRate) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          icon: Icons.qr_code_scanner_rounded,
          label: 'Total Scans',
          value: totalScans.toString(),
          gradient: AppColors.primaryGradient,
          trend: null,
        ).animate(delay: 100.ms).slideY(begin: 0.2, duration: 300.ms),
        
        _buildStatCard(
          icon: Icons.today_rounded,
          label: 'Today',
          value: todayCount.toString(),
          gradient: AppColors.accentGradient,
          trend: todaySuccess > 0 ? '+$todaySuccess' : null,
        ).animate(delay: 200.ms).slideY(begin: 0.2, duration: 300.ms),
        
        _buildStatCard(
          icon: Icons.check_circle_rounded,
          label: 'Successful',
          value: successfulScans.toString(),
          gradient: AppColors.successGradient,
          trend: '${successRate.toStringAsFixed(0)}%',
        ).animate(delay: 300.ms).slideY(begin: 0.2, duration: 300.ms),
        
        _buildStatCard(
          icon: Icons.error_rounded,
          label: 'Failed',
          value: failedScans.toString(),
          gradient: AppColors.errorGradient,
          trend: null,
        ).animate(delay: 400.ms).slideY(begin: 0.2, duration: 300.ms),
      ],
    );
  }

  /// Build modern stat card
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required LinearGradient gradient,
    String? trend,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.9),
            AppColors.surface.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradient.colors.first.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradient.colors.first.withValues(alpha: 0.08),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trend,
                      style: GoogleFonts.inter(
                        color: Colors.white,
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
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
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
