/// Admin Notification Model
/// Represents a notification for admin staff users
class AdminNotification {
  final String id;
  final String? memberId; // NULL for admin notifications
  final NotificationType type;
  final String title;
  final String message;
  final String? referenceId;
  final String? referenceType;
  final bool isGlobal;
  final bool isAdminOnly; // TRUE for admin-only notifications (not shown in mobile app)
  final bool isRead;
  final DateTime createdAt;

  AdminNotification({
    required this.id,
    this.memberId,
    required this.type,
    required this.title,
    required this.message,
    this.referenceId,
    this.referenceType,
    required this.isGlobal,
    required this.isAdminOnly,
    required this.isRead,
    required this.createdAt,
  });

  /// Create from JSON
  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: json['id'] as String,
      memberId: json['member_id'] as String?,
      type: NotificationType.fromString(json['type'] as String),
      title: json['title'] as String,
      message: json['message'] as String,
      referenceId: json['reference_id'] as String?,
      referenceType: json['reference_type'] as String?,
      isGlobal: json['is_global'] as bool,
      isAdminOnly: json['is_admin_only'] as bool,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_id': memberId,
      'type': type.value,
      'title': title,
      'message': message,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'is_global': isGlobal,
      'is_admin_only': isAdminOnly,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with method for updates
  AdminNotification copyWith({
    String? id,
    String? memberId,
    NotificationType? type,
    String? title,
    String? message,
    String? referenceId,
    String? referenceType,
    bool? isGlobal,
    bool? isAdminOnly,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AdminNotification(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      isGlobal: isGlobal ?? this.isGlobal,
      isAdminOnly: isAdminOnly ?? this.isAdminOnly,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Notification Type enum
enum NotificationType {
  servicePurchase('service_purchase'),
  sessionBooking('session_booking'),
  sessionUpdated('session_updated'),
  sessionCancelled('session_cancelled'),
  announcement('announcement'),
  gymScheduleUpdated('gym_schedule_updated');

  final String value;

  const NotificationType(this.value);

  /// Convert from string
  static NotificationType fromString(String value) {
    switch (value) {
      case 'service_purchase':
        return NotificationType.servicePurchase;
      case 'session_booking':
        return NotificationType.sessionBooking;
      case 'session_updated':
        return NotificationType.sessionUpdated;
      case 'session_cancelled':
        return NotificationType.sessionCancelled;
      case 'announcement':
        return NotificationType.announcement;
      case 'gym_schedule_updated':
        return NotificationType.gymScheduleUpdated;
      default:
        return NotificationType.announcement;
    }
  }

  /// Get notification icon emoji
  String get icon {
    switch (this) {
      case NotificationType.servicePurchase:
        return '💳';
      case NotificationType.sessionBooking:
        return '📅';
      case NotificationType.sessionUpdated:
        return '📝';
      case NotificationType.sessionCancelled:
        return '❌';
      case NotificationType.announcement:
        return '📢';
      case NotificationType.gymScheduleUpdated:
        return '🕐';
    }
  }

  /// Get toast type based on notification type
  ToastType get toastType {
    switch (this) {
      case NotificationType.servicePurchase:
      case NotificationType.sessionBooking:
        return ToastType.success;
      case NotificationType.sessionUpdated:
        return ToastType.warning;
      case NotificationType.sessionCancelled:
        return ToastType.error;
      default:
        return ToastType.success;
    }
  }
}

/// Toast Type enum for UI display
enum ToastType {
  success,
  warning,
  error;
}
