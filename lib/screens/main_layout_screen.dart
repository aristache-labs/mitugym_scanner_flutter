import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_themes.dart';
import '../config/app_colors.dart';
import '../providers/config_provider.dart';
import '../providers/scan_provider.dart';
import '../providers/windows_scanner_provider.dart';
import '../providers/offline_provider.dart';
import '../providers/history_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/modern_sidebar_widget.dart';
import '../widgets/offline_banner_widget.dart';
import '../services/export_service.dart';
import '../services/history_sync_service.dart';
import 'dashboard_screen.dart';
import 'scanner_screen.dart';
import 'history_screen.dart';
import 'stats_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

/// Main layout screen with persistent sidebar and top bar
/// Only the content area changes when navigating
class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  int _selectedIndex = 0;

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
      
      // Initialize history sync service
      _initializeHistoryServices();
    });
  }
  
  /// Initialize history services
  Future<void> _initializeHistoryServices() async {
    // Clear and sync fresh history from server on app startup
    await ref.read(historyProvider.notifier).clearAndSyncFromServer();
    
    // Start periodic sync service for incremental updates
    final syncService = ref.read(historySyncServiceProvider);
    syncService.startPeriodicSync();
  }

  // List of pages/screens
  final List<Widget> _pages = const [
    DashboardScreen(),      // 0 - Dashboard
    ScannerScreen(),        // 1 - QR Scanner
    StatsScreen(),          // 2 - Check-ins/Analytics
    HistoryScreen(),        // 3 - History
    SearchScreen(),         // 4 - Search
    SettingsScreen(),       // 5 - Settings
  ];

  // Page titles
  final List<String> _pageTitles = const [
    'Dashboard',
    'QR Code Scanner',
    'Check-ins',
    'History',
    'Members',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(configProvider);
    final themeColors = AppThemeColors.getThemeColors(
      config.theme.isEmpty ? 'cyan' : config.theme,
    );

    return Scaffold(
      appBar: _buildModernAppBar(context, themeColors),
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
                  // Modern Sidebar - Persistent
                  ModernSidebarWidget(
                    themeColors: themeColors,
                    selectedIndex: _selectedIndex,
                    onNavigate: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    onExport: () => _showExportDialog(context, ref, themeColors),
                  ),
                  
                  // Main Content Area - Changes based on selected page
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Page title
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 20),
                            child: Text(
                              _pageTitles[_selectedIndex],
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          
                          // Page content
                          Expanded(
                            child: _pages[_selectedIndex],
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

  /// Build online/offline status indicator
  Widget _buildStatusIndicator(OfflineState offlineState) {
    final isOnline = offlineState.isOnline;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOnline
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOnline
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? AppColors.success : AppColors.error,
              boxShadow: [
                BoxShadow(
                  color: isOnline
                      ? AppColors.success.withValues(alpha: 0.5)
                      : AppColors.error.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: GoogleFonts.inter(
              color: isOnline ? AppColors.success : AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Build modern app bar - persistent across all pages
  PreferredSizeWidget _buildModernAppBar(
    BuildContext context,
    AppThemeColors themeColors,
  ) {
    final offlineState = ref.watch(offlineProvider);
    
    return AppBar(
      toolbarHeight: 70,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0A0F0F), // Very dark background
          border: Border(
            bottom: BorderSide(
              color: Color(0xFF1F2828),
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
        'MITUGYM',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        // Online/Offline status indicator
        _buildStatusIndicator(offlineState),
        const SizedBox(width: 16),
        
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
        
        // User profile dropdown
        _buildUserDropdown(context),
      ],
    );
  }

  /// Build user dropdown menu
  Widget _buildUserDropdown(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userName = authState.session?.userName ?? 'User';
    
    return PopupMenuButton<String>(
      tooltip: '', // Remove default "Show menu" tooltip
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.border.withValues(alpha: 0.3),
        ),
      ),
      color: AppColors.surface,
      child: Container(
        margin: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(
          minHeight: 50,
        ),
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
              child: Center(
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            
            // Welcome text + User name
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WELCOME BACK',
                    style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userName,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            
            // Dropdown icon
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white.withValues(alpha: 0.7),
              size: 18,
            ),
          ],
        ),
      ),
      onSelected: (value) async {
        if (value == 'settings') {
          await _openWebSettings();
        } else if (value == 'logout') {
          await _handleLogout();
        }
      },
      itemBuilder: (context) => [
        // Settings option
        PopupMenuItem<String>(
          value: 'settings',
          height: 48,
          child: Row(
            children: [
              Icon(
                Icons.settings_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Settings',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.open_in_new,
                size: 14,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
        
        // Divider
        PopupMenuItem<String>(
          enabled: false,
          height: 1,
          child: Divider(
            color: AppColors.border.withValues(alpha: 0.2),
            height: 1,
          ),
        ),
        
        // Logout option
        PopupMenuItem<String>(
          value: 'logout',
          height: 48,
          child: Row(
            children: [
              Icon(
                Icons.logout_outlined,
                size: 18,
                color: AppColors.error,
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: GoogleFonts.inter(
                  color: AppColors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Open web panel settings page
  Future<void> _openWebSettings() async {
    final config = ref.read(configProvider);
    final apiUrl = config.apiUrl;
    
    if (apiUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API URL not configured'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    
    // Extract base URL and construct settings URL
    final uri = Uri.parse(apiUrl);
    final baseUrl = '${uri.scheme}://${uri.host}';
    final settingsUrl = '$baseUrl/settings';
    
    final url = Uri.parse(settingsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open: $settingsUrl'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Handle user logout
  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Logout',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout? You will need to login again to use the app.',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      // Perform logout
      await ref.read(authProvider.notifier).logout();
      
      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    }
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

