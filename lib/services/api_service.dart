import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/scan_result.dart';
import '../models/member_data.dart';
import '../models/activity_log.dart';

/// API Service for MituGym backend
/// Handles all HTTP requests to the check-in/check-out API
class ApiService {
  final Dio _dio;
  final Logger _logger = Logger();
  final String apiKey;

  ApiService({
    String? apiUrl,
    required this.apiKey,
  }) : _dio = Dio() {
    _dio.options.baseUrl = apiUrl ?? 'https://mitugym-app-webpanel.vercel.app';
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  /// Update the base URL
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// Check in or check out a member
  /// 
  /// [qrCode] - The QR code scanned from member's device
  /// [apiKey] - The API key for authentication
  /// 
  /// Returns a [ScanResult] with success/failure information
  Future<ScanResult> checkInOut(String qrCode, String apiKey) async {
    try {
      _logger.i('Attempting check-in/out for QR: $qrCode');

      final response = await _dio.post(
        '/api/checkin',
        data: {
          'qr_code': qrCode,
          'api_key': apiKey,
          'action': 'auto',
        },
      );

      _logger.i('API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        // Check if the response contains membership_status
        final membershipStatus = data['membership_status'] as String?;
        
        // If membership is expired or inactive, create error result with member data
        if (membershipStatus == 'expired') {
          _logger.w('Membership expired for: ${data['member_name']}');
          final memberData = MemberData.fromJson(data);
          return ScanResult(
            success: false,
            message: 'Membership Expired',
            error: 'Membership expired on ${memberData.formattedExpiryDate}. Please renew to continue.',
            data: memberData,
          );
        } else if (membershipStatus == 'inactive') {
          _logger.w('Membership inactive for: ${data['member_name']}');
          final memberData = MemberData.fromJson(data);
          return ScanResult(
            success: false,
            message: 'Membership Inactive',
            error: 'Membership is inactive. Please contact the gym.',
            data: memberData,
          );
        }
        
        // Otherwise, parse as normal success
        final result = ScanResult.fromJson(data);
        _logger.i('Check-in/out successful: ${result.message}');
        return result;
      } else {
        _logger.w('Unexpected status code: ${response.statusCode}');
        return ScanResult.error('Unexpected response: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('DioException: ${e.type} - ${e.message}');
      // Log response data if available for debugging
      if (e.response?.data != null) {
        _logger.d('Response data: ${e.response!.data}');
      }
      return _handleDioError(e);
    } catch (e) {
      _logger.e('Unexpected error: $e');
      return ScanResult.error('Unexpected error: $e');
    }
  }

  /// Handle Dio errors and convert to user-friendly messages
  ScanResult _handleDioError(DioException e) {
    // Try to extract message from response body
    String? errorMessage;
    String? errorDetail;
    
    if (e.response?.data != null) {
      try {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          errorMessage = data['message'] as String?;
          errorDetail = data['error'] as String?;
          
          // Check if it's a membership status issue
          if (errorMessage?.toLowerCase().contains('inactive') == true ||
              errorMessage?.toLowerCase().contains('expired') == true ||
              errorDetail?.toLowerCase().contains('inactive') == true ||
              errorDetail?.toLowerCase().contains('expired') == true) {
            return ScanResult.error('Membership Inactive: Please renew your membership');
          }
          
          // Return the server's error message if available
          if (errorMessage != null && errorMessage.isNotEmpty) {
            return ScanResult.error(errorMessage);
          }
        }
      } catch (parseError) {
        _logger.d('Could not parse error response: $parseError');
      }
    }

    // Fallback to status code handling
    switch (e.response?.statusCode) {
      case 401:
        return ScanResult.error('Unauthorized: Invalid API key');
      case 403:
        // Check if response has more details
        if (errorDetail != null && errorDetail.isNotEmpty) {
          return ScanResult.error(errorDetail);
        }
        return ScanResult.error('Access Denied: Membership may be inactive or expired');
      case 404:
        return ScanResult.error('Member not found or invalid QR code');
      case 429:
        return ScanResult.error('Too many requests: Please wait and try again');
      case 500:
        return ScanResult.error('Server error: Please try again later');
      default:
        if (e.type == DioExceptionType.connectionTimeout) {
          return ScanResult.error('Connection timeout: Check your internet connection');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          return ScanResult.error('Request timeout: Server took too long to respond');
        } else if (e.type == DioExceptionType.connectionError) {
          return ScanResult.error('Connection error: Unable to reach server');
        } else {
          return ScanResult.error('Network error: ${e.message}');
        }
    }
  }

  /// Fetch history from server (Supabase api_logs table)
  Future<List<ActivityLog>> fetchHistoryFromServer({
    DateTime? sinceDate,
    int limit = 100,
  }) async {
    try {
      _logger.i('Fetching history from server since: $sinceDate');

      // Build query parameters
      final queryParams = <String, dynamic>{
        'api_key': apiKey,
        'limit': limit,
      };

      if (sinceDate != null) {
        queryParams['created_at'] = 'gte.${sinceDate.toIso8601String()}';
      }

      // Fetch from api_logs endpoint
      final response = await _dio.get(
        '/api/history',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Handle the new API response format
        if (responseData is Map<String, dynamic> && responseData['success'] == true) {
          final data = responseData['data'];
          
          if (data is List) {
            return data.map((item) {
              // Parse API log entry to ActivityLog
              final responseDataObj = item['response_data'];
              String? avatarUrl;
              
              // Extract avatar URL from response_data
              if (responseDataObj is Map<String, dynamic>) {
                avatarUrl = responseDataObj['avatar_url'] as String?;
              }
              
              return ActivityLog(
                memberName: item['member_name'] as String? ?? 'Unknown',
                action: item['api_action'] as String? ?? 'checkin',
                time: DateTime.parse(item['created_at'] as String),
                success: true, // Records in api_logs are successful by default
                memberId: item['member_id'] as String?,
                avatarUrl: avatarUrl,
              );
            }).toList();
          }
        }
      }

      _logger.w('Failed to fetch history: ${response.statusCode}');
      return [];
    } on DioException catch (e) {
      _logger.e('Failed to fetch history from server: ${e.message}');
      return [];
    } catch (e) {
      _logger.e('Unexpected error fetching history: $e');
      return [];
    }
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}


