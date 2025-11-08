import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config/app_colors.dart';
import '../providers/history_provider.dart';
import '../widgets/unified_activity_table.dart';

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
        
        // Today's Activity - Using Unified Table Component
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Today\'s Activity (${sortedActivities.length} entries)',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              UnifiedActivityTable(
                activities: sortedActivities.cast(),
                sortBy: _sortBy,
                sortAscending: _sortAscending,
                onSort: _toggleSort,
                showHeader: true,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
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
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoveredCardIndex = 0),
            onExit: (_) => setState(() => _hoveredCardIndex = -1),
            child: _buildPremiumStatCard(
            'Total Scans',
            '$totalScans',
            LucideIcons.scanLine,
            AppColors.primary,
            'All scans today',
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
            'Check-ins',
            '$checkIns',
            LucideIcons.userCheck,
            AppColors.success,
            'Successful entries',
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
            'Check-outs',
            '$checkOuts',
            LucideIcons.userMinus,
            AppColors.warning,
            'Successful exits',
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
            'Denied',
            '$denied',
            LucideIcons.userX,
            AppColors.error,
            'Failed scans',
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
