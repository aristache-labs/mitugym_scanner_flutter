import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/activity_log.dart';

/// Activity list widget
/// Displays recent check-in/check-out activity
class ActivityListWidget extends StatelessWidget {
  final List<ActivityLog> activities;

  const ActivityListWidget({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Colors.white38,
            ),
            const SizedBox(height: 12),
            Text(
              'No recent activity',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Recent Activity',
            style: theme.textTheme.titleLarge,
          ),
        ),

        // Activity list
        Expanded(
          child: ListView.builder(
            itemCount: activities.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return _buildActivityItem(activity, index, theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(ActivityLog activity, int index, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: activity.success
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.2),
          child: Icon(
            activity.success ? Icons.check : Icons.close,
            color: activity.success ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          activity.memberName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          activity.action,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        trailing: Text(
          activity.formattedTime,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white54,
          ),
        ),
      ),
    )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: -0.1, duration: 300.ms, curve: Curves.easeOut);
  }
}

