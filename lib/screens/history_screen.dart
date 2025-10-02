import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../config/app_colors.dart';
import '../models/activity_log.dart';
import '../providers/scan_provider.dart';
import '../services/export_service.dart';

/// History screen with filtering, date range, and export
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final ExportService _exportService = ExportService();
  
  String _filterType = 'all'; // all, success, error
  DateTimeRange? _dateRange;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ActivityLog> _getFilteredActivities() {
    final scanState = ref.watch(scanProvider);
    var activities = scanState.recentActivity.toList();
    
    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      activities = activities.where((log) {
        return log.memberName.toLowerCase().contains(query) ||
               log.action.toLowerCase().contains(query);
      }).toList();
    }
    
    // Apply status filter
    if (_filterType == 'success') {
      activities = activities.where((log) => log.success).toList();
    } else if (_filterType == 'error') {
      activities = activities.where((log) => !log.success).toList();
    }
    
    // Apply date range filter
    if (_dateRange != null) {
      activities = activities.where((log) {
        return log.time.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
               log.time.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }
    
    return activities;
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
    }
  }

  void _clearFilters() {
    setState(() {
      _filterType = 'all';
      _dateRange = null;
      _searchController.clear();
    });
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
    final totalActivities = ref.watch(scanProvider).recentActivity.length;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.primary),
            tooltip: 'Export',
            onPressed: _exportHistory,
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Filters section
          _buildFiltersSection(totalActivities, activities.length),
          
          // Activity list or empty state
          Expanded(
            child: activities.isEmpty ? _buildEmptyState() : _buildActivityList(activities),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(int total, int filtered) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'Search by name or action...',
              hintStyle: TextStyle(color: AppColors.muted.withValues(alpha: 0.6)),
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.muted),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All',
                  value: 'all',
                  icon: Icons.list,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Success',
                  value: 'success',
                  icon: Icons.check_circle,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Errors',
                  value: 'error',
                  icon: Icons.error,
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
          const SizedBox(height: 12),
          
          // Results summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing $filtered of $total activities',
                style: TextStyle(
                  color: AppColors.muted.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              if (_dateRange != null)
                Text(
                  '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}',
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
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
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? AppColors.background : chipColor,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterType = value);
      },
      backgroundColor: AppColors.card,
      selectedColor: chipColor,
      checkmarkColor: AppColors.background,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.background : chipColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? chipColor : chipColor.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildDateRangeChip() {
    return ActionChip(
      avatar: Icon(
        Icons.calendar_today,
        size: 16,
        color: _dateRange != null ? AppColors.background : AppColors.accent,
      ),
      label: Text(_dateRange != null ? 'Date Range' : 'Pick Date'),
      onPressed: _selectDateRange,
      backgroundColor: _dateRange != null ? AppColors.accent : AppColors.card,
      labelStyle: TextStyle(
        color: _dateRange != null ? AppColors.background : AppColors.accent,
        fontWeight: _dateRange != null ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: _dateRange != null 
            ? AppColors.accent 
            : AppColors.accent.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildClearFiltersChip() {
    return ActionChip(
      avatar: const Icon(Icons.clear, size: 16, color: AppColors.background),
      label: const Text('Clear'),
      onPressed: _clearFilters,
      backgroundColor: AppColors.error,
      labelStyle: const TextStyle(
        color: AppColors.background,
        fontWeight: FontWeight.bold,
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final dayActivities = grouped[dateKey]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      dateKey,
                      style: const TextStyle(
                        color: AppColors.background,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${dayActivities.length} scans',
                    style: TextStyle(
                      color: AppColors.muted.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Activities for this date
            ...dayActivities.map((activity) => _buildActivityCard(activity)),
          ],
        );
      },
    );
  }

  Widget _buildActivityCard(ActivityLog activity) {
    final statusColor = activity.success ? AppColors.success : AppColors.error;
    
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            if (activity.hasAvatar)
              _buildAvatar(activity, statusColor)
            else
              _buildFallbackAvatar(activity, statusColor),
            const SizedBox(width: 16),
            
            // Activity details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.memberName,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        activity.success ? Icons.check_circle : Icons.error,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          activity.action,
                          style: TextStyle(
                            color: AppColors.muted.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('h:mm a').format(activity.time),
                    style: TextStyle(
                      color: AppColors.muted.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Status icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                activity.success ? Icons.login : Icons.block,
                color: statusColor,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ActivityLog activity, Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: CachedNetworkImage(
        imageUrl: activity.avatarUrl!,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 24,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: AppColors.surface,
          highlightColor: AppColors.primary.withValues(alpha: 0.3),
          child: const CircleAvatar(radius: 24),
        ),
        errorWidget: (context, url, error) => _buildFallbackAvatar(activity, borderColor),
      ),
    );
  }

  Widget _buildFallbackAvatar(ActivityLog activity, Color borderColor) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
              color: borderColor,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(
        child: Text(
          activity.initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

