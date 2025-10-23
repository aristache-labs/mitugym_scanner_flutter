import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config/app_colors.dart';
import '../providers/history_provider.dart';
import '../providers/gym_schedule_provider.dart';
import '../widgets/member_avatar_modal.dart';
import '../widgets/member_details_modal.dart';

/// Check-ins Analytics Screen - Modern design
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> with SingleTickerProviderStateMixin {
  String _sortBy = ''; // No default sorting - clean state
  bool _sortAscending = true;
  Timer? _syncTimer;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late Animation<double> _percentageAnimation;
  double _currentRate = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    
    _percentageAnimation = Tween<double>(begin: 0.0, end: 100.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    // Skip initial fetch - data already loaded in splash screen
    // Start hourly sync timer for periodic updates
    _startHourlySync();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  /// Start hourly sync timer
  void _startHourlySync() {
    // Sync every hour (3600 seconds) - fetches both schedule and history
    _syncTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      // Only fetch if widget is still mounted
      if (mounted) {
        _fetchData();
      }
    });
  }

  /// Fetch gym schedule and history data
  void _fetchData() {
    // Check if widget is still mounted before using ref
    if (!mounted) return;
    
    Future.microtask(() async {
      try {
        // Double-check mounted state before using ref
        if (!mounted) return;
        
        // Fetch gym schedule
        await ref.read(gymScheduleProvider.notifier).fetchSchedule();
        
        // Check mounted state again before next operation
        if (!mounted) return;
        
        // Sync history from server to get latest activity data
        await ref.read(historyProvider.notifier).syncFromServer();
      } catch (e) {
        // Silently catch errors if widget is disposed
        if (mounted) {
          // Only log if still mounted
          debugPrint('Error fetching data: $e');
        }
      }
    });
  }

  /// Refresh data (schedule and history) - used by pull-to-refresh
  Future<void> _refreshData() async {
    try {
      if (!mounted) return;
      
      // Fetch latest gym schedule
      await ref.read(gymScheduleProvider.notifier).fetchSchedule();
      
      if (!mounted) return;
      
      // Refresh history to get latest check-ins/check-outs
      await ref.read(historyProvider.notifier).syncFromServer();
    } catch (e) {
      if (mounted) {
        debugPrint('Error refreshing data: $e');
      }
    }
  }

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
    
    // Calculate all statistics for today
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
    
    // Success rate: successful sessions / total sessions
    // Count unique successful sessions (not double-counting check-ins and check-outs)
    final successfulSessions = todayActivities
        .where((a) => a.success)
        .length;
    
    final successRate = totalScans > 0 
        ? (successfulSessions / totalScans * 100) 
        : 0.0;
    
    // Trigger animation when success rate changes
    if (_currentRate != successRate) {
      _currentRate = successRate;
      _percentageAnimation = Tween<double>(
        begin: 0.0,
        end: successRate,
      ).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
      );
      _progressAnimation = Tween<double>(
        begin: 0.0,
        end: successRate / 100,
      ).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
      );
      _progressController.forward(from: 0.0);
    }

    // Calculate peak occupancy
    final peakOccupancy = _calculatePeakOccupancy(todayActivities.toList());
    
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Traffic Chart
            _buildTodaysTrafficChart(todayActivities.toList(), peakOccupancy),
            const SizedBox(height: 20),
            
            // Charts and analytics section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success rate chart
                Expanded(
                  child: _buildSuccessRateCard(successRate, checkIns, checkOuts, denied),
                ),
                const SizedBox(width: 16),
                
                // Peak hours
                Expanded(
                  child: _buildPeakHoursCard(todayActivities.toList()),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Recent check-ins list
            _buildRecentCheckIns(todayActivities.toList(), context),
          ],
        ),
      ),
    );
  }
  
  /// Calculate how many people are IN the gym at a specific hour
  /// This considers check-ins and check-outs to show actual occupancy
  int _calculateOccupancyAtHour(List<dynamic> activities, int targetHour) {
    int count = 0;
    
    // Create a DateTime for the target hour (start of that hour)
    final now = DateTime.now();
    final targetTime = DateTime(now.year, now.month, now.day, targetHour, 0, 0);
    
    for (var activity in activities) {
      // Only count successful check-ins
      if (!activity.success || activity.checkInTime == null) continue;
      
      final checkInTime = activity.checkInTime!;
      final checkOutTime = activity.checkOutTime;
      
      // Person is in the gym at targetHour if:
      // 1. They checked in at or before the target hour
      // 2. They haven't checked out yet OR they checked out AFTER the target hour
      if (checkInTime.isBefore(targetTime) || checkInTime.hour == targetHour) {
        if (checkOutTime == null || checkOutTime.isAfter(targetTime)) {
          count++;
        }
      }
    }
    
    return count;
  }
  
  /// Calculate peak occupancy throughout the day
  int _calculatePeakOccupancy(List<dynamic> activities) {
    if (activities.isEmpty) return 0;
    
    final scheduleNotifier = ref.read(gymScheduleProvider.notifier);
    final openHour = scheduleNotifier.openHour ?? 0;
    final closeHour = scheduleNotifier.closeHour ?? 23;
    
    int peak = 0;
    
    // Check occupancy at each hour during opening hours
    for (int hour = openHour; hour <= closeHour; hour++) {
      if (scheduleNotifier.isOpenAtHour(hour)) {
        final occupancy = _calculateOccupancyAtHour(activities, hour);
        if (occupancy > peak) peak = occupancy;
      }
    }
    
    return peak;
  }
  
  /// Build Today's Traffic Chart
  Widget _buildTodaysTrafficChart(List<dynamic> activities, int peakOccupancy) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Traffic',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Live gym occupancy throughout the day',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Peak indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Peak: ',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$peakOccupancy',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'people',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Chart
          SizedBox(
            height: 200,
            child: _buildLineChart(activities),
          ),
          
          const SizedBox(height: 20),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Live occupancy', AppColors.primary, true),
              const SizedBox(width: 24),
              _buildLegendItem('Future hours', AppColors.textMuted.withValues(alpha: 0.3), false),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Updates info
          Center(
            child: Text(
              'Updates every hour',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build legend item
  Widget _buildLegendItem(String label, Color color, bool filled) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: filled ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  /// Build the line chart
  Widget _buildLineChart(List<dynamic> activities) {
    final scheduleNotifier = ref.read(gymScheduleProvider.notifier);
    
    // Get gym opening hours (default to 0-23 if no schedule)
    final openHour = scheduleNotifier.openHour ?? 0;
    final closeHour = scheduleNotifier.closeHour ?? 23;
    
    // Calculate occupancy for each hour (only for opening hours)
    // We include all opening hours to show the complete timeline
    final hourlyData = List.generate(24, (hour) {
      // Only show data for opening hours
      if (!scheduleNotifier.isOpenAtHour(hour)) {
        return null; // Skip closed hours
      }
      
      // Calculate how many people are IN the gym at this hour
      final occupancy = _calculateOccupancyAtHour(activities, hour);
      return FlSpot(hour.toDouble(), occupancy.toDouble());
    }).whereType<FlSpot>().toList(); // Filter out null (closed hours)
    
    final now = DateTime.now();
    final currentHour = now.hour;
    
    // Split data into past (live) and future
    final liveData = hourlyData.where((spot) => spot.x <= currentHour).toList();
    final futureData = hourlyData.where((spot) => spot.x > currentHour).toList();
    
    // Add connection point between live and future data
    if (liveData.isNotEmpty && futureData.isNotEmpty) {
      futureData.insert(0, liveData.last);
    }
    
    final maxY = hourlyData.isEmpty ? 5.0 : hourlyData.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final yMax = maxY > 0 ? (maxY + 2).ceilToDouble() : 5.0;
    
    // Use gym opening hours for X-axis range
    final minX = openHour.toDouble();
    final maxX = closeHour.toDouble();
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.textMuted.withValues(alpha: 0.08),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.inter(
                    color: AppColors.primary.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final hour = value.toInt();
                // Only show labels for opening hours
                if (hour < openHour || hour > closeHour) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${hour.toString().padLeft(2, '0')}:00',
                    style: GoogleFonts.inter(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: minX,
        maxX: maxX,
        minY: 0,
        maxY: yMax,
        lineBarsData: [
          // Live data line
          LineChartBarData(
            spots: liveData,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: AppColors.background,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
          // Future data line (greyed out)
          if (futureData.length > 1)
            LineChartBarData(
              spots: futureData,
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.textMuted.withValues(alpha: 0.2),
              barWidth: 3,
              isStrokeCapRound: true,
              dashArray: [5, 5],
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.transparent,
                    strokeWidth: 2,
                    strokeColor: AppColors.textMuted.withValues(alpha: 0.3),
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => AppColors.surface,
            tooltipBorder: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.asMap().entries.map((entry) {
                final index = entry.key;
                final spot = entry.value;
                
                // Only show tooltip for the first line (live occupancy)
                // Skip the second line (future hours - dashed line)
                if (index > 0) {
                  return null;
                }
                
                final hour = spot.x.toInt();
                final count = spot.y.toInt();
                return LineTooltipItem(
                  '${hour.toString().padLeft(2, '0')}:00\n$count ${count == 1 ? 'person' : 'people'}',
                  GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  /// Build success rate card with animations
  Widget _buildSuccessRateCard(double rate, int checkIns, int checkOuts, int denied) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Success Rate',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AnimatedBuilder(
                animation: _percentageAnimation,
                builder: (context, child) {
                  return Text(
                    '${_percentageAnimation.value.toStringAsFixed(1)}%',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Progress bar with animation
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progressAnimation.value,
                  minHeight: 10,
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    rate >= 80 ? AppColors.success :
                    rate >= 50 ? AppColors.warning :
                    AppColors.error,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Stats breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Check-ins', '$checkIns', AppColors.success),
              _buildStatItem('Check-outs', '$checkOuts', AppColors.warning),
              _buildStatItem('Denied', '$denied', AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Build peak hours card
  Widget _buildPeakHoursCard(List activities) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.clock,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Peak Hours',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (activities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'No data yet',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...['Morning', 'Afternoon', 'Evening'].map((time) {
              final count = _getCountByPeriod(activities, time);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      time,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$count',
                      style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                        fontWeight: FontWeight.bold,
                ),
              ),
            ],
                ),
              );
            }),
        ],
      ),
    );
  }

  int _getCountByPeriod(List activities, String period) {
    return activities.where((a) {
      // Only count successful check-ins (activities with checkInTime)
      if (!a.success) return false;
      if (a.checkInTime == null) return false;
      
      final hour = a.time.hour;
      if (period == 'Morning') return hour >= 6 && hour < 12;
      if (period == 'Afternoon') return hour >= 12 && hour < 18;
      return hour >= 18 || hour < 6;
    }).length;
  }

  /// Build recent check-ins list
  Widget _buildRecentCheckIns(List activities, BuildContext context) {
    var recent = activities.toList();
    
    // Apply sorting
    recent = _applySorting(recent);
    
    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(
            'Recent Activity',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (recent.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'No recent activity',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else ...[
            _buildActivityTableHeader(),
            ...recent.map((activity) => _buildActivityItem(activity, context)),
          ],
        ],
      ),
    );
  }

  /// Build activity table header (matching dashboard/history) with sorting
  Widget _buildActivityTableHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
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
  
  List<dynamic> _applySorting(List<dynamic> activities) {
    // If no sort is selected, return original order
    if (_sortBy.isEmpty) {
      return activities;
    }
    
    final sorted = List<dynamic>.from(activities);
    
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

  /// Build activity item (matching dashboard/history layout)
  Widget _buildActivityItem(dynamic activity, BuildContext context) {
    final isSuccess = activity.success;
    final statusColor = isSuccess ? AppColors.success : AppColors.error;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
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
                  child: GestureDetector(
                    onTap: () {
                      // Show member details modal if member data is available
                      if (activity.memberData != null) {
                        MemberDetailsModal.show(context, member: activity.memberData!);
                      }
                    },
                    child: Text(
                      activity.memberName,
                      style: GoogleFonts.inter(
                        color: activity.memberData != null 
                            ? AppColors.primary 
                            : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
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
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: DateFormat('h:mm a').format(activity.checkInTime!),
                              style: GoogleFonts.inter(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' - ',
                              style: GoogleFonts.inter(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text: DateFormat('MMM d, yyyy').format(activity.checkInTime!),
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
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
                                LucideIcons.xCircle,
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
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: DateFormat('h:mm a').format(activity.checkOutTime!),
                              style: GoogleFonts.inter(
                                color: AppColors.warning,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' - ',
                              style: GoogleFonts.inter(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text: DateFormat('MMM d, yyyy').format(activity.checkOutTime!),
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
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
                                LucideIcons.shieldAlert,
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
                                    LucideIcons.dumbbell,
                                    size: 13,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Still in GYM',
                                    style: GoogleFonts.inter(
                                      color: AppColors.success,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                              .animate(onPlay: (controller) => controller.repeat())
                              .fadeIn(duration: 800.ms, curve: Curves.easeInOut)
                              .then()
                              .fadeOut(duration: 800.ms, curve: Curves.easeInOut),
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
            width: 140,
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
                                LucideIcons.trendingUp,
                                size: 13,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Active Session',
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
