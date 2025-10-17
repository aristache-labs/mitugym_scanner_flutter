/// Gym schedule model
/// Contains opening and closing hours for the gym
class GymSchedule {
  final String id;
  final String dayOfWeek; // e.g., "monday", "tuesday", etc.
  final String? openTime; // e.g., "06:00"
  final String? closeTime; // e.g., "22:00"
  final bool isClosed; // If true, gym is closed this day

  const GymSchedule({
    required this.id,
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    required this.isClosed,
  });

  /// Create GymSchedule from JSON response
  factory GymSchedule.fromJson(Map<String, dynamic> json) {
    return GymSchedule(
      id: json['id'] as String? ?? '',
      dayOfWeek: json['day_of_week'] as String? ?? '',
      openTime: json['open_time'] as String?,
      closeTime: json['close_time'] as String?,
      isClosed: json['is_closed'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day_of_week': dayOfWeek,
      'open_time': openTime,
      'close_time': closeTime,
      'is_closed': isClosed,
    };
  }

  /// Get opening hour as integer (0-23)
  int? get openHour {
    if (openTime == null || isClosed) return null;
    try {
      final parts = openTime!.split(':');
      return int.parse(parts[0]);
    } catch (e) {
      return null;
    }
  }

  /// Get closing hour as integer (0-23)
  int? get closeHour {
    if (closeTime == null || isClosed) return null;
    try {
      final parts = closeTime!.split(':');
      return int.parse(parts[0]);
    } catch (e) {
      return null;
    }
  }

  /// Check if gym is open at a specific hour
  bool isOpenAtHour(int hour) {
    if (isClosed) return false;
    final open = openHour;
    final close = closeHour;
    if (open == null || close == null) return false;
    
    // Handle overnight schedules (e.g., 22:00 - 02:00)
    if (close < open) {
      return hour >= open || hour <= close;
    }
    
    // Include both opening and closing hour
    // e.g., if gym is open 07:00-23:59, show hours 7 through 23
    return hour >= open && hour <= close;
  }

  /// Get today's day of week in lowercase (monday, tuesday, etc.)
  static String getTodayDayOfWeek() {
    final now = DateTime.now();
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days[now.weekday - 1];
  }

  @override
  String toString() {
    return 'GymSchedule(day: $dayOfWeek, open: $openTime, close: $closeTime, closed: $isClosed)';
  }
}

