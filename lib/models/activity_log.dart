import 'package:intl/intl.dart';

/// Activity log model
/// Represents a single check-in/check-out session for display
class ActivityLog {
  final String memberName;
  final String action;
  final DateTime time;
  final bool success;
  final String? avatarUrl;
  final String? memberId;
  
  // Session data (for history view)
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final int? durationMinutes;
  final String? method;

  const ActivityLog({
    required this.memberName,
    required this.action,
    required this.time,
    required this.success,
    this.avatarUrl,
    this.memberId,
    this.checkInTime,
    this.checkOutTime,
    this.durationMinutes,
    this.method,
  });

  /// Get member initials for avatar fallback
  String get initials {
    final names = memberName.split(' ');
    if (names.isEmpty) return '?';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  /// Check if member has avatar
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  /// Get formatted time string (HH:mm:ss)
  String get formattedTime {
    return DateFormat('HH:mm:ss').format(time);
  }

  /// Get formatted date and time string
  String get formattedDateTime {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(time);
  }

  /// Check if this is a session entry (has both check-in and check-out times)
  bool get isSession => checkInTime != null && checkOutTime != null;
  
  /// Get formatted duration string
  String get formattedDuration {
    if (durationMinutes == null) return '--';
    final hours = durationMinutes! ~/ 60;
    final minutes = durationMinutes! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Create a copy with updated fields
  ActivityLog copyWith({
    String? memberName,
    String? action,
    DateTime? time,
    bool? success,
    String? avatarUrl,
    String? memberId,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    int? durationMinutes,
    String? method,
  }) {
    return ActivityLog(
      memberName: memberName ?? this.memberName,
      action: action ?? this.action,
      time: time ?? this.time,
      success: success ?? this.success,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      memberId: memberId ?? this.memberId,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      method: method ?? this.method,
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
        other.success == success &&
        other.avatarUrl == avatarUrl &&
        other.memberId == memberId;
  }

  @override
  int get hashCode {
    return Object.hash(memberName, action, time, success, avatarUrl, memberId);
  }
}

