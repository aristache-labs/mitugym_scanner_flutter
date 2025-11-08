import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_colors.dart';
import '../models/activity_log.dart';
import '../providers/history_provider.dart';
import '../providers/config_provider.dart';
import '../services/export_service.dart';
import '../widgets/unified_activity_table.dart';
import '../widgets/date_range_picker_modal.dart';

/// History screen with filtering and modern design
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final ExportService _exportService = ExportService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _exportButtonKey = GlobalKey();
  
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
    final picked = await DateRangePickerModal.show(
      context,
      initialDateRange: _dateRange,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
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

  Future<void> _exportHistory(String format) async {
    final activities = _getFilteredActivities();
    
    if (activities.isEmpty) {
      if (mounted) {
        _showPremiumToast(
          'No activities to export',
          LucideIcons.alertCircle,
          ToastType.warning,
        );
      }
      return;
    }

    try {
      // Get custom export path from config
      final config = ref.read(configProvider);
      final customPath = config.exportPath.isNotEmpty ? config.exportPath : null;
      
      // Export using selected format
      String? filePath;
      switch (format.toLowerCase()) {
        case 'csv':
          filePath = await _exportService.exportToCSV(activities, customPath: customPath);
          break;
        case 'pdf':
          filePath = await _exportService.exportToPDF(activities, customPath: customPath);
          break;
        case 'txt':
        default:
          filePath = await _exportService.exportToText(activities, customPath: customPath);
      }
      
      if (filePath == null) {
        throw Exception('Export failed: No file path returned');
      }
      
      if (mounted) {
        _showPremiumToast(
          'Exported ${format.toUpperCase()} to: $filePath',
          LucideIcons.checkCircle,
          ToastType.success,
          filePath: filePath,
        );
      }
    } catch (e) {
      if (mounted) {
        _showPremiumToast(
          'Export failed: $e',
          LucideIcons.xCircle,
          ToastType.error,
        );
      }
    }
  }

  void _showExportMenu(BuildContext context) {
    final RenderBox? renderBox = _exportButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + size.width - 200, // Align right edge of menu with button
        offset.dy + size.height + 8, // 8px below the button
        MediaQuery.of(context).size.width - offset.dx - size.width,
        0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      color: AppColors.card,
      elevation: 8,
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          enabled: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Export Format',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        _buildExportMenuItem(
          icon: LucideIcons.fileSpreadsheet,
          label: 'CSV',
          description: 'Comma-separated values',
          onTap: () {
            Navigator.pop(context);
            _exportHistory('csv');
          },
        ),
        _buildExportMenuItem(
          icon: LucideIcons.fileText,
          label: 'PDF',
          description: 'Portable document format',
          onTap: () {
            Navigator.pop(context);
            _exportHistory('pdf');
          },
        ),
        _buildExportMenuItem(
          icon: LucideIcons.fileType,
          label: 'TXT',
          description: 'Plain text file',
          onTap: () {
            Navigator.pop(context);
            _exportHistory('txt');
          },
        ),
      ],
    );
  }

  PopupMenuItem _buildExportMenuItem({
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: AppColors.textMuted.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
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
          key: _exportButtonKey,
          onPressed: () => _showExportMenu(context),
          icon: const Icon(LucideIcons.download, size: 16),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Export',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                LucideIcons.chevronDown,
                size: 14,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            ],
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            foregroundColor: AppColors.primary.withValues(alpha: 0.95),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 1,
              ),
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
              prefixIcon: const Icon(LucideIcons.search, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, color: AppColors.textMuted),
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
                  icon: LucideIcons.list,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Success',
                  value: 'success',
                  icon: LucideIcons.checkCircle,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Denied',
                  value: 'failed',
                  icon: LucideIcons.shieldAlert,
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
              LucideIcons.calendar,
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
            const Icon(LucideIcons.x, size: 16, color: AppColors.error),
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
            LucideIcons.history,
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
                      isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight,
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
                            LucideIcons.qrCode,
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
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: UnifiedActivityTable(
                  activities: dayActivities,
                  sortBy: _sortBy,
                  sortAscending: _sortAscending,
                  onSort: _toggleSort,
                  showHeader: false, // Header is shown at the top of the entire list
                ),
              ),
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
            width: 140,
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
                  ? (_sortAscending ? LucideIcons.arrowUp : LucideIcons.arrowDown)
                  : LucideIcons.arrowUpDown,
                        size: 14,
              color: isActive ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }


  // Premium Toast Helper
  void _showPremiumToast(String message, IconData icon, ToastType type, {String? filePath}) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _PremiumToast(
        message: message,
        icon: icon,
        color: type == ToastType.success
            ? AppColors.success
            : type == ToastType.error
                ? AppColors.error
                : AppColors.warning,
        filePath: filePath,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

enum ToastType { success, error, warning }

class _PremiumToast extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final String? filePath;
  final VoidCallback onDismiss;

  const _PremiumToast({
    required this.message,
    required this.icon,
    required this.color,
    this.filePath,
    required this.onDismiss,
  });

  @override
  State<_PremiumToast> createState() => _PremiumToastState();
}

class _PremiumToastState extends State<_PremiumToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      reverseCurve: Curves.easeOut,
    ));

    _controller.forward();

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openFile() async {
    if (widget.filePath == null) return;
    
    try {
      final uri = Uri.file(widget.filePath!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error opening file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Material(
              color: Colors.transparent,
              child: MouseRegion(
                cursor: widget.filePath != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: GestureDetector(
                  onTap: widget.filePath != null ? _openFile : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    constraints: const BoxConstraints(
                      maxWidth: double.infinity,
                      minWidth: 300,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.card.withValues(alpha: _isHovered && widget.filePath != null ? 1.0 : 0.95),
                          AppColors.surface.withValues(alpha: _isHovered && widget.filePath != null ? 0.95 : 0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.color.withValues(alpha: _isHovered && widget.filePath != null ? 0.5 : 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: _isHovered && widget.filePath != null ? 32 : 24,
                          offset: Offset(0, _isHovered && widget.filePath != null ? 16 : 12),
                          spreadRadius: -4,
                        ),
                        BoxShadow(
                          color: widget.color.withValues(alpha: _isHovered && widget.filePath != null ? 0.3 : 0.2),
                          blurRadius: _isHovered && widget.filePath != null ? 20 : 16,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: widget.color.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color.withValues(alpha: 0.9),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        widget.message,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

