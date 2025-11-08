import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/offline_provider.dart';
import '../models/auth_session.dart';
import 'main_layout_screen.dart';

/// Login screen for authentication
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if online
    final isOnline = ref.read(offlineProvider).isOnline;
    
    // If offline, check if cached credentials exist
    if (!isOnline) {
      final hasCachedCredentials = await AuthSession.hasCachedCredentials();
      
      if (!hasCachedCredentials) {
        _showError('You must be online for your first login. Once you\'ve logged in successfully, you can login offline.');
        return;
      }
      
      // Attempt offline login
      setState(() => _isLoading = true);
      
      try {
        final success = await ref.read(authProvider.notifier).login(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              deviceName: 'Scanner App',
              isOffline: true,
            );

        if (mounted) {
          if (success) {
            // Navigate to main app
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const MainLayoutScreen(),
              ),
            );
          } else {
            final authState = ref.read(authProvider);
            _showError(authState.error ?? 'Login failed');
          }
        }
      } catch (e) {
        if (mounted) {
          _showError('Offline login failed: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
      return;
    }

    // Online login
    setState(() => _isLoading = true);

    try {
      final success = await ref.read(authProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            deviceName: 'Scanner App',
            isOffline: false,
          );

      if (mounted) {
        if (success) {
          // Navigate to main app
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainLayoutScreen(),
            ),
          );
        } else {
          final authState = ref.read(authProvider);
          _showError(authState.error ?? 'Login failed');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Login failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(offlineProvider).isOnline;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0F), // Dark teal background matching web panel
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              const Color(0xFF1A2222).withValues(alpha: 0.3),
              const Color(0xFF0A0F0F),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo - matching web panel
                    _buildHeader(),
                    const SizedBox(height: 48),

                    // Login form card with title - matching web panel
                    _buildLoginCard(isOnline),
                    const SizedBox(height: 24),

                    // Offline indicator
                    if (!isOnline) _buildOfflineIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Image.asset(
        'assets/images/logo.png',
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to icon if image not found
          return Icon(
            LucideIcons.dumbbell,
            size: 90,
            color: AppColors.primary,
          );
        },
      ),
    );
  }

  Widget _buildLoginCard(bool isOnline) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title - "Staff Portal" inside card, matching web panel
              Center(
                child: Text(
                  'Staff Portal',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Email field
              _buildEmailField(),
              const SizedBox(height: 20),

              // Password field
              _buildPasswordField(),
              const SizedBox(height: 32),

              // Login button
              _buildLoginButton(isOnline),
              const SizedBox(height: 24),
              
              // Contact support text - matching web panel
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Need access? Contact ',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: 'ops@mitugym.dev',
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EMAIL',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !_isLoading,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: '',
            filled: true,
            fillColor: const Color(0xFF1F2A2E), // Dark input background matching web panel
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: const Color(0xFF2A3535).withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.error,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PASSWORD',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          enabled: !_isLoading,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: '',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                color: AppColors.textMuted,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            filled: true,
            fillColor: const Color(0xFF1F2A2E), // Dark input background matching web panel
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: const Color(0xFF2A3535).withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.error,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
          onFieldSubmitted: (_) => _handleLogin(),
        ),
      ],
    );
  }

  Widget _buildLoginButton(bool isOnline) {
    return FutureBuilder<bool>(
      future: AuthSession.hasCachedCredentials(),
      builder: (context, snapshot) {
        final hasCachedCredentials = snapshot.data ?? false;
        // Enable button if online OR if offline with cached credentials
        final isEnabled = !_isLoading && (isOnline || hasCachedCredentials);
        
        return ElevatedButton(
          onPressed: isEnabled ? _handleLogin : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.border,
            disabledForegroundColor: AppColors.textMuted,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                )
              : Text(
                  'Sign In',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
        );
      },
    );
  }

  Widget _buildOfflineIndicator() {
    return FutureBuilder<bool>(
      future: AuthSession.hasCachedCredentials(),
      builder: (context, snapshot) {
        final hasCachedCredentials = snapshot.data ?? false;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: hasCachedCredentials 
                ? AppColors.info.withValues(alpha: 0.1)
                : AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasCachedCredentials 
                  ? AppColors.info.withValues(alpha: 0.3)
                  : AppColors.warning.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasCachedCredentials ? LucideIcons.info : LucideIcons.wifiOff,
                color: hasCachedCredentials ? AppColors.info : AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  hasCachedCredentials
                      ? 'You\'re offline. Offline login available for previous users.'
                      : 'You\'re offline. Please connect to the internet for your first login.',
                  style: GoogleFonts.inter(
                    color: hasCachedCredentials ? AppColors.info : AppColors.warning,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

