import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/scan_result.dart';
import '../models/member_data.dart';
import '../models/activity_log.dart';
import '../models/gym_schedule.dart';


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
  /// [qrCode] - The QR code scanned from member's device (or just member_id for offline scans)
  /// [apiKey] - The API key for authentication
  /// [isOfflineScan] - Flag to indicate this is an offline scan (skips TOTP validation)
  /// 
  /// Returns a [ScanResult] with success/failure information
  Future<ScanResult> checkInOut(
    String qrCode,
    String apiKey, {
    bool isOfflineScan = false,
  }) async {
    try {
      _logger.i('Attempting check-in/out for QR: $qrCode (offline: $isOfflineScan)');

      final requestData = <String, dynamic>{
        'qr_code': qrCode,
        'api_key': apiKey,
        'action': 'auto',
      };
      
      // Add offline scan flag if true
      if (isOfflineScan) {
        requestData['is_offline_scan'] = true;
      }

      final response = await _dio.post(
        '/api/checkin',
        data: requestData,
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
              // Parse session entry to ActivityLog
              final responseDataObj = item['response_data'];
              String? avatarUrl;
              DateTime? checkInTime;
              DateTime? checkOutTime;
              int? durationMinutes;
              String? method;
              
              // Extract data from response_data
              if (responseDataObj is Map<String, dynamic>) {
                avatarUrl = responseDataObj['avatar_url'] as String?;
                method = responseDataObj['method'] as String?;
                durationMinutes = responseDataObj['duration_minutes'] as int?;
                
                // Parse check-in and check-out times
                if (responseDataObj['check_in_time'] != null) {
                  checkInTime = DateTime.parse(responseDataObj['check_in_time'] as String);
                }
                if (responseDataObj['check_out_time'] != null) {
                  checkOutTime = DateTime.parse(responseDataObj['check_out_time'] as String);
                }
              }
              
              // Use the success field directly from the API response
              final isSuccess = item['success'] as bool? ?? true;
              
              // For denied entries, clear check-in/check-out times since the scan was rejected
              if (!isSuccess) {
                checkInTime = null;
                checkOutTime = null;
                durationMinutes = null;
              }
              
              // Parse full member data if available in response_data
              MemberData? memberData;
              if (responseDataObj is Map<String, dynamic>) {
                try {
                  memberData = MemberData.fromJson(responseDataObj);
                } catch (e) {
                  _logger.w('Failed to parse member data from history: $e');
                }
              }
              
              return ActivityLog(
                memberName: item['member_name'] as String? ?? 'Unknown',
                action: item['api_action'] as String? ?? 'session',
                time: DateTime.parse(item['created_at'] as String),
                success: isSuccess,
                memberId: item['member_id'] as String?,
                avatarUrl: avatarUrl,
                checkInTime: checkInTime,
                checkOutTime: checkOutTime,
                durationMinutes: durationMinutes,
                method: method,
                memberData: memberData, // Store full member data for details modal
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

  /// Fetch gym schedule for today
  /// Returns the schedule for the current day of the week
  Future<GymSchedule?> fetchGymSchedule() async {
    try {
      final today = GymSchedule.getTodayDayOfWeek();
      _logger.i('Fetching gym schedule for: $today');
      _logger.d('Using API key: ${apiKey.substring(0, 10)}...');

      final response = await _dio.get(
        '/api/gym-schedule',
        queryParameters: {
          'api_key': apiKey,
          'day': today,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        _logger.d('Gym schedule API response: $data');

        if (data['success'] == true && data['schedule'] != null) {
          final scheduleData = data['schedule'] as Map<String, dynamic>;
          final schedule = GymSchedule.fromJson(scheduleData);
          _logger.i('✅ Gym schedule loaded: ${schedule.dayOfWeek} - Open: ${schedule.openTime} to ${schedule.closeTime} (Closed: ${schedule.isClosed})');
          return schedule;
        } else {
          _logger.w('No schedule data in response');
          return null;
        }
      } else {
        _logger.w('Failed to fetch gym schedule: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      _logger.e('Failed to fetch gym schedule: ${e.message}');
      return null;
    } catch (e) {
      _logger.e('Unexpected error fetching gym schedule: $e');
      return null;
    }
  }

  /// Test API connectivity and validate all endpoints
  /// Returns a map of endpoint status results
  Future<Map<String, dynamic>> testAllApiEndpoints() async {
    final results = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'baseUrl': _dio.options.baseUrl,
      'endpoints': <String, dynamic>{},
    };

    // Test 1: Gym Schedule API
    try {
      _logger.i('Testing gym schedule API...');
      final schedule = await fetchGymSchedule();
      
      if (schedule != null) {
        results['endpoints']['gym_schedule'] = {
          'status': 'success',
          'available': true,
          'data': {
            'day': schedule.dayOfWeek,
            'open': schedule.openTime,
            'close': schedule.closeTime,
            'isClosed': schedule.isClosed,
          },
        };
      } else {
        results['endpoints']['gym_schedule'] = {
          'status': 'error',
          'error': 'Failed to fetch gym schedule - returned null',
        };
      }
    } catch (e) {
      results['endpoints']['gym_schedule'] = {
        'status': 'error',
        'error': e.toString(),
      };
    }

    // Test 2: History API
    bool historySuccess = false;
    String? historyError;
    int historyCount = 0;
    
    try {
      _logger.i('Testing history API...');
      // Fetch history from last 7 days to avoid parameter issues
      final testDate = DateTime.now().subtract(const Duration(days: 7));
      
      // Direct API call to check if endpoint is working
      final response = await _dio.get(
        '/api/history',
        queryParameters: {
          'api_key': apiKey,
          'limit': 5,
          'created_at': 'gte.${testDate.toIso8601String()}',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData['success'] == true) {
          final data = responseData['data'];
          if (data is List) {
            historySuccess = true;
            historyCount = data.length;
          }
        }
      }
    } catch (e) {
      historyError = e.toString();
    }
    
    if (historySuccess) {
      results['endpoints']['history'] = {
        'status': 'success',
        'recordCount': historyCount,
        'available': true,
      };
    } else {
      results['endpoints']['history'] = {
        'status': 'error',
        'error': historyError ?? 'Failed to fetch history',
      };
    }

    // Test 3: Check-in API (we can't test without a real QR code, but we can test connectivity)
    try {
      _logger.i('Testing check-in API connectivity...');
      
      // First, try GET request to check if endpoint exists (backend has GET method)
      final getResponse = await _dio.get(
        '/api/checkin',
        options: Options(
          validateStatus: (status) => true, // Accept any status code
        ),
      );
      
      _logger.d('Check-in GET test response: ${getResponse.statusCode}');
      
      // If GET returns 200, the endpoint exists and is operational
      if (getResponse.statusCode == 200) {
        results['endpoints']['checkin'] = {
          'status': 'reachable',
          'statusCode': getResponse.statusCode,
          'note': 'Endpoint is operational',
        };
      } else if (getResponse.statusCode == 404) {
        // 404 means the endpoint doesn't exist (wrong URL or not deployed)
        results['endpoints']['checkin'] = {
          'status': 'error',
          'error': 'Endpoint not found (404) - check API URL',
          'statusCode': getResponse.statusCode,
        };
      } else if (getResponse.statusCode != null && getResponse.statusCode! >= 500) {
        // 5xx means server error
        results['endpoints']['checkin'] = {
          'status': 'error',
          'error': 'Server error (${getResponse.statusCode})',
          'statusCode': getResponse.statusCode,
        };
      } else {
        // Any other response means endpoint exists
        results['endpoints']['checkin'] = {
          'status': 'reachable',
          'statusCode': getResponse.statusCode,
          'note': 'Endpoint responded (${getResponse.statusCode})',
        };
      }
    } catch (e) {
      _logger.e('Check-in test error: $e');
      results['endpoints']['checkin'] = {
        'status': 'error',
        'error': e.toString(),
      };
    }

    // Overall health - Check critical endpoints
    final endpoints = results['endpoints'] as Map<String, dynamic>;
    
    // Check if there are authentication errors (401) in other endpoints
    final gymScheduleError = endpoints['gym_schedule']?['error'] as String?;
    final historyErrorMsg = endpoints['history']?['error'] as String?;
    final hasAuthError = (gymScheduleError?.contains('401') == true) || 
                        (historyErrorMsg?.contains('401') == true);
    
    // If authentication failed on other endpoints, mark check-in with a warning
    if (hasAuthError && endpoints['checkin']?['status'] == 'reachable') {
      endpoints['checkin'] = {
        'status': 'warning',
        'statusCode': endpoints['checkin']?['statusCode'],
        'note': 'Endpoint reachable but API key may be invalid',
      };
    }
    
    // Critical endpoints that must succeed for healthy status
    final gymScheduleOk = endpoints['gym_schedule']?['status'] == 'success';
    final historyOk = endpoints['history']?['status'] == 'success';
    final checkinReachable = endpoints['checkin']?['status'] == 'reachable' || 
                             endpoints['checkin']?['status'] == 'success';
    
    // Overall health: degraded if ANY critical endpoint fails
    final criticalEndpointsFailed = !gymScheduleOk || !historyOk;
    final allEndpointsDown = !gymScheduleOk && !historyOk && !checkinReachable;
    
    if (allEndpointsDown) {
      results['overallHealth'] = 'offline';
    } else if (criticalEndpointsFailed) {
      results['overallHealth'] = 'degraded';
    } else {
      results['overallHealth'] = 'healthy';
    }

    _logger.i('API health check complete: ${results['overallHealth']}');
    return results;
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}


