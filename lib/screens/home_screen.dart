import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../providers/scan_provider.dart';
import '../providers/windows_scanner_provider.dart';
import '../widgets/windows_camera_preview_widget.dart';
import '../widgets/member_info_card.dart';
import '../widgets/activity_list_widget.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/control_buttons.dart';
import '../services/export_service.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

/// Home screen - Main scanning interface
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);
    final scannerState = ref.watch(windowsScannerControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MituGym Scanner'),
        actions: [
          // Status indicator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scannerState.isActive 
                      ? AppColors.success 
                      : AppColors.error,
                  boxShadow: scannerState.isActive
                      ? [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
          // Statistics button
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              );
            },
            tooltip: 'Statistics',
          ),
          // Export button
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _showExportDialog(context, ref),
            tooltip: 'Export',
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Container(
        decoration: AppColors.getBackgroundDecoration(),
        child: Column(
        children: [
          // Camera Preview
          Expanded(
            flex: 6,
            child: WindowsCameraPreviewWidget(
              scannerService: scannerState.service,
              isScanning: scannerState.isActive,
              statusMessage: scanState.statusMessage ?? 'Ready',
            ),
          ),

          // Member Info Card
          if (scanState.lastResult != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: MemberInfoCard(
                scanResult: scanState.lastResult!,
              ),
            ),

          // Countdown Timer
          if (scanState.cooldownActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CountdownTimer(
                remainingSeconds: scanState.cooldownRemaining,
                totalSeconds: scanState.cooldownRemaining,
              ),
            ),

          // Activity List
          Expanded(
            flex: 3,
            child: ActivityListWidget(
              activities: scanState.recentActivity,
            ),
          ),

          // Control Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: ControlButtons(
              isScanning: scannerState.isActive,
              onStartStop: () async {
                if (scannerState.isActive) {
                  await ref.read(windowsScannerControllerProvider.notifier).stopScanner();
                } else {
                  await ref.read(windowsScannerControllerProvider.notifier).startScanner();
                }
              },
              onSettings: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              onClearActivity: () {
                ref.read(scanProvider.notifier).clearActivity();
              },
            ),
          ),
        ],
        ),
      ),
    );
  }

  /// Show export dialog with format options
  void _showExportDialog(BuildContext context, WidgetRef ref) {
    final activities = ref.read(scanProvider).recentActivity;
    
    if (activities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No activity to export'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Export Activity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export ${activities.length} activities',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            Text(
              'Choose format:',
              style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _exportActivities(context, ref, 'csv');
            },
            icon: const Icon(Icons.table_chart, size: 18),
            label: const Text('CSV'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _exportActivities(context, ref, 'text');
            },
            icon: const Icon(Icons.description, size: 18),
            label: const Text('Text'),
          ),
        ],
      ),
    );
  }

  /// Export activities to file
  Future<void> _exportActivities(BuildContext context, WidgetRef ref, String format) async {
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
                  color: AppColors.text,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Exporting...'),
            ],
          ),
          duration: const Duration(seconds: 2),
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
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Open Folder',
              textColor: AppColors.text,
              onPressed: () async {
                final dir = await exportService.getExportDirectory();
                if (dir != null) {
                  // You could use url_launcher or process to open the folder
                  // For now just show the path
                }
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Export failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

