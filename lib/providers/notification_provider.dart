import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_notification.dart';
import '../services/notification_service.dart';
import 'config_provider.dart';

/// Notification state
class NotificationState {
  final List<AdminNotification> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<AdminNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final config = ref.watch(configProvider);
  return NotificationService(
    apiUrl: config.apiUrl,
    apiKey: config.apiKey,
  );
});

/// Notification provider
final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(() {
  return NotificationNotifier();
});

/// Notification notifier
class NotificationNotifier extends Notifier<NotificationState> {
  Timer? _refreshTimer;
  
  @override
  NotificationState build() {
    // Set up periodic refresh every 30 seconds after initialization
    Future.microtask(() {
      fetchNotifications();
      _startPeriodicRefresh();
    });
    
    return NotificationState();
  }
  
  NotificationService get _notificationService => ref.read(notificationServiceProvider);

  /// Start periodic refresh of notifications
  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchNotifications(silent: true);
    });
  }

  /// Fetch notifications from server
  Future<void> fetchNotifications({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final notifications = await _notificationService.fetchNotifications(
        limit: 20,
        unreadOnly: false,
      );

      final unreadCount = notifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
        error: null,
      );

      debugPrint('✅ Fetched ${notifications.length} notifications ($unreadCount unread)');
    } catch (e) {
      debugPrint('❌ Error fetching notifications: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markAsRead(notificationId);
      
      if (success) {
        // Update local state
        final updatedNotifications = state.notifications.map((n) {
          if (n.id == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();

        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        );
      }
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final success = await _notificationService.markAllAsRead();
      
      if (success) {
        // Update local state
        final updatedNotifications = state.notifications.map((n) {
          return n.copyWith(isRead: true);
        }).toList();

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        );
      }
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final success = await _notificationService.deleteNotification(notificationId);
      
      if (success) {
        // Find the notification to check if it was unread
        final notification = state.notifications.firstWhere(
          (n) => n.id == notificationId,
          orElse: () => state.notifications.first,
        );
        
        // Update local state
        final updatedNotifications = state.notifications
            .where((n) => n.id != notificationId)
            .toList();

        final unreadCount = notification.isRead
            ? state.unreadCount
            : (state.unreadCount - 1).clamp(0, double.infinity).toInt();

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        );
      }
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
    }
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    try {
      final success = await _notificationService.deleteAllNotifications();
      
      if (success) {
        state = state.copyWith(
          notifications: [],
          unreadCount: 0,
        );
      }
    } catch (e) {
      debugPrint('❌ Error deleting all notifications: $e');
    }
  }

  /// Add a new notification (from realtime subscription)
  void addNotification(AdminNotification notification) {
    final updatedNotifications = [notification, ...state.notifications];
    final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: unreadCount,
    );

    debugPrint('✅ Added new notification: ${notification.title}');
  }
}
