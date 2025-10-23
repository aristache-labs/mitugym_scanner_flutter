import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../services/audio_service.dart';
import '../providers/auth_provider.dart';
import '../providers/offline_provider.dart';
import '../providers/history_provider.dart';
import '../providers/gym_schedule_provider.dart';
import 'main_layout_screen.dart';
import 'login_screen.dart';

/// Splash screen with animated logo and loading indicator
/// Preloads configuration and services during animation
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String _loadingText = 'Initializing scanner...';
  
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    try {
      // Run initialization tasks in parallel during splash animation
      await Future.wait([
        _preloadConfiguration(),
        _initializeServices(),
        _checkAuthentication(),
        Future.delayed(const Duration(seconds: 3)), // Minimum splash time
      ]);
      
      // After authentication, preload app data if authenticated
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        await _preloadAppData();
      }
    } catch (e) {
      // Log error but continue
      debugPrint('Initialization error: $e');
    }
    
    if (mounted) {
      // Check authentication status
      final authState = ref.read(authProvider);
      final isOnline = ref.read(offlineProvider).isOnline;
      
      Widget destination;
      
      if (!authState.isAuthenticated) {
        // No session, go to login
        destination = const LoginScreen();
        debugPrint('No session found, redirecting to login');
      } else if (isOnline && authState.session!.needsRevalidation()) {
        // Online and needs revalidation - validate was already called in _checkAuthentication
        // Check if still valid after validation
        final currentAuthState = ref.read(authProvider);
        destination = currentAuthState.isAuthenticated 
            ? const MainLayoutScreen() 
            : const LoginScreen();
        debugPrint('Session validated: ${currentAuthState.isAuthenticated}');
      } else {
        // Has valid session or offline (allow offline use)
        destination = const MainLayoutScreen();
        debugPrint('Valid session, proceeding to main app');
      }
      
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  Future<void> _preloadConfiguration() async {
    if (mounted) {
      setState(() => _loadingText = 'Loading configuration...');
    }
    
    // Configuration loads automatically via provider
    // Just give it time to complete
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _initializeServices() async {
    if (mounted) {
      setState(() => _loadingText = 'Preparing services...');
    }
    
    // Preload audio files for instant playback
    await _preloadAudio();
  }

  Future<void> _preloadAudio() async {
    try {
      // Preload audio files
      final audioService = AudioService();
      await audioService.initialize();
      // Don't dispose - will be reused later
      debugPrint('Audio service initialized');
    } catch (e) {
      debugPrint('Audio preload error: $e');
    }
  }

  Future<void> _checkAuthentication() async {
    if (mounted) {
      setState(() => _loadingText = 'Checking authentication...');
    }
    
    try {
      // Validate session on startup (if exists)
      await ref.read(authProvider.notifier).validateOnStartup();
      debugPrint('Authentication check completed');
    } catch (e) {
      debugPrint('Authentication check error: $e');
    }
  }

  /// Preload app data (history, gym schedule, etc.)
  Future<void> _preloadAppData() async {
    try {
      // Check if online before loading from server
      final isOnline = ref.read(offlineProvider).isOnline;
      
      if (isOnline) {
        if (mounted) {
          setState(() => _loadingText = 'Loading history from server...');
        }
        
        // Sync history from server (last 90 days)
        await ref.read(historyProvider.notifier).syncFromServer();
        debugPrint('✅ History synced from server during splash');
        
        if (mounted) {
          setState(() => _loadingText = 'Loading gym schedule...');
        }
        
        // Load gym schedule for today
        await ref.read(gymScheduleProvider.notifier).fetchSchedule();
        debugPrint('✅ Gym schedule loaded during splash');
      } else {
        // Offline - load from local database
        if (mounted) {
          setState(() => _loadingText = 'Loading cached data...');
        }
        
        await ref.read(historyProvider.notifier).loadInitialHistory();
        debugPrint('✅ History loaded from cache during splash (offline)');
      }
    } catch (e) {
      debugPrint('App data preload error: $e');
      // Don't block navigation on error, just log it
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              AppColors.accent.withValues(alpha: 0.12),
              AppColors.background,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles/dots
            ...List.generate(20, (index) {
              final random = (index * 137.5) % 100;
              return Positioned(
                left: (random * 10) % MediaQuery.of(context).size.width,
                top: ((random * 20) % MediaQuery.of(context).size.height),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .fadeIn(duration: 2000.ms, delay: (index * 100).ms)
                    .fadeOut(duration: 2000.ms, delay: (index * 100).ms),
              );
            }),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with glow effect and animations
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 60,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Container(
                        color: AppColors.background,
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                        duration: 2500.ms,
                        color: AppColors.accent.withValues(alpha: 0.3),
                      )
                      .animate()
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        duration: 800.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 600.ms)
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .then()
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.05, 1.05),
                        duration: 1500.ms,
                        curve: Curves.easeInOut,
                      ),

                  const SizedBox(height: 50),

                  // App title with gradient effect
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.accent,
                        AppColors.primary,
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'MITUGYM',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 6,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 300.ms)
                      .slideY(begin: 0.3, duration: 800.ms, delay: 300.ms, curve: Curves.easeOut)
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                        duration: 3000.ms,
                        delay: 1000.ms,
                        color: AppColors.accent.withValues(alpha: 0.5),
                      ),

                  const SizedBox(height: 12),

                  // Subtitle with typing effect
                  Text(
                    'SCANNER SYSTEM',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary.withValues(alpha: 0.8),
                      letterSpacing: 8,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 500.ms)
                      .slideY(begin: 0.3, duration: 800.ms, delay: 500.ms),

                  const SizedBox(height: 80),

                  // Modern loading indicator
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Circular progress
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          backgroundColor: AppColors.surface,
                        ),
                      ),
                      // Pulsing center dot
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      )
                          .animate(onPlay: (controller) => controller.repeat())
                          .scale(
                            begin: const Offset(1.0, 1.0),
                            end: const Offset(1.5, 1.5),
                            duration: 1000.ms,
                          )
                          .fadeOut(duration: 1000.ms),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 700.ms)
                      .scale(duration: 400.ms, delay: 700.ms),

                  const SizedBox(height: 30),

                  // Loading text with fade animation
                  Text(
                    _loadingText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                      letterSpacing: 1,
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .fadeIn(duration: 1200.ms)
                      .then()
                      .fadeOut(duration: 1200.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

