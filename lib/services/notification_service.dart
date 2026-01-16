import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/admin_notification.dart';

/// Service for managing admin notifications
class NotificationService {
  final Dio _dio;
  final String apiKey;
  
  NotificationService({
    required String apiUrl,
    required this.apiKey,
  }) : _dio = Dio() {
    _dio.options.baseUrl = apiUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  /// Fetch notifications from the server
  /// [limit] - Maximum number of notifications to fetch (default: 20)
  /// [unreadOnly] - Whether to fetch only unread notifications
  Future<List<AdminNotification>> fetchNotifications({
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{
        'limit': limit.toString(),
      };
      
      if (unreadOnly) {
        queryParams['unread'] = 'true';
      }

      // Make API request
      final response = await _dio.get(
        '/api/notifications',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final notificationsList = data['notifications'] as List<dynamic>? ?? [];
        
        return notificationsList
            .map((json) => AdminNotification.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch notifications: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching notifications: $e');
      rethrow;
    }
  }

  /// Mark a specific notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      // Make API request
      final response = await _dio.post(
        '/api/notifications',
        data: {
          'notificationId': notificationId,
        },
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Notification marked as read: $notificationId');
        return true;
      } else {
        throw Exception('Failed to mark notification as read: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      // Make API request
      final response = await _dio.post(
        '/api/notifications',
        data: {
          'markAllAsRead': true,
        },
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ All notifications marked as read');
        return true;
      } else {
        throw Exception('Failed to mark all notifications as read: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Delete a specific notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      // Make API request - No Content-Type header needed for query param deletion
      final response = await _dio.delete(
        '/api/notifications',
        queryParameters: {
          'id': notificationId,
        },
        options: Options(
          headers: {
            'x-api-key': apiKey,
          },
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Notification deleted: $notificationId');
        return true;
      } else {
        throw Exception('Failed to delete notification: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
      return false;
    }
  }

  /// Delete all notifications
  Future<bool> deleteAllNotifications() async {
    try {
      // Make API request
      final response = await _dio.delete(
        '/api/notifications',
        data: {
          'deleteAll': true,
        },
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ All notifications deleted');
        return true;
      } else {
        throw Exception('Failed to delete all notifications: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error deleting all notifications: $e');
      return false;
    }
  }
}
