import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../services/audio_service.dart';
import 'home_screen.dart';

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
        Future.delayed(const Duration(seconds: 3)), // Minimum splash time
      ]);
    } catch (e) {
      // Log error but continue to home screen
      debugPrint('Initialization error: $e');
    }
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with glow effect
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 60,
                  color: AppColors.background,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: 2000.ms,
                    color: AppColors.accent.withValues(alpha: 0.3),
                  )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.easeOut),

              const SizedBox(height: 40),

              // App title
              const Text(
                'MituGym',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                  letterSpacing: 2,
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 200.ms)
                  .slideY(begin: 0.3, duration: 800.ms, delay: 200.ms),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'SCANNER',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                  letterSpacing: 4,
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 400.ms)
                  .slideY(begin: 0.3, duration: 800.ms, delay: 400.ms),

              const SizedBox(height: 60),

              // Loading indicator
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 600.ms),

              const SizedBox(height: 20),

              // Loading text - dynamic based on initialization stage
              Text(
                _loadingText,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(duration: 1000.ms)
                  .then()
                  .fadeOut(duration: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }
}

