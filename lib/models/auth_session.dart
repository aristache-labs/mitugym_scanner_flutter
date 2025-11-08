import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Authentication session model
/// Stores user session information including API key and validation status
class AuthSession {
  final String email;
  final String apiKey;
  final String userName;
  final String locationName;
  final String? avatarUrl;
  final DateTime loginTime;
  final DateTime? lastValidated;

  const AuthSession({
    required this.email,
    required this.apiKey,
    required this.userName,
    required this.locationName,
    this.avatarUrl,
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
      avatarUrl: json['avatar_url'] as String?,
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
      'avatar_url': avatarUrl,
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
    String? avatarUrl,
    DateTime? loginTime,
    DateTime? lastValidated,
  }) {
    return AuthSession(
      email: email ?? this.email,
      apiKey: apiKey ?? this.apiKey,
      userName: userName ?? this.userName,
      locationName: locationName ?? this.locationName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
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
    if (jsonData['avatar_url'] != null) {
      await prefs.setString('auth_avatar_url', jsonData['avatar_url']);
    }
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
    final avatarUrl = prefs.getString('auth_avatar_url');
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
      avatarUrl: avatarUrl,
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
    await prefs.remove('auth_avatar_url');
    await prefs.remove('auth_login_time');
    await prefs.remove('auth_last_validated');
  }

  /// Check if session needs revalidation (older than 24 hours)
  bool needsRevalidation() {
    if (lastValidated == null) return true;
    final difference = DateTime.now().difference(lastValidated!);
    return difference.inHours >= 24;
  }

  // ============================================================================
  // Cached Credentials Management (for offline login)
  // ============================================================================

  /// Hash a password using SHA256
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Save cached credentials for offline login (email + password hash)
  /// This allows users to login offline if they've successfully logged in before
  static Future<void> saveCachedCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final passwordHash = _hashPassword(password);
    
    await prefs.setString('cached_email', email);
    await prefs.setString('cached_password_hash', passwordHash);
  }

  /// Check if cached credentials exist
  static Future<bool> hasCachedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedEmail = prefs.getString('cached_email');
    final cachedHash = prefs.getString('cached_password_hash');
    
    return cachedEmail != null && cachedHash != null;
  }

  /// Validate credentials against cached credentials
  /// Returns true if the provided email and password match the cached ones
  static Future<bool> validateCachedCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedEmail = prefs.getString('cached_email');
    final cachedHash = prefs.getString('cached_password_hash');
    
    if (cachedEmail == null || cachedHash == null) {
      return false;
    }
    
    final providedHash = _hashPassword(password);
    return cachedEmail == email && cachedHash == providedHash;
  }

  /// Clear cached credentials
  static Future<void> clearCachedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_email');
    await prefs.remove('cached_password_hash');
  }
}

