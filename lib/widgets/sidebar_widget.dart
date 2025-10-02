import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:badges/badges.dart' as badges;
import '../config/app_themes.dart';
import '../providers/scan_provider.dart';
import '../providers/offline_provider.dart';
import '../models/activity_log.dart';

/// Premium sidebar widget with stats, activity, search, and quick actions
class SidebarWidget extends ConsumerStatefulWidget {
  final AppThemeColors themeColors;
  final VoidCallback onExport;
  final VoidCallback onSettings;
  final VoidCallback onStats;
  final VoidCallback onSearch;
  final VoidCallback onHistory;

  const SidebarWidget({
    super.key,
    required this.themeColors,
    required this.onExport,
    required this.onSettings,
    required this.onStats,
    required this.onSearch,
    required this.onHistory,
  });

  @override
  ConsumerState<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends ConsumerState<SidebarWidget> {
  bool _statsExpanded = true;
  bool _activityExpanded = true;
  bool _actionsExpanded = true;

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);
    final offlineState = ref.watch(offlineProvider);

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: widget.themeColors.surface,
        border: Border(
          right: BorderSide(
            color: widget.themeColors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(offlineState),
          
          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Quick Stats
                _buildQuickStats(scanState),
                const SizedBox(height: 16),
                
                // Recent Activity
                _buildRecentActivity(scanState),
                const SizedBox(height: 16),
                
                // Quick Actions
                _buildQuickActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build header with logo and status
  Widget _buildHeader(OfflineState offlineState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: widget.themeColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: widget.themeColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo/Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppThemeColors.radiusMedium),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MituGym',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: offlineState.isOnline
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.red.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: offlineState.isOnline
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: offlineState.isOnline
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          boxShadow: [
                            BoxShadow(
                              color: (offlineState.isOnline
                                      ? Colors.greenAccent
                                      : Colors.redAccent)
                                  .withValues(alpha: 0.6),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        offlineState.isOnline ? 'Online' : 'Offline',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Sync badge
          if (offlineState.pendingSyncCount > 0)
            badges.Badge(
              badgeContent: Text(
                '${offlineState.pendingSyncCount}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              badgeStyle: badges.BadgeStyle(
                badgeColor: widget.themeColors.warning,
              ),
              child: IconButton(
                icon: const Icon(Icons.sync, color: Colors.white),
                onPressed: () {
                  ref.read(offlineProvider.notifier).manualSync();
                },
              ),
            ),
        ],
      ),
    );
  }

  /// Build quick stats card
  Widget _buildQuickStats(ScanState scanState) {
    final todayCheckIns = scanState.recentActivity
        .where((a) => a.time.day == DateTime.now().day)
        .length;
    final successfulToday = scanState.recentActivity
        .where((a) => a.time.day == DateTime.now().day && a.success)
        .length;

    return _buildSection(
      title: 'Today\'s Stats',
      icon: Icons.bar_chart,
      isExpanded: _statsExpanded,
      onToggle: () => setState(() => _statsExpanded = !_statsExpanded),
      child: Column(
        children: [
          _buildStatRow(
            icon: Icons.check_circle,
            label: 'Check-ins',
            value: '$successfulToday',
            color: widget.themeColors.success,
          ),
          const SizedBox(height: 8),
          _buildStatRow(
            icon: Icons.timeline,
            label: 'Total Scans',
            value: '$todayCheckIns',
            color: widget.themeColors.primary,
          ),
          const SizedBox(height: 8),
          _buildStatRow(
            icon: Icons.error_outline,
            label: 'Errors',
            value: '${todayCheckIns - successfulToday}',
            color: widget.themeColors.error,
          ),
        ],
      ),
    );
  }

  /// Build recent activity list
  Widget _buildRecentActivity(ScanState scanState) {
    final recentActivities = scanState.recentActivity.take(8).toList();

    return _buildSection(
      title: 'Recent Activity',
      icon: Icons.history,
      isExpanded: _activityExpanded,
      onToggle: () => setState(() => _activityExpanded = !_activityExpanded),
      child: recentActivities.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No recent activity',
                  style: TextStyle(color: widget.themeColors.muted),
                ),
              ),
            )
          : Column(
              children: recentActivities.map((activity) {
                return _buildActivityItem(activity);
              }).toList(),
            ),
    );
  }

  /// Build quick actions section
  Widget _buildQuickActions() {
    return _buildSection(
      title: 'Quick Actions',
      icon: Icons.flash_on,
      isExpanded: _actionsExpanded,
      onToggle: () => setState(() => _actionsExpanded = !_actionsExpanded),
      child: Column(
        children: [
          _buildActionButton(
            icon: Icons.search,
            label: 'Search Members',
            color: widget.themeColors.primary,
            onTap: widget.onSearch,
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            icon: Icons.admin_panel_settings,
            label: 'Admin Panel',
            color: widget.themeColors.accent,
            onTap: _launchAdminPanel,
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            icon: Icons.history,
            label: 'View History',
            color: widget.themeColors.secondary,
            onTap: widget.onHistory,
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            icon: Icons.download,
            label: 'Export Logs',
            color: widget.themeColors.success,
            onTap: widget.onExport,
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            icon: Icons.bar_chart,
            label: 'Statistics',
            color: widget.themeColors.warning,
            onTap: widget.onStats,
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            icon: Icons.settings,
            label: 'Settings',
            color: widget.themeColors.muted,
            onTap: widget.onSettings,
          ),
        ],
      ),
    );
  }

  /// Build collapsible section
  Widget _buildSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: widget.themeColors.card,
        borderRadius: BorderRadius.circular(AppThemeColors.radiusMedium),
        border: Border.all(
          color: widget.themeColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: widget.themeColors.cardShadowSubtle,
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppThemeColors.radiusMedium),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: widget.themeColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppThemeColors.radiusSmall),
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: widget.themeColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.themeColors.muted,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: child,
            ),
        ],
      ),
    );
  }

  /// Build stat row
  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppThemeColors.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: widget.themeColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build activity item
  Widget _buildActivityItem(ActivityLog activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.themeColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: activity.success
              ? widget.themeColors.success.withValues(alpha: 0.3)
              : widget.themeColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Avatar placeholder
          CircleAvatar(
            radius: 16,
            backgroundColor: activity.success
                ? widget.themeColors.success.withValues(alpha: 0.2)
                : widget.themeColors.error.withValues(alpha: 0.2),
            child: Text(
              activity.memberName.isNotEmpty
                  ? activity.memberName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: activity.success
                    ? widget.themeColors.success
                    : widget.themeColors.error,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.memberName,
                  style: TextStyle(
                    color: widget.themeColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  activity.action,
                  style: TextStyle(
                    color: widget.themeColors.muted,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Status icon
          Icon(
            activity.success ? Icons.check_circle : Icons.error,
            color: activity.success
                ? widget.themeColors.success
                : widget.themeColors.error,
            size: 16,
          ),
        ],
      ),
    );
  }

  /// Build action button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppThemeColors.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppThemeColors.radiusSmall),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: widget.themeColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withValues(alpha: 0.6),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  /// Launch admin panel in browser
  Future<void> _launchAdminPanel() async {
    final url = Uri.parse('https://mitugym-app-webpanel.vercel.app/');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not open admin panel'),
              backgroundColor: widget.themeColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: widget.themeColors.error,
          ),
        );
      }
    }
  }
}

