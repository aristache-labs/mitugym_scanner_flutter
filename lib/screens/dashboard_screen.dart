import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config/app_colors.dart';
import '../providers/history_provider.dart';
import '../widgets/unified_activity_table.dart';
import '../l10n/app_localizations.dart';

/// Dashboard screen - Overview and quick stats
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _sortBy = ''; // No default sorting - clean state
  bool _sortAscending = true;
  int _hoveredCardIndex = -1;

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
    
    // Get ALL today's activities (not limited)
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    var recentActivities = historyState.items
        .where((a) => a.time.isAfter(todayStart) && a.time.isBefore(todayEnd))
        .toList();
    
    // Apply sorting
    final sortedActivities = _applySorting(recentActivities);

    return CustomScrollView(
      slivers: [
        // Stats overview
        SliverToBoxAdapter(
          child: _buildStatsOverview(historyState),
        ),
        
        SliverToBoxAdapter(
          child: const SizedBox(height: 16),
        ),

        // Sticky title + table header
        SliverPersistentHeader(
          pinned: true,
          delegate: _ActivityTableHeaderDelegate(
            sortBy: _sortBy,
            sortAscending: _sortAscending,
            onSort: _toggleSort,
            activityCount: sortedActivities.length,
          ),
        ),

        // Table rows
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final activity = sortedActivities[index];
              return UnifiedActivityTable(
                activities: [activity],
                sortBy: _sortBy,
                sortAscending: _sortAscending,
                onSort: _toggleSort,
                showHeader: false,
              );
            },
            childCount: sortedActivities.length,
          ),
        ),

        SliverToBoxAdapter(
          child: const SizedBox(height: 24),
        ),
      ],
    );
  }

  Widget _buildStatsOverview(HistoryState historyState) {
    final l10n = AppLocalizations.of(context)!;
    
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
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoveredCardIndex = 0),
            onExit: (_) => setState(() => _hoveredCardIndex = -1),
            child: _buildPremiumStatCard(
            l10n.totalScans,
            '$totalScans',
            LucideIcons.scanLine,
            AppColors.primary,
            l10n.allScansToday,
            isHovered: _hoveredCardIndex == 0,
          ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoveredCardIndex = 1),
            onExit: (_) => setState(() => _hoveredCardIndex = -1),
            child: _buildPremiumStatCard(
            l10n.checkIns,
            '$checkIns',
            LucideIcons.userCheck,
            AppColors.success,
            l10n.successfulEntries,
            isHovered: _hoveredCardIndex == 1,
          ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoveredCardIndex = 2),
            onExit: (_) => setState(() => _hoveredCardIndex = -1),
            child: _buildPremiumStatCard(
            l10n.checkOuts,
            '$checkOuts',
            LucideIcons.userMinus,
            AppColors.warning,
            l10n.successfulExits,
            isHovered: _hoveredCardIndex == 2,
          ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoveredCardIndex = 3),
            onExit: (_) => setState(() => _hoveredCardIndex = -1),
            child: _buildPremiumStatCard(
            l10n.denied,
            '$denied',
            LucideIcons.userX,
            AppColors.error,
            l10n.failedScans,
            isHovered: _hoveredCardIndex == 3,
          ),
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
    { bool isHovered = false }
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isHovered ? color : const Color(0xFF0D0D0D),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 250),
                  scale: isHovered ? 1.1 : 1.0,
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 250),
                    turns: isHovered ? (-5 / 360) : 0,
                    child: Icon(
                      icon,
                      color: isHovered ? const Color(0xFF0D0D0D) : color,
                      size: 28,
                    ),
                  ),
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
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  style: GoogleFonts.firaCode(
                    color: isHovered ? color : AppColors.textPrimary,
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    letterSpacing: 2,
                  ),
                  child: Text(value),
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

  List _applySorting(List activities) {
    // If no sort is selected, return original order
    if (_sortBy.isEmpty) {
      return activities;
    }
    
    final sorted = List.from(activities);
    
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
}

/// Delegate for sticky table header with title
class _ActivityTableHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String sortBy;
  final bool sortAscending;
  final Function(String) onSort;
  final int activityCount;

  _ActivityTableHeaderDelegate({
    required this.sortBy,
    required this.sortAscending,
    required this.onSort,
    required this.activityCount,
  });

  @override
  double get minExtent => 122.0;

  @override
  double get maxExtent => 122.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      height: 122.0,
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 20, 26, 26),
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Text(
              l10n.todayActivityWithCount(activityCount),
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Table header
          Container(
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
                    l10n.member.toUpperCase(),
                    'member',
                    padding: const EdgeInsets.only(
                      left: 56,
                      right: 4,
                      top: 6,
                      bottom: 6,
                    ),
                  ),
                ),
                
                const SizedBox(width: 10),
                
                // Checked In column
                Expanded(
                  flex: 3,
                  child: _buildSortableHeader(
                    l10n.checkedIn.toUpperCase(),
                    'checkIn',
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                  ),
                ),
                
                const SizedBox(width: 10),
                
                // Checked Out column
                Expanded(
                  flex: 2,
                  child: _buildSortableHeader(
                    l10n.checkedOut.toUpperCase(),
                    'checkOut',
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                  ),
                ),
                
                const SizedBox(width: 10),
                
                // Duration column
                SizedBox(
                  width: 120,
                  child: _buildSortableHeader(
                    l10n.duration.toUpperCase(),
                    'duration',
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortableHeader(
    String label,
    String sortKey, {
    Alignment alignment = Alignment.centerLeft,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
  }) {
    final isActive = sortBy == sortKey;

    return Align(
      alignment: alignment,
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

  @override
  bool shouldRebuild(_ActivityTableHeaderDelegate oldDelegate) {
    return sortBy != oldDelegate.sortBy || 
           sortAscending != oldDelegate.sortAscending ||
           activityCount != oldDelegate.activityCount;
  }
}
