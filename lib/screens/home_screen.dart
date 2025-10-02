import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_themes.dart';
import '../providers/scan_provider.dart';
import '../providers/config_provider.dart';
import '../providers/windows_scanner_provider.dart';
import '../widgets/collapsible_camera_widget.dart';
import '../widgets/member_info_card.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/control_buttons.dart';
import '../widgets/sidebar_widget.dart';
import '../services/export_service.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

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
    
    // Get theme colors
    final themeColors = AppThemeColors.getThemeColors(config.theme);

    return Scaffold(
      appBar: _buildAppBar(context, scannerState, themeColors),
      body: Container(
        decoration: BoxDecoration(
          gradient: themeColors.getBackgroundDecoration(),
        ),
        child: Row(
          children: [
            // Left Sidebar
            SidebarWidget(
              themeColors: themeColors,
              onExport: () => _showExportDialog(context, ref, themeColors),
              onSettings: () => _navigateToSettings(context),
              onStats: () => _navigateToStats(context),
            ),
            
            // Main Content Area
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Collapsible Camera Preview
                    CollapsibleCameraWidget(
                      scannerService: scannerState.service,
                      isScanning: scannerState.isActive,
                      statusMessage: scanState.statusMessage ?? 'Ready',
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Member Info Card
                    if (scanState.lastResult != null)
                      MemberInfoCard(
                        scanResult: scanState.lastResult!,
                      ),
                    
                    if (scanState.lastResult != null)
                      const SizedBox(height: 16),
                    
                    // Countdown Timer
                    if (scanState.cooldownActive)
                      CountdownTimer(
                        remainingSeconds: scanState.cooldownRemaining,
                        totalSeconds: scanState.cooldownRemaining,
                      ),
                    
                    if (scanState.cooldownActive)
                      const SizedBox(height: 16),
                    
                    const Spacer(),
                    
                    // Control Buttons
                    ControlButtons(
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build premium app bar with gradient
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WindowsScannerControllerState scannerState,
    AppThemeColors themeColors,
  ) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: themeColors.primaryGradient,
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.qr_code_scanner, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'MituGym Scanner',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        // Status indicator with pulse animation
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Row(
              children: [
                Text(
                  scannerState.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scannerState.isActive 
                        ? themeColors.success 
                        : themeColors.error,
                    boxShadow: scannerState.isActive
                        ? [
                            BoxShadow(
                              color: themeColors.success.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
