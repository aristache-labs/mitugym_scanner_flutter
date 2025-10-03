import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_themes.dart';
import '../config/app_colors.dart';
import '../providers/scan_provider.dart';
import '../providers/config_provider.dart';
import '../providers/windows_scanner_provider.dart';
import '../widgets/collapsible_camera_widget.dart';
import '../widgets/member_info_card.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/control_buttons.dart';
import '../widgets/modern_sidebar_widget.dart';
import '../widgets/offline_banner_widget.dart';
import '../services/export_service.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'search_screen.dart';
import 'history_screen.dart';

/// Home screen - Main scanning interface with premium sidebar layout
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize scanner on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(windowsScannerControllerProvider.notifier).initialize();
      
      // Auto-start scanning if enabled
      final config = ref.read(configProvider);
      if (config.autoStartScanning) {
        ref.read(windowsScannerControllerProvider.notifier).startScanner();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);
    final scannerState = ref.watch(windowsScannerControllerProvider);
    final config = ref.watch(configProvider);
    
    // Get theme colors - Default to purple for dashboard look
    final themeColors = AppThemeColors.getThemeColors(config.theme.isEmpty ? 'purple' : config.theme);

    return Scaffold(
      appBar: _buildModernAppBar(context, scannerState, themeColors),
      body: Container(
        decoration: themeColors.getBackgroundDecoration(),
        child: Column(
          children: [
            // Offline banner (appears when offline)
            const OfflineBannerWidget(),
            
            // Main content with dashboard layout
            Expanded(
              child: Row(
                children: [
                  // Modern Sidebar
                  ModernSidebarWidget(
                    themeColors: themeColors,
                    onExport: () => _showExportDialog(context, ref, themeColors),
                    onSettings: () => _navigateToSettings(context),
                    onStats: () => _navigateToStats(context),
                    onSearch: () => _navigateToSearch(context),
                    onHistory: () => _navigateToHistory(context),
                  ),
                  
                  // Main Content Area - Dashboard style
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dashboard title
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 20),
                            child: Text(
                              'Dashboard',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          
                          // Main dashboard content
                          Expanded(
                            child: Row(
                              children: [
                                // Left column - Scanner and controls
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      // Scanner card
                                      _buildScannerCard(scannerState, scanState),
                                      const SizedBox(height: 16),
                                      
                                      // Member info card
                                      if (scanState.lastResult != null)
                                        _buildMemberInfoCard(scanState, themeColors),
                                      
                                      // Countdown timer
                                      if (scanState.cooldownActive)
                                        _buildCountdownCard(scanState, themeColors),
                                      
                                      const Spacer(),
                                      
                                      // Control buttons
                                      _buildControlButtonsCard(scannerState, themeColors),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Right column - Quick actions and status
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      // Status overview card
                                      _buildStatusOverviewCard(scanState, themeColors),
                                      const SizedBox(height: 16),
                                      
                                      // Quick actions card
                                      _buildQuickActionsCard(themeColors),
                                      
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build modern app bar like the Casflow image
  PreferredSizeWidget _buildModernAppBar(
    BuildContext context,
    WindowsScannerControllerState scannerState,
    AppThemeColors themeColors,
  ) {
    return AppBar(
      toolbarHeight: 70,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F1B2C), // Deep navy to match sidebar
          border: Border(
            bottom: BorderSide(
              color: Color(0xFF1E293B),
              width: 1,
            ),
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 14),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
      title: Text(
        'MituGym',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          letterSpacing: 0.3,
        ),
      ),
      actions: [
        // Notification icon
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_outlined,
            color: Colors.white70,
            size: 22,
          ),
        ),
        const SizedBox(width: 8),
        
        // User profile section
        Container(
          margin: const EdgeInsets.only(right: 20, top: 14, bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              
              // User name
              Text(
                'Hi, Admin',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 6),
              
              // Dropdown icon
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withValues(alpha: 0.7),
                size: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build scanner card with modern design
  Widget _buildScannerCard(WindowsScannerControllerState scannerState, ScanState scanState) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.9),
            AppColors.surface.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QR Code Scanner',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scanState.statusMessage ?? 'Ready to scan',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Camera preview
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: CollapsibleCameraWidget(
              scannerService: scannerState.service,
              isScanning: scannerState.isActive,
              statusMessage: scanState.statusMessage ?? 'Ready',
            ),
          ),
        ],
      ),
    );
  }

  /// Build member info card with modern design
  Widget _buildMemberInfoCard(ScanState scanState, AppThemeColors themeColors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.9),
            AppColors.surface.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: MemberInfoCard(
          scanResult: scanState.lastResult!,
        ),
      ),
    );
  }

  /// Build countdown card with modern design
  Widget _buildCountdownCard(ScanState scanState, AppThemeColors themeColors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withValues(alpha: 0.15),
            AppColors.warningLight.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: CountdownTimer(
          remainingSeconds: scanState.cooldownRemaining,
          totalSeconds: scanState.cooldownRemaining,
        ),
      ),
    );
  }

  /// Build control buttons card
  Widget _buildControlButtonsCard(WindowsScannerControllerState scannerState, AppThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.9),
            AppColors.surface.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ControlButtons(
        isScanning: scannerState.isActive,
        onStartStop: () async {
          if (scannerState.isActive) {
            await ref.read(windowsScannerControllerProvider.notifier).stopScanner();
          } else {
            await ref.read(windowsScannerControllerProvider.notifier).startScanner();
          }
        },
        onSettings: () => _navigateToSettings(context),
        onClearActivity: () {
          ref.read(scanProvider.notifier).clearActivity();
        },
      ),
    );
  }

  /// Build status overview card
  Widget _buildStatusOverviewCard(ScanState scanState, AppThemeColors themeColors) {
    final todayScans = scanState.recentActivity
        .where((a) => a.time.day == DateTime.now().day)
        .length;
    final todaySuccess = scanState.recentActivity
        .where((a) => a.time.day == DateTime.now().day && a.success)
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.9),
            AppColors.surface.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Today\'s Overview',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildStatusItem(
            label: 'Total Scans',
            value: '$todayScans',
            color: AppColors.primary,
            icon: Icons.qr_code_scanner,
          ),
          const SizedBox(height: 16),
          _buildStatusItem(
            label: 'Successful',
            value: '$todaySuccess',
            color: AppColors.success,
            icon: Icons.check_circle,
          ),
          const SizedBox(height: 16),
          _buildStatusItem(
            label: 'Errors',
            value: '${todayScans - todaySuccess}',
            color: AppColors.error,
            icon: Icons.error,
          ),
        ],
      ),
    );
  }

  /// Build status item
  Widget _buildStatusItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Build quick actions card
  Widget _buildQuickActionsCard(AppThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.9),
            AppColors.surface.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.flash_on,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Quick Actions',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildQuickActionButton(
            icon: Icons.search,
            label: 'Search Members',
            onTap: () => _navigateToSearch(context),
            gradient: AppColors.primaryGradient,
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            icon: Icons.history,
            label: 'View History',
            onTap: () => _navigateToHistory(context),
            gradient: AppColors.accentGradient,
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            icon: Icons.bar_chart,
            label: 'Statistics',
            onTap: () => _navigateToStats(context),
            gradient: AppColors.warningGradient,
          ),
        ],
      ),
    );
  }

  /// Build quick action button
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required LinearGradient gradient,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradient.colors.first.withValues(alpha: 0.1),
                gradient.colors.last.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: gradient.colors.first.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: gradient.colors.first.withValues(alpha: 0.6),
                size: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to settings
  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  /// Navigate to stats
  void _navigateToStats(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatsScreen()),
    );
  }

  /// Navigate to search screen
  void _navigateToSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  /// Navigate to history screen
  void _navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  /// Show export dialog with format options
  void _showExportDialog(BuildContext context, WidgetRef ref, AppThemeColors themeColors) {
    final activities = ref.read(scanProvider).recentActivity;
    
    if (activities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No activity to export'),
          backgroundColor: themeColors.warning,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeColors.card,
        title: Text(
          'Export Activity',
          style: TextStyle(color: themeColors.text),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export ${activities.length} activities',
              style: TextStyle(color: themeColors.muted),
            ),
            const SizedBox(height: 20),
            Text(
              'Choose format:',
              style: TextStyle(
                color: themeColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: themeColors.muted)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _exportActivities(context, ref, 'csv', themeColors);
            },
            icon: const Icon(Icons.table_chart, size: 18),
            label: const Text('CSV'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColors.secondary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _exportActivities(context, ref, 'text', themeColors);
            },
            icon: const Icon(Icons.description, size: 18),
            label: const Text('Text'),
          ),
        ],
      ),
    );
  }

  /// Export activities to file
  Future<void> _exportActivities(
    BuildContext context,
    WidgetRef ref,
    String format,
    AppThemeColors themeColors,
  ) async {
    final activities = ref.read(scanProvider).recentActivity;
    final exportService = ExportService();
    
    // Show loading
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: themeColors.text,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Exporting...'),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: themeColors.surface,
        ),
      );
    }

    String? filePath;
    if (format == 'csv') {
      filePath = await exportService.exportToCSV(activities);
    } else {
      filePath = await exportService.exportToText(activities);
    }

    if (context.mounted) {
      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported to:\n$filePath'),
            backgroundColor: themeColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Export failed'),
            backgroundColor: themeColors.error,
          ),
        );
      }
    }
  }
}
