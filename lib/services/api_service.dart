import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/scan_result.dart';

/// API Service for MituGym backend
/// Handles all HTTP requests to the check-in/check-out API
class ApiService {
  final Dio _dio;
  final Logger _logger = Logger();

  ApiService({String? baseUrl}) : _dio = Dio() {
    _dio.options.baseUrl = baseUrl ?? 'https://mitugym-app-webpanel.vercel.app';
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
        final result = ScanResult.fromJson(response.data as Map<String, dynamic>);
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

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}

