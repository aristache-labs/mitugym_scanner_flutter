import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config/app_colors.dart';
import '../models/admin_notification.dart';

/// Toast container widget that manages all toast notifications
class ToastContainer extends StatefulWidget {
  final Widget child;

  const ToastContainer({
    super.key,
    required this.child,
  });

  @override
  State<ToastContainer> createState() => ToastContainerState();

  /// Show a toast notification
  static void showToast(
    BuildContext context, {
    required ToastType type,
    required String title,
    String? description,
    int durationSeconds = 5,
  }) {
    final state = context.findAncestorStateOfType<ToastContainerState>();
    state?.addToast(
      type: type,
      title: title,
      description: description,
      durationSeconds: durationSeconds,
    );
  }
}

/// Toast container state
class ToastContainerState extends State<ToastContainer> {
  final List<_ToastData> _toasts = [];

  /// Add a toast to the container
  void addToast({
    required ToastType type,
    required String title,
    String? description,
    int durationSeconds = 5,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final toast = _ToastData(
      id: id,
      type: type,
      title: title,
      description: description,
      durationSeconds: durationSeconds,
    );

    setState(() {
      _toasts.add(toast);
    });

    // Auto remove after duration
    Future.delayed(Duration(seconds: durationSeconds), () {
      removeToast(id);
    });
  }

  /// Remove a toast by ID
  void removeToast(String id) {
    setState(() {
      _toasts.removeWhere((t) => t.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main child widget
        widget.child,
        
        // Toast notifications overlay
        if (_toasts.isNotEmpty)
          Positioned(
            top: 80, // Below the app bar
            right: 16,
            child: SizedBox(
              width: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _toasts.map((toast) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ToastItem(
                      toast: toast,
                      onRemove: () => removeToast(toast.id),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}

/// Toast data model
class _ToastData {
  final String id;
  final ToastType type;
  final String title;
  final String? description;
  final int durationSeconds;

  _ToastData({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    required this.durationSeconds,
  });
}

/// Individual toast item widget
class _ToastItem extends StatefulWidget {
  final _ToastData toast;
  final VoidCallback onRemove;

  const _ToastItem({
    required this.toast,
    required this.onRemove,
  });

  @override
  State<_ToastItem> createState() => _ToastItemState();
}

class _ToastItemState extends State<_ToastItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPaused = false;
  Timer? _progressTimer;
  double _progress = 1.0;

  @override
  void initState() {
    super.initState();

    // Set up slide and fade animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<double>(
      begin: 120,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start entrance animation
    _controller.forward();

    // Start progress animation
    _startProgressAnimation();
  }

  void _startProgressAnimation() {
    final duration = widget.toast.durationSeconds * 1000;
    const updateInterval = 16; // ~60fps
    final steps = duration ~/ updateInterval;
    final decrement = 1.0 / steps;

    _progressTimer = Timer.periodic(
      const Duration(milliseconds: updateInterval),
      (timer) {
        if (!_isPaused && mounted) {
          setState(() {
            _progress = (_progress - decrement).clamp(0.0, 1.0);
          });

          if (_progress <= 0) {
            timer.cancel();
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _handleRemove() {
    _controller.reverse().then((_) {
      widget.onRemove();
    });
  }

  void _handleMouseEnter() {
    setState(() {
      _isPaused = true;
    });
  }

  void _handleMouseExit() {
    setState(() {
      _isPaused = false;
    });
  }

  /// Get toast styling based on type
  _ToastStyles _getToastStyles() {
    switch (widget.toast.type) {
      case ToastType.success:
        return _ToastStyles(
          icon: LucideIcons.checkCircle2,
          iconColor: const Color(0xFF22c55e),
          borderColor: const Color(0xFF22c55e).withValues(alpha: 0.2),
          bgGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0e1512), Color(0xFF0a110d)],
          ),
          shadowColor: const Color(0xFF22c55e).withValues(alpha: 0.2),
          progressColor: const Color(0xFF22c55e),
        );
      case ToastType.error:
        return _ToastStyles(
          icon: LucideIcons.xCircle,
          iconColor: const Color(0xFFef4444),
          borderColor: const Color(0xFFef4444).withValues(alpha: 0.2),
          bgGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a0e0e), Color(0xFF140a0a)],
          ),
          shadowColor: const Color(0xFFef4444).withValues(alpha: 0.2),
          progressColor: const Color(0xFFef4444),
        );
      case ToastType.warning:
        return _ToastStyles(
          icon: LucideIcons.alertTriangle,
          iconColor: const Color(0xFFeab308),
          borderColor: const Color(0xFFeab308).withValues(alpha: 0.2),
          bgGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1810), Color(0xFF14120c)],
          ),
          shadowColor: const Color(0xFFeab308).withValues(alpha: 0.2),
          progressColor: const Color(0xFFeab308),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final styles = _getToastStyles();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => _handleMouseEnter(),
        onExit: (_) => _handleMouseExit(),
        child: Container(
          width: 420,
          decoration: BoxDecoration(
            gradient: styles.bgGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: styles.borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: styles.shadowColor,
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top glow line
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      styles.iconColor,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: styles.iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: styles.iconColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        styles.icon,
                        color: styles.iconColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.toast.title,
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          if (widget.toast.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.toast.description!,
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Close button
                    IconButton(
                      onPressed: _handleRemove,
                      icon: const Icon(
                        LucideIcons.x,
                        size: 16,
                      ),
                      color: AppColors.textMuted,
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Progress bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: styles.progressColor.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: FractionallySizedBox(
                  widthFactor: _progress,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: styles.progressColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: styles.progressColor.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Toast styles
class _ToastStyles {
  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final Gradient bgGradient;
  final Color shadowColor;
  final Color progressColor;

  _ToastStyles({
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    required this.bgGradient,
    required this.shadowColor,
    required this.progressColor,
  });
}
