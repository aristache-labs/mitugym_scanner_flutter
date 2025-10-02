import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_colors.dart';
import '../providers/scan_provider.dart';

/// Statistics and dashboard screen
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);
    final activities = scanState.recentActivity;

    // Calculate statistics
    final totalScans = activities.length;
    final successfulScans = activities.where((a) => a.success).length;
    final failedScans = activities.where((a) => a.success == false).length;
    final successRate = totalScans > 0 ? (successfulScans / totalScans * 100) : 0.0;

    // Get today's scans
    final today = DateTime.now();
    final todayScans = activities.where((a) {
      return a.time.year == today.year &&
          a.time.month == today.month &&
          a.time.day == today.day;
    }).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: AppColors.getBackgroundDecoration(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Text(
              'Activity Overview',
              style: Theme.of(context).textTheme.displayMedium,
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideX(begin: -0.1, duration: 400.ms),
            
            const SizedBox(height: 8),
            
            Text(
              'Real-time scanning statistics',
              style: Theme.of(context).textTheme.bodyMedium,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms),

            const SizedBox(height: 24),

            // Stats cards grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  title: 'Total Scans',
                  value: totalScans.toString(),
                  icon: Icons.qr_code_scanner,
                  gradient: AppColors.primaryGradient,
                  index: 0,
                ),
                _StatCard(
                  title: 'Today',
                  value: todayScans.toString(),
                  icon: Icons.today,
                  gradient: AppColors.primaryGradient,
                  index: 1,
                ),
                _StatCard(
                  title: 'Successful',
                  value: successfulScans.toString(),
                  icon: Icons.check_circle,
                  gradient: AppColors.successGradient,
                  index: 2,
                ),
                _StatCard(
                  title: 'Failed',
                  value: failedScans.toString(),
                  icon: Icons.error,
                  gradient: AppColors.errorGradient,
                  index: 3,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Success rate card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: AppColors.success,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Success Rate',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: successRate / 100,
                        minHeight: 12,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          successRate >= 80 ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Text(
                      '${successRate.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: successRate >= 80 ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideY(begin: 0.1, duration: 400.ms, delay: 400.ms),

            const SizedBox(height: 24),

            // Recent activity header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () {
                    ref.read(scanProvider.notifier).clearActivity();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Activity cleared'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear All'),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 500.ms),

            const SizedBox(height: 12),

            // Activity list
            if (activities.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: AppColors.muted.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No activity yet',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...activities.asMap().entries.map((entry) {
                final index = entry.key;
                final activity = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: activity.success
                          ? AppColors.success.withValues(alpha: 0.2)
                          : AppColors.error.withValues(alpha: 0.2),
                      child: Icon(
                        activity.success ? Icons.check : Icons.close,
                        color: activity.success ? AppColors.success : AppColors.error,
                      ),
                    ),
                    title: Text(
                      activity.memberName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${activity.action} • ${activity.formattedTime}',
                      style: TextStyle(color: AppColors.muted),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.muted,
                    ),
                  ),
                )
                    .animate(delay: (index * 50).ms)
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: -0.1, duration: 300.ms);
              }),
          ],
        ),
      ),
    );
  }
}

/// Individual stat card widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final int index;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradient.colors.first.withValues(alpha: 0.1),
              gradient.colors.last.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Icon(
                  icon,
                  color: gradient.colors.first,
                  size: 24,
                ),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: gradient.colors.first,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: (index * 100).ms)
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.easeOut);
  }
}

