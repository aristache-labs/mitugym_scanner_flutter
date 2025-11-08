import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config/app_themes.dart';
import '../config/app_colors.dart';
import '../providers/history_provider.dart';
import '../models/activity_log.dart';
import '../l10n/app_localizations.dart';

/// Modern dashboard-style sidebar widget
class ModernSidebarWidget extends ConsumerStatefulWidget {
  final AppThemeColors themeColors;
  final int selectedIndex;
  final Function(int) onNavigate;
  final VoidCallback onExport;

  const ModernSidebarWidget({
    super.key,
    required this.themeColors,
    required this.selectedIndex,
    required this.onNavigate,
    required this.onExport,
  });

  @override
  ConsumerState<ModernSidebarWidget> createState() => _ModernSidebarWidgetState();
}

class _ModernSidebarWidgetState extends ConsumerState<ModernSidebarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0F0F), // Very dark background
              const Color(0xFF0D1515).withValues(alpha: 0.95), // Dark with slight green tint
              const Color(0xFF0F1A1A).withValues(alpha: 0.9), // Subtle cyan/green gradient
              const Color(0xFF0A0F0F), // Back to dark at bottom
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(4, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // Compact icon navigation menu
            _buildCompactNavigationMenu(),
            
            const SizedBox(height: 24),
            
            // Stats section
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildCompactStatsCard(historyState),
                  const SizedBox(height: 24),
                  
                  // Recent Activity (compact)
                  _buildCompactActivityCard(historyState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build compact icon-based navigation menu like the image
  Widget _buildCompactNavigationMenu() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          _buildCompactNavItem(
            icon: LucideIcons.home,
            label: l10n.navDashboard,
            isActive: widget.selectedIndex == 0,
            onTap: () => widget.onNavigate(0),
          ),
          _buildMenuSeparator(),
          _buildCompactNavItem(
            icon: LucideIcons.qrCode,
            label: l10n.navQRScanner,
            isActive: widget.selectedIndex == 1,
            onTap: () => widget.onNavigate(1),
          ),
          _buildMenuSeparator(),
          _buildCompactNavItem(
            icon: LucideIcons.activity,
            label: l10n.navCheckIns,
            isActive: widget.selectedIndex == 2,
            onTap: () => widget.onNavigate(2),
          ),
          _buildMenuSeparator(),
          _buildCompactNavItem(
            icon: LucideIcons.history,
            label: l10n.navHistory,
            isActive: widget.selectedIndex == 3,
            onTap: () => widget.onNavigate(3),
          ),
          _buildMenuSeparator(),
          _buildCompactNavItem(
            icon: LucideIcons.users,
            label: l10n.navMembers,
            isActive: widget.selectedIndex == 4,
            onTap: () => widget.onNavigate(4),
          ),
          _buildMenuSeparator(),
          _buildCompactNavItem(
            icon: LucideIcons.settings,
            label: l10n.navSettings,
            isActive: widget.selectedIndex == 5,
            onTap: () => widget.onNavigate(5),
          ),
        ],
      ),
    );
  }

  /// Build elegant menu separator
  Widget _buildMenuSeparator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.border.withValues(alpha: 0.3),
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.border.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  /// Build elegant stat separator
  Widget _buildStatSeparator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.border.withValues(alpha: 0.2),
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.border.withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  /// Build compact navigation item
  Widget _buildCompactNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return _AnimatedNavItem(
      isActive: isActive,
      onTap: onTap,
      icon: icon,
      label: label,
    );
  }

  /// Build compact stats card
  Widget _buildCompactStatsCard(HistoryState historyState) {
    final l10n = AppLocalizations.of(context)!;
    
    // Filter for today's activities from the full history
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    final todayActivities = historyState.items.where((a) => 
        a.time.isAfter(todayStart) && a.time.isBefore(todayEnd));
    
    // Count check-ins: activities with checkInTime set and successful
    final todayCheckIns = todayActivities
        .where((a) => a.success && a.checkInTime != null)
        .length;
    
    // Count check-outs: activities with checkOutTime set and successful
    final todayCheckOuts = todayActivities
        .where((a) => a.success && a.checkOutTime != null)
        .length;
    
    final todayDenied = todayActivities
        .where((a) => !a.success)
        .length;
    
    final totalScans = todayActivities.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.6),
            AppColors.surface.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  LucideIcons.barChart3,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.todayStats,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildCompactStatRow(
            icon: LucideIcons.userCheck,
            label: l10n.checkIns,
            value: '$todayCheckIns',
            color: AppColors.success,
          ),
          _buildStatSeparator(),
          _buildCompactStatRow(
            icon: LucideIcons.userMinus,
            label: l10n.checkOuts,
            value: '$todayCheckOuts',
            color: AppColors.warning,
          ),
          _buildStatSeparator(),
          _buildCompactStatRow(
            icon: LucideIcons.userX,
            label: l10n.denied,
            value: '$todayDenied',
            color: AppColors.error,
          ),
          _buildStatSeparator(),
          _buildCompactStatRow(
            icon: LucideIcons.scanLine,
            label: l10n.totalScans,
            value: '$totalScans',
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  /// Build compact stat row
  Widget _buildCompactStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Build compact activity card
  Widget _buildCompactActivityCard(HistoryState historyState) {
    final l10n = AppLocalizations.of(context)!;
    final recentActivities = historyState.items.take(4).toList();

    if (recentActivities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.6),
            AppColors.surface.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.recent,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recentActivities.map((activity) => _buildCompactActivityItem(activity)),
        ],
      ),
    );
  }

  /// Build compact activity item
  Widget _buildCompactActivityItem(ActivityLog activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activity.success ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              activity.memberName,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom animated navigation item with professional scale and fade animation
class _AnimatedNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _AnimatedNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isActive,
  });

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  gradient: widget.isActive
                      ? LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.15),
                            AppColors.primary.withValues(alpha: 0.05),
                          ],
                        )
                      : _isHovered
                          ? LinearGradient(
                              colors: [
                                AppColors.surface.withValues(alpha: 0.8),
                                AppColors.surface.withValues(alpha: 0.4),
                              ],
                            )
                          : null,
                  borderRadius: BorderRadius.circular(12),
                  border: widget.isActive
                      ? Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1,
                        )
                      : _isHovered
                          ? Border.all(
                              color: AppColors.border.withValues(alpha: 0.2),
                              width: 1,
                            )
                          : null,
                  boxShadow: _isHovered && !widget.isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.isActive 
                          ? AppColors.primary 
                          : _isHovered
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                      size: 22,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.label,
                      style: GoogleFonts.inter(
                        color: widget.isActive 
                            ? AppColors.primary 
                            : _isHovered
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
