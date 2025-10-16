import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../models/activity_log.dart';
import '../providers/history_provider.dart';
import '../services/export_service.dart';
import '../widgets/member_avatar_modal.dart';

/// History screen with filtering and modern design
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final ExportService _exportService = ExportService();
  final ScrollController _scrollController = ScrollController();
  
  String _filterType = 'all'; // all, success, error
  DateTimeRange? _dateRange;
  final TextEditingController _searchController = TextEditingController();
  
  // Sorting state
  String _sortBy = 'time'; // member, checkIn, checkOut, duration, time
  bool _sortAscending = false;
  
  // Collapse/expand state for date categories
  final Map<String, bool> _expandedDates = {};
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  bool _isCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Handle scroll for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.9) {
      final historyState = ref.read(historyProvider);
      if (!historyState.isLoading && historyState.hasMore) {
        ref.read(historyProvider.notifier).loadMoreHistory();
      }
    }
  }

  List<ActivityLog> _getFilteredActivities() {
    final historyState = ref.watch(historyProvider);
    final items = List<ActivityLog>.from(historyState.items);
    
    // Apply sorting
    items.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'member':
          comparison = a.memberName.compareTo(b.memberName);
          break;
        case 'checkIn':
          final aTime = a.checkInTime ?? DateTime(1970);
          final bTime = b.checkInTime ?? DateTime(1970);
          comparison = aTime.compareTo(bTime);
          break;
        case 'checkOut':
          final aTime = a.checkOutTime ?? DateTime(1970);
          final bTime = b.checkOutTime ?? DateTime(1970);
          comparison = aTime.compareTo(bTime);
          break;
        case 'duration':
          final aDuration = a.durationMinutes ?? 0;
          final bDuration = b.durationMinutes ?? 0;
          comparison = aDuration.compareTo(bDuration);
          break;
        case 'time':
        default:
          comparison = a.time.compareTo(b.time);
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });
    
    return items;
  }
  
  void _toggleSort(String sortBy) {
    setState(() {
      if (_sortBy == sortBy) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = sortBy;
        _sortAscending = true;
      }
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.background,
              surface: AppColors.surface,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
      // Apply filters to history provider
      ref.read(historyProvider.notifier).applyFilters(
        searchQuery: _searchController.text,
        statusFilter: _filterType,
        dateRange: picked,
      );
    }
  }

  void _clearFilters() {
    setState(() {
      _filterType = 'all';
      _dateRange = null;
      _searchController.clear();
    });
    // Clear filters in history provider
    ref.read(historyProvider.notifier).clearFilters();
  }
  
  /// Apply search filter
  void _applySearchFilter() {
    ref.read(historyProvider.notifier).applyFilters(
      searchQuery: _searchController.text,
      statusFilter: _filterType,
      dateRange: _dateRange,
    );
  }
  
  /// Apply status filter
  void _applyStatusFilter(String status) {
    setState(() {
      _filterType = status;
    });
    ref.read(historyProvider.notifier).applyFilters(
      searchQuery: _searchController.text,
      statusFilter: status,
      dateRange: _dateRange,
    );
  }

  Future<void> _exportHistory() async {
    final activities = _getFilteredActivities();
    
    if (activities.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No activities to export'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      return;
    }

    try {
      final filePath = await _exportService.exportToCSV(activities);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported to: $filePath'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activities = _getFilteredActivities();
    final historyState = ref.watch(historyProvider);
    final totalActivities = historyState.items.length;
    
    return Column(
        children: [
        // Header with export button
        _buildHeader(totalActivities, activities.length),
        const SizedBox(height: 16),
        
          // Filters section
        _buildFiltersSection(),
        const SizedBox(height: 16),
          
          // Activity list or empty state
          Expanded(
            child: activities.isEmpty ? _buildEmptyState() : _buildActivityList(activities),
          ),
        ],
    );
  }

  Widget _buildHeader(int total, int filtered) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Showing $filtered of $total',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
            if (_dateRange != null) ...[
              const SizedBox(height: 4),
              Text(
                '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        ElevatedButton.icon(
          onPressed: _exportHistory,
          icon: const Icon(Icons.download_rounded, size: 18),
          label: Text(
            'Export',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: (_) {
              setState(() {});
              _applySearchFilter();
            },
            style: GoogleFonts.inter(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search by name...',
              hintStyle: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                        _applySearchFilter();
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          
          // Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All',
                  value: 'all',
                  icon: Icons.list_rounded,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Success',
                  value: 'success',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Denied',
                  value: 'failed',
                  icon: Icons.block_rounded,
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                _buildDateRangeChip(),
                const SizedBox(width: 8),
                if (_filterType != 'all' || _dateRange != null || _searchController.text.isNotEmpty)
                  _buildClearFiltersChip(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    final isSelected = _filterType == value;
    final chipColor = color ?? AppColors.primary;
    
    return InkWell(
      onTap: () => _applyStatusFilter(value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
              color: isSelected ? chipColor : AppColors.textMuted,
          ),
          const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? chipColor : AppColors.textMuted,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeChip() {
    final isSelected = _dateRange != null;
    return InkWell(
      onTap: _selectDateRange,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.warning.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.warning : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_rounded,
        size: 16,
              color: isSelected ? AppColors.warning : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              isSelected ? 'Date Range' : 'Pick Date',
              style: GoogleFonts.inter(
                color: isSelected ? AppColors.warning : AppColors.textMuted,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearFiltersChip() {
    return InkWell(
      onTap: _clearFilters,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.clear_rounded, size: 16, color: AppColors.error),
            const SizedBox(width: 6),
            Text(
              'Clear',
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppColors.muted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No activities found',
            style: TextStyle(
              color: AppColors.muted.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              color: AppColors.muted.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(List<ActivityLog> activities) {
    // Group activities by date
    final grouped = <String, List<ActivityLog>>{};
    for (final activity in activities) {
      final dateKey = DateFormat('EEEE, MMMM d, y').format(activity.time);
      grouped.putIfAbsent(dateKey, () => []).add(activity);
    }

    final sortedDates = grouped.keys.toList()
      ..sort((a, b) {
        final dateA = grouped[a]!.first.time;
        final dateB = grouped[b]!.first.time;
        return dateB.compareTo(dateA);
      });

    final historyState = ref.watch(historyProvider);

    return Stack(
      children: [
        // Activity list with padding for fixed header
        Positioned.fill(
          top: 55, // Height of the header
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            itemCount: sortedDates.length + (historyState.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator at the end
        if (index >= sortedDates.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: historyState.isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    )
                  : const SizedBox.shrink(),
            ),
          );
        }
        

        final dateKey = sortedDates[index];
        final dayActivities = grouped[dateKey]!;
        
        // Determine if this date should be expanded by default
        final firstActivityDate = dayActivities.first.time;
        final isCurrentWeekDate = _isCurrentWeek(firstActivityDate);
        
        // Initialize expanded state if not set
        if (!_expandedDates.containsKey(dateKey)) {
          _expandedDates[dateKey] = isCurrentWeekDate;
        }
        
        final isExpanded = _expandedDates[dateKey] ?? false;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header - Clickable to expand/collapse
            InkWell(
              onTap: () {
                setState(() {
                  _expandedDates[dateKey] = !isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.only(bottom: 16, top: index == 0 ? 0 : 24, left: 4, right: 4),
              child: Row(
                children: [
                    // Expand/collapse icon
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    // Vertical accent line
                  Container(
                      width: 3,
                      height: 20,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withValues(alpha: isExpanded ? 0.8 : 0.5),
                            AppColors.primary.withValues(alpha: isExpanded ? 0.3 : 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Date text
                    Expanded(
                    child: Text(
                      dateKey,
                        style: GoogleFonts.inter(
                          color: isExpanded ? AppColors.text : AppColors.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                      ),
                    ),
                  ),
                    const SizedBox(width: 12),
                    // Scan count badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                  Text(
                            '${dayActivities.length}',
                            style: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Activities for this date (only show if expanded)
            if (isExpanded)
            ...dayActivities.map((activity) => _buildActivityCard(activity)),
          ],
        );
      },
          ),
        ),
        
        // Fixed table header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildTableHeader(),
        ),
      ],
    );
  }

  /// Build table header (like web panel) with sorting
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
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

  Widget _buildActivityCard(ActivityLog activity) {
    final isSuccess = activity.success;

    // Determine status color based on success
    final statusColor = isSuccess ? AppColors.success : AppColors.error;
    
    return Container(
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
        border: Border(
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

