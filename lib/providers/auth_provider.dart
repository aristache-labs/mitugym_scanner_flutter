import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/auth_session.dart';
import '../services/auth_service.dart';
import 'config_provider.dart';

/// Authentication state
class AuthState {
  final bool isAuthenticated;
  final AuthSession? session;
  final bool isValidating;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.session,
    this.isValidating = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    AuthSession? session,
    bool? isValidating,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      session: session ?? this.session,
      isValidating: isValidating ?? this.isValidating,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Authentication provider notifier
class AuthNotifier extends Notifier<AuthState> {
  final Logger _logger = Logger();
  AuthService? _authService;

  @override
  AuthState build() {
    // Initialize with saved session
    _initializeSession();
    return const AuthState();
  }

  /// Initialize session from storage
  Future<void> _initializeSession() async {
    final session = await AuthSession.load();
    if (session != null) {
      state = state.copyWith(
        isAuthenticated: true,
        session: session,
      );
    }
  }

  /// Get or create auth service
  AuthService _getAuthService() {
    if (_authService == null) {
      final config = ref.read(configProvider);
      _authService = AuthService(apiUrl: config.apiUrl);
    }
    return _authService!;
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
    String? deviceName,
    bool isOffline = false,
    bool rememberMe = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authService = _getAuthService();
      final session = isOffline
          ? await authService.offlineLogin(
              email: email,
              password: password,
              deviceName: deviceName,
            )
          : await authService.login(
              email: email,
              password: password,
              deviceName: deviceName,
              rememberMe: rememberMe,
            );

      state = state.copyWith(
        isAuthenticated: true,
        session: session,
        isLoading: false,
        error: null,
      );

      _logger.i('Login successful for: $email (offline: $isOffline)');
      return true;
    } catch (e) {
      _logger.e('Login failed: $e');
      state = state.copyWith(
        isAuthenticated: false,
        session: null,
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Validate session on startup
  Future<bool> validateOnStartup() async {
    final session = await AuthSession.load();
    if (session == null) {
      _logger.i('No saved session found');
      return false;
    }

    // If session doesn't need revalidation, consider it valid
    if (!session.needsRevalidation()) {
      _logger.i('Session is recent, skipping validation');
      state = state.copyWith(
        isAuthenticated: true,
        session: session,
      );
      return true;
    }

    // Validate with server
    state = state.copyWith(isValidating: true);

    try {
      final authService = _getAuthService();
      final isValid = await authService.validateSession(session.apiKey);

      if (isValid) {
        // Reload session (may have been updated by validation)
        final updatedSession = await AuthSession.load();
        state = state.copyWith(
          isAuthenticated: true,
          session: updatedSession ?? session,
          isValidating: false,
        );
        _logger.i('Session validation successful');
        return true;
      } else {
        // Invalid session, clear it
        await AuthSession.clear();
        state = state.copyWith(
          isAuthenticated: false,
          session: null,
          isValidating: false,
        );
        _logger.w('Session validation failed');
        return false;
      }
    } catch (e) {
      _logger.e('Session validation error: $e');
      // On error, allow offline use with existing session
      state = state.copyWith(
        isAuthenticated: true,
        session: session,
        isValidating: false,
      );
      return true;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final authService = _getAuthService();
      await authService.logout();

      state = const AuthState(
        isAuthenticated: false,
        session: null,
      );

      _logger.i('Logout successful');
    } catch (e) {
      _logger.e('Logout error: $e');
      // Still clear state even on error
      state = const AuthState(
        isAuthenticated: false,
        session: null,
      );
    }
  }

  /// Update last validated timestamp
  Future<void> updateLastValidated() async {
    final session = state.session;
    if (session != null) {
      final updatedSession = session.copyWith(
        lastValidated: DateTime.now(),
      );
      await updatedSession.save();
      state = state.copyWith(session: updatedSession);
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for authentication state
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

