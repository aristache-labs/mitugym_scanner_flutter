import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config/app_themes.dart';
import '../config/app_colors.dart';
import '../providers/history_provider.dart';
import '../models/activity_log.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          _buildCompactNavItem(
            icon: LucideIcons.home,
            label: 'Dashboard',
            isActive: widget.selectedIndex == 0,
            onTap: () => widget.onNavigate(0),
          ),
          _buildCompactNavItem(
            icon: LucideIcons.qrCode,
            label: 'QR Scanner',
            isActive: widget.selectedIndex == 1,
            onTap: () => widget.onNavigate(1),
          ),
          _buildCompactNavItem(
            icon: LucideIcons.activity,
            label: 'Check-ins',
            isActive: widget.selectedIndex == 2,
            onTap: () => widget.onNavigate(2),
          ),
          _buildCompactNavItem(
            icon: LucideIcons.history,
            label: 'History',
            isActive: widget.selectedIndex == 3,
            onTap: () => widget.onNavigate(3),
          ),
          _buildCompactNavItem(
            icon: LucideIcons.users,
            label: 'Members',
            isActive: widget.selectedIndex == 4,
            onTap: () => widget.onNavigate(4),
          ),
          _buildCompactNavItem(
            icon: LucideIcons.settings,
            label: 'Settings',
            isActive: widget.selectedIndex == 5,
            onTap: () => widget.onNavigate(5),
          ),
        ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build compact stats card
  Widget _buildCompactStatsCard(HistoryState historyState) {
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Today\'s Stats',
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
            icon: Icons.login_rounded,
            label: 'Check-ins',
            value: '$todayCheckIns',
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildCompactStatRow(
            icon: Icons.logout_rounded,
            label: 'Check-outs',
            value: '$todayCheckOuts',
            color: AppColors.warning,
          ),
          const SizedBox(height: 12),
          _buildCompactStatRow(
            icon: Icons.block_rounded,
            label: 'Denied',
            value: '$todayDenied',
            color: AppColors.error,
          ),
          const SizedBox(height: 12),
          _buildCompactStatRow(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Total Scans',
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
                'Recent',
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
