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
      return _handleDioError(e);
    } catch (e) {
      _logger.e('Unexpected error: $e');
      return ScanResult.error('Unexpected error: $e');
    }
  }

  /// Handle Dio errors and convert to user-friendly messages
  ScanResult _handleDioError(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return ScanResult.error('Unauthorized: Invalid API key');
      case 403:
        return ScanResult.error('Forbidden: Access denied');
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

