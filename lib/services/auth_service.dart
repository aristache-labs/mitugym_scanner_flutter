import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_session.dart';
import 'logger_service.dart';

/// Authentication service for login and session management
class AuthService {
  final Dio _dio;
  final Logger _logger = Logger();
  final LoggerService? _verboseLogger;
  final String apiUrl;

  AuthService({
    required this.apiUrl,
    LoggerService? verboseLogger,
  }) : _dio = Dio(), _verboseLogger = verboseLogger {
    _dio.options.baseUrl = apiUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
    
    _verboseLogger?.logDebug('AuthService initialized with URL: $apiUrl', source: 'AuthService');
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
      _verboseLogger?.logDebug('Starting login request for email: $email', source: 'AuthService');
      _verboseLogger?.logDebug('Device name: ${deviceName ?? "Scanner App"}', source: 'AuthService');

      final stopwatch = Stopwatch()..start();
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
          'device_name': deviceName ?? 'Scanner App',
        },
      );
      stopwatch.stop();

      _verboseLogger?.logDebug('Login response received in ${stopwatch.elapsedMilliseconds}ms - Status: ${response.statusCode}', source: 'AuthService');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          _logger.i('Login successful for: $email');
          _verboseLogger?.logDebug('Parsing login response data', source: 'AuthService');

          final session = AuthSession(
            email: data['email'] as String,
            apiKey: data['api_key'] as String,
            userName: data['user_name'] as String,
            locationName: data['location_name'] as String,
            avatarUrl: data['avatar_url'] as String?,
            loginTime: DateTime.now(),
            lastValidated: DateTime.now(),
          );

          _verboseLogger?.logDebug('Created session for user: ${session.userName} at location: ${session.locationName}', source: 'AuthService');

          // Save session
          await session.save();
          _verboseLogger?.logDebug('Session saved successfully', source: 'AuthService');

          // Save cached credentials for offline login
          await AuthSession.saveCachedCredentials(email, password);
          _verboseLogger?.logDebug('Cached credentials saved for offline login', source: 'AuthService');

          // Save session data for offline login restoration
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('last_user_name', session.userName);
          await prefs.setString('last_location_name', session.locationName);
          await prefs.setString('last_api_key', session.apiKey);
          if (session.avatarUrl != null) {
            await prefs.setString('last_avatar_url', session.avatarUrl!);
          }
          _verboseLogger?.logDebug('Session data cached for offline login', source: 'AuthService');

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
      _verboseLogger?.logDebug('Starting session validation', source: 'AuthService');

      final stopwatch = Stopwatch()..start();
      final response = await _dio.post(
        '/api/auth/validate',
        data: {
          'api_key': apiKey,
        },
      );
      stopwatch.stop();

      _verboseLogger?.logDebug('Validation response received in ${stopwatch.elapsedMilliseconds}ms - Status: ${response.statusCode}', source: 'AuthService');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['valid'] == true) {
          _logger.i('Session validation successful');
          _verboseLogger?.logDebug('Session is valid', source: 'AuthService');

          // Update last validated timestamp
          final session = await AuthSession.load();
          if (session != null) {
            final updatedSession = session.copyWith(
              lastValidated: DateTime.now(),
              userName: data['user_name'] as String,
              locationName: data['location_name'] as String,
              avatarUrl: data['avatar_url'] as String?,
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
  /// Note: Cached credentials are NOT cleared to allow offline login in the future
  Future<void> logout() async {
    try {
      _logger.i('Logging out...');
      await AuthSession.clear();
      _logger.i('Session cleared (cached credentials preserved for offline login)');
    } catch (e) {
      _logger.e('Logout error: $e');
      // Still try to clear even if there's an error
      await AuthSession.clear();
    }
  }

  /// Offline login with cached credentials
  /// Returns AuthSession on success, throws exception on failure
  /// This allows users to login offline if they've successfully logged in before
  Future<AuthSession> offlineLogin({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    try {
      _logger.i('Attempting offline login for: $email');
      _verboseLogger?.logDebug('Starting offline login validation', source: 'AuthService');

      // Validate against cached credentials
      final isValid = await AuthSession.validateCachedCredentials(email, password);
      
      if (!isValid) {
        _logger.w('Offline login failed: Invalid credentials');
        throw Exception('Invalid email or password');
      }

      // Try to load existing session
      final existingSession = await AuthSession.load();
      
      if (existingSession != null && existingSession.email == email) {
        // Session exists and matches - restore it
        _logger.i('Offline login successful for: $email');
        _verboseLogger?.logDebug('Restoring existing session for: ${existingSession.userName}', source: 'AuthService');
        return existingSession;
      }

      // Session doesn't exist (was cleared on logout) - check if we have cached session data
      // We need to load the last known session data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final lastUserName = prefs.getString('last_user_name');
      final lastLocationName = prefs.getString('last_location_name');
      final lastApiKey = prefs.getString('last_api_key');
      final lastAvatarUrl = prefs.getString('last_avatar_url');
      
      if (lastUserName == null || lastLocationName == null || lastApiKey == null) {
        _logger.w('Offline login failed: No cached session data found');
        throw Exception('No saved session data found. Please login online first.');
      }

      // Create a new session from cached data
      final session = AuthSession(
        email: email,
        apiKey: lastApiKey,
        userName: lastUserName,
        locationName: lastLocationName,
        avatarUrl: lastAvatarUrl,
        loginTime: DateTime.now(),
        lastValidated: DateTime.now(),
      );

      // Save the session
      await session.save();
      
      _logger.i('Offline login successful for: $email (recreated session from cache)');
      _verboseLogger?.logDebug('Recreated session for: ${session.userName}', source: 'AuthService');

      return session;
    } catch (e) {
      _logger.e('Offline login error: $e');
      rethrow;
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

