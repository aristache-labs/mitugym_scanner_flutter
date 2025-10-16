import 'package:shared_preferences/shared_preferences.dart';

/// Authentication session model
/// Stores user session information including API key and validation status
class AuthSession {
  final String email;
  final String apiKey;
  final String userName;
  final String locationName;
  final DateTime loginTime;
  final DateTime? lastValidated;

  const AuthSession({
    required this.email,
    required this.apiKey,
    required this.userName,
    required this.locationName,
    required this.loginTime,
    this.lastValidated,
  });

  /// Create session from JSON
  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      email: json['email'] as String,
      apiKey: json['api_key'] as String,
      userName: json['user_name'] as String,
      locationName: json['location_name'] as String,
      loginTime: DateTime.parse(json['login_time'] as String),
      lastValidated: json['last_validated'] != null
          ? DateTime.parse(json['last_validated'] as String)
          : null,
    );
  }

  /// Convert session to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'api_key': apiKey,
      'user_name': userName,
      'location_name': locationName,
      'login_time': loginTime.toIso8601String(),
      'last_validated': lastValidated?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  AuthSession copyWith({
    String? email,
    String? apiKey,
    String? userName,
    String? locationName,
    DateTime? loginTime,
    DateTime? lastValidated,
  }) {
    return AuthSession(
      email: email ?? this.email,
      apiKey: apiKey ?? this.apiKey,
      userName: userName ?? this.userName,
      locationName: locationName ?? this.locationName,
      loginTime: loginTime ?? this.loginTime,
      lastValidated: lastValidated ?? this.lastValidated,
    );
  }

  /// Save session to SharedPreferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = toJson();
    
    await prefs.setString('auth_email', jsonData['email']);
    await prefs.setString('auth_api_key', jsonData['api_key']);
    await prefs.setString('auth_user_name', jsonData['user_name']);
    await prefs.setString('auth_location_name', jsonData['location_name']);
    await prefs.setString('auth_login_time', jsonData['login_time']);
    if (jsonData['last_validated'] != null) {
      await prefs.setString('auth_last_validated', jsonData['last_validated']);
    }
  }

  /// Load session from SharedPreferences
  static Future<AuthSession?> load() async {
    final prefs = await SharedPreferences.getInstance();
    
    final email = prefs.getString('auth_email');
    final apiKey = prefs.getString('auth_api_key');
    final userName = prefs.getString('auth_user_name');
    final locationName = prefs.getString('auth_location_name');
    final loginTimeStr = prefs.getString('auth_login_time');
    final lastValidatedStr = prefs.getString('auth_last_validated');
    
    if (email == null || apiKey == null || userName == null || 
        locationName == null || loginTimeStr == null) {
      return null;
    }
    
    return AuthSession(
      email: email,
      apiKey: apiKey,
      userName: userName,
      locationName: locationName,
      loginTime: DateTime.parse(loginTimeStr),
      lastValidated: lastValidatedStr != null ? DateTime.parse(lastValidatedStr) : null,
    );
  }

  /// Clear session from SharedPreferences
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_email');
    await prefs.remove('auth_api_key');
    await prefs.remove('auth_user_name');
    await prefs.remove('auth_location_name');
    await prefs.remove('auth_login_time');
    await prefs.remove('auth_last_validated');
  }

  /// Check if session needs revalidation (older than 24 hours)
  bool needsRevalidation() {
    if (lastValidated == null) return true;
    final difference = DateTime.now().difference(lastValidated!);
    return difference.inHours >= 24;
  }
}

