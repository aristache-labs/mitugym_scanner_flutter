import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/auth_session.dart';

/// Authentication service for login and session management
class AuthService {
  final Dio _dio;
  final Logger _logger = Logger();
  final String apiUrl;

  AuthService({
    required this.apiUrl,
  }) : _dio = Dio() {
    _dio.options.baseUrl = apiUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  /// Login with email and password
  /// Returns AuthSession on success, throws exception on failure
  Future<AuthSession> login({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    try {
      _logger.i('Attempting login for: $email');

      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
          'device_name': deviceName ?? 'Scanner App',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          _logger.i('Login successful for: $email');

          final session = AuthSession(
            email: data['email'] as String,
            apiKey: data['api_key'] as String,
            userName: data['user_name'] as String,
            locationName: data['location_name'] as String,
            loginTime: DateTime.now(),
            lastValidated: DateTime.now(),
          );

          // Save session
          await session.save();

          return session;
        } else {
          throw Exception(data['error'] ?? 'Login failed');
        }
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Login error: ${e.type} - ${e.message}');
      
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      _logger.e('Unexpected login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  /// Validate existing session with server
  /// Returns true if valid, false if invalid
  Future<bool> validateSession(String apiKey) async {
    try {
      _logger.i('Validating session...');

      final response = await _dio.post(
        '/api/auth/validate',
        data: {
          'api_key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['valid'] == true) {
          _logger.i('Session validation successful');

          // Update last validated timestamp
          final session = await AuthSession.load();
          if (session != null) {
            final updatedSession = session.copyWith(
              lastValidated: DateTime.now(),
              userName: data['user_name'] as String,
              locationName: data['location_name'] as String,
            );
            await updatedSession.save();
          }

          return true;
        } else {
          _logger.w('Session validation failed: ${data['error']}');
          return false;
        }
      } else {
        _logger.w('Session validation failed with status: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      _logger.e('Session validation error: ${e.type} - ${e.message}');
      
      // If it's a network error, consider session valid (offline mode)
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        _logger.i('Network error during validation, allowing offline mode');
        return true; // Allow offline use
      }
      
      return false;
    } catch (e) {
      _logger.e('Unexpected validation error: $e');
      return false;
    }
  }

  /// Logout and clear session
  Future<void> logout() async {
    try {
      _logger.i('Logging out...');
      await AuthSession.clear();
      _logger.i('Session cleared');
    } catch (e) {
      _logger.e('Logout error: $e');
      // Still try to clear even if there's an error
      await AuthSession.clear();
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final session = await AuthSession.load();
    return session != null;
  }

  /// Get current session
  Future<AuthSession?> getCurrentSession() async {
    return await AuthSession.load();
  }
}

