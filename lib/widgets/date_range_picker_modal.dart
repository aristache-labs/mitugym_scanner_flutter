import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';

/// Modern compact date range picker modal
class DateRangePickerModal extends StatefulWidget {
  final DateTimeRange? initialDateRange;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DateRangePickerModal({
    super.key,
    this.initialDateRange,
    this.firstDate,
    this.lastDate,
  });

  static Future<DateTimeRange?> show(
    BuildContext context, {
    DateTimeRange? initialDateRange,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return showDialog<DateTimeRange>(
      context: context,
      builder: (context) => DateRangePickerModal(
        initialDateRange: initialDateRange,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );
  }

  @override
  State<DateRangePickerModal> createState() => _DateRangePickerModalState();
}

class _DateRangePickerModalState extends State<DateRangePickerModal> {
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime _focusedMonth = DateTime.now();
  String? _selectedPreset;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialDateRange?.start;
    _endDate = widget.initialDateRange?.end;
    
    // Set focused month to start date if available, otherwise current month
    if (_startDate != null) {
      _focusedMonth = DateTime(_startDate!.year, _startDate!.month, 1);
    }
  }

  void _onDayTapped(DateTime date) {
    setState(() {
      _selectedPreset = null; // Clear preset when manually selecting
      
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        // Start new range
        _startDate = date;
        _endDate = null;
      } else if (date.isBefore(_startDate!)) {
        // Selected date is before start, make it the new start
        _startDate = date;
        _endDate = null;
      } else {
        // Complete the range
        _endDate = date;
      }
    });
  }

  void _applyPreset(String preset, DateTime start, DateTime end) {
    setState(() {
      _selectedPreset = preset;
      _startDate = start;
      _endDate = end;
    });
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return false;
    return date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
        date.isBefore(_endDate!.add(const Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.surface.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.calendarRange,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Date Range',
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _startDate != null && _endDate != null
                              ? '${DateFormat('MMM d, yyyy').format(_startDate!)} - ${DateFormat('MMM d, yyyy').format(_endDate!)}'
                              : _startDate != null
                                  ? 'From ${DateFormat('MMM d, yyyy').format(_startDate!)}...'
                                  : 'Select start date',
                          style: GoogleFonts.inter(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, color: AppColors.textMuted, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface.withValues(alpha: 0.5),
                      padding: const EdgeInsets.all(6),
                    ),
                  ),
                ],
              ),
            ),

            // Content (no scroll needed)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quick presets
                  _buildPresets(today),
                  const SizedBox(height: 16),
                  
                  // Calendar
                  _buildCalendar(),
                ],
              ),
            ),

            // Footer buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _startDate != null && _endDate != null
                          ? () => Navigator.pop(context, DateTimeRange(start: _startDate!, end: _endDate!))
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.muted,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.check, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Apply Filter',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresets(DateTime today) {
    final presets = [
      {'label': 'Today', 'key': 'today', 'start': today, 'end': today},
      {'label': 'Yesterday', 'key': 'yesterday', 'start': today.subtract(const Duration(days: 1)), 'end': today.subtract(const Duration(days: 1))},
      {'label': 'Last 7 Days', 'key': 'week', 'start': today.subtract(const Duration(days: 6)), 'end': today},
      {'label': 'Last 30 Days', 'key': 'month', 'start': today.subtract(const Duration(days: 29)), 'end': today},
      {'label': 'This Month', 'key': 'thisMonth', 'start': DateTime(today.year, today.month, 1), 'end': today},
      {'label': 'Last Month', 'key': 'lastMonth', 'start': DateTime(today.year, today.month - 1, 1), 'end': DateTime(today.year, today.month, 0)},
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: presets.map((preset) {
        final isSelected = _selectedPreset == preset['key'];
        return InkWell(
          onTap: () => _applyPreset(
            preset['key'] as String,
            preset['start'] as DateTime,
            preset['end'] as DateTime,
          ),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? AppColors.primaryGradient
                  : null,
              color: isSelected ? null : AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.border.withValues(alpha: 0.3),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              preset['label'] as String,
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Month navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(LucideIcons.chevronLeft, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    padding: const EdgeInsets.all(6),
                    minimumSize: const Size(32, 32),
                  ),
                ),
                Expanded(
                  child: Text(
                    DateFormat('MMMM yyyy').format(_focusedMonth),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(LucideIcons.chevronRight, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    padding: const EdgeInsets.all(6),
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ],
            ),
          ),

          // Weekday headers
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Row(
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Calendar grid
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
            child: _buildCalendarGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // Convert to 0 = Sunday

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<Widget> dayWidgets = [];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isToday = _isSameDay(date, today);
      final isStart = _isSameDay(date, _startDate);
      final isEnd = _isSameDay(date, _endDate);
      final isInRange = _isInRange(date);
      final isDisabled = widget.firstDate != null && date.isBefore(widget.firstDate!) ||
          widget.lastDate != null && date.isAfter(widget.lastDate!);

      dayWidgets.add(_buildDayCell(
        date: date,
        day: day,
        isToday: isToday,
        isStart: isStart,
        isEnd: isEnd,
        isInRange: isInRange,
        isDisabled: isDisabled,
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: 1.0,
      children: dayWidgets,
    );
  }

  Widget _buildDayCell({
    required DateTime date,
    required int day,
    required bool isToday,
    required bool isStart,
    required bool isEnd,
    required bool isInRange,
    required bool isDisabled,
  }) {
    Color? backgroundColor;
    Color? textColor;
    Border? border;
    
    if (isDisabled) {
      textColor = AppColors.textMuted.withValues(alpha: 0.3);
    } else if (isStart || isEnd) {
      backgroundColor = AppColors.primary;
      textColor = Colors.white;
      border = Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2);
    } else if (isInRange) {
      backgroundColor = AppColors.primary.withValues(alpha: 0.15);
      textColor = AppColors.primary;
    } else if (isToday) {
      border = Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5);
      textColor = AppColors.primary;
    } else {
      textColor = AppColors.textPrimary;
    }

    return InkWell(
      onTap: isDisabled ? null : () => _onDayTapped(date),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: border,
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: GoogleFonts.inter(
              color: textColor,
              fontSize: 13,
              fontWeight: (isStart || isEnd || isToday) ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

