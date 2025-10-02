import 'package:intl/intl.dart';

/// Activity log model
/// Represents a single check-in/check-out activity for display
class ActivityLog {
  final String memberName;
  final String action;
  final DateTime time;
  final bool success;

  const ActivityLog({
    required this.memberName,
    required this.action,
    required this.time,
    required this.success,
  });

  /// Get formatted time string (HH:mm:ss)
  String get formattedTime {
    return DateFormat('HH:mm:ss').format(time);
  }

  /// Get formatted date and time string
  String get formattedDateTime {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(time);
  }

  /// Create a copy with updated fields
  ActivityLog copyWith({
    String? memberName,
    String? action,
    DateTime? time,
    bool? success,
  }) {
    return ActivityLog(
      memberName: memberName ?? this.memberName,
      action: action ?? this.action,
      time: time ?? this.time,
      success: success ?? this.success,
    );
  }

  @override
  String toString() {
    return 'ActivityLog(memberName: $memberName, action: $action, time: $formattedDateTime, success: $success)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActivityLog &&
        other.memberName == memberName &&
        other.action == action &&
        other.time == time &&
        other.success == success;
  }

  @override
  int get hashCode {
    return Object.hash(memberName, action, time, success);
  }
}

