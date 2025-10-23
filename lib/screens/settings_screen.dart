import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../providers/config_provider.dart';
import '../providers/history_provider.dart';
import '../providers/gym_schedule_provider.dart';
import '../providers/windows_scanner_provider.dart';
import '../services/api_service.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Modern settings screen - Dashboard style
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  late TextEditingController _apiUrlController;
  late TextEditingController _apiKeyController;
  late int _cameraIndex;
  late int _debounceDuration;
  late bool _audioEnabled;
  late double _soundVolume;
  late int _cameraFrameRate;
  late int _logRetentionDays;
  late String _exportFormat;
  late bool _autoStartScanning;
  late bool _cameraVisible;
  late int _historyRetentionDays;
  late bool _verboseLogging;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize from current config
    final config = ref.read(configProvider);
    _apiUrlController = TextEditingController(text: config.apiUrl);
    _apiKeyController = TextEditingController(text: config.apiKey);
    _cameraIndex = config.cameraIndex;
    _debounceDuration = config.debounceDuration;
    _audioEnabled = config.audioEnabled;
    _soundVolume = config.soundVolume;
    _cameraFrameRate = config.cameraFrameRate;
    _logRetentionDays = config.logRetentionDays;
    _exportFormat = config.exportFormat;
    _autoStartScanning = config.autoStartScanning;
    _cameraVisible = config.cameraVisible;
    _historyRetentionDays = config.historyRetentionDays;
    _verboseLogging = config.verboseLogging;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _apiUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    // Update ALL settings individually
    await ref.read(configProvider.notifier).updateApiUrl(_apiUrlController.text);
    await ref.read(configProvider.notifier).updateApiKey(_apiKeyController.text);
    await ref.read(configProvider.notifier).updateCameraIndex(_cameraIndex);
    await ref.read(configProvider.notifier).updateDebounceDuration(_debounceDuration);
    await ref.read(configProvider.notifier).updateAudioEnabled(_audioEnabled);
    await ref.read(configProvider.notifier).updateHistoryRetentionDays(_historyRetentionDays);
    
    // Save settings from Display tab
    await ref.read(configProvider.notifier).updateCameraVisible(_cameraVisible);
    await ref.read(configProvider.notifier).updateAutoStartScanning(_autoStartScanning);
    
    // Save settings from Audio tab
    await ref.read(configProvider.notifier).updateSoundVolume(_soundVolume);
    
    // Save settings from Advanced tab
    await ref.read(configProvider.notifier).updateCameraFrameRate(_cameraFrameRate);
    await ref.read(configProvider.notifier).updateLogRetentionDays(_logRetentionDays);
    await ref.read(configProvider.notifier).updateExportFormat(_exportFormat);
    await ref.read(configProvider.notifier).updateVerboseLogging(_verboseLogging);
    
    // Update scanner service with new settings
    ref.read(windowsScannerControllerProvider.notifier).updateDebounceDuration(_debounceDuration);
    ref.read(windowsScannerControllerProvider.notifier).updateFrameRate(_cameraFrameRate);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(LucideIcons.check, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                'Settings saved successfully',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          children: [
        // Modern header with tabs
        _buildModernHeader(),
            
            // Content
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeneralTab(),
                    _buildDisplayTab(),
                    _buildAudioTab(),
                    _buildAdvancedTab(),
                  ],
                ),
              ),
            ),
            
            // Modern bottom bar
            _buildBottomActionBar(),
          ],
    );
  }

  /// Build modern header with tabs
  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.9),
            AppColors.surface.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
                child: Column(
                  children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'GENERAL'),
                Tab(text: 'DISPLAY'),
                Tab(text: 'AUDIO'),
                Tab(text: 'ADVANCED'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build modern bottom action bar
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.card.withValues(alpha: 0.9),
            AppColors.surface.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Reset to original values
                  final config = ref.read(configProvider);
                  setState(() {
                    _apiUrlController.text = config.apiUrl;
                    _apiKeyController.text = config.apiKey;
                    _cameraIndex = config.cameraIndex;
                    _debounceDuration = config.debounceDuration;
                    _audioEnabled = config.audioEnabled;
                    _soundVolume = config.soundVolume;
                    _cameraFrameRate = config.cameraFrameRate;
                    _logRetentionDays = config.logRetentionDays;
                    _exportFormat = config.exportFormat;
                    _autoStartScanning = config.autoStartScanning;
                    _cameraVisible = config.cameraVisible;
                    _historyRetentionDays = config.historyRetentionDays;
                  });
                },
                borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                      color: AppColors.border,
                  width: 1.5,
                ),
              ),
                  child: Center(
                child: Text(
                      'Reset',
                  style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _saveSettings,
                borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      const Icon(LucideIcons.save, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Save Settings',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSection(
          'API Configuration',
          LucideIcons.cloud,
          [
            _buildTextField(
              controller: _apiUrlController,
              label: 'API URL',
              hint: 'https://api.example.com',
              icon: LucideIcons.link,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _apiKeyController,
              label: 'API Key',
              hint: 'Your API key',
              icon: LucideIcons.key,
              obscure: true,
            ),
            const SizedBox(height: 16),
            _buildTestApiButton(),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          'Camera',
          LucideIcons.camera,
          [
            _buildSlider(
              label: 'Camera Device',
              value: _cameraIndex.toDouble(),
              min: 0,
              max: 5,
              divisions: 5,
              displayValue: 'Device $_cameraIndex',
              onChanged: (v) => setState(() => _cameraIndex = v.toInt()),
            ),
            const SizedBox(height: 16),
            _buildSlider(
              label: 'Frame Rate',
              value: _cameraFrameRate.toDouble(),
              min: 5,
              max: 30,
              divisions: 25,
              displayValue: '$_cameraFrameRate FPS',
              onChanged: (v) => setState(() => _cameraFrameRate = v.toInt()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDisplayTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSection(
          'Scanner',
          LucideIcons.qrCode,
          [
            _buildSlider(
              label: 'Scan Cooldown',
              value: _debounceDuration.toDouble(),
              min: 2,
              max: 15,
              divisions: 13,
              displayValue: '$_debounceDuration sec',
              onChanged: (v) => setState(() => _debounceDuration = v.toInt()),
            ),
            const SizedBox(height: 16),
            _buildSwitch(
              label: 'Show Camera by Default',
              value: _cameraVisible,
              onChanged: (v) => setState(() => _cameraVisible = v),
            ),
            _buildSwitch(
              label: 'Auto-start Scanning',
              value: _autoStartScanning,
              onChanged: (v) => setState(() => _autoStartScanning = v),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAudioTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSection(
          'Sound Settings',
          LucideIcons.volume2,
          [
            _buildSwitch(
              label: 'Enable Audio Feedback',
              value: _audioEnabled,
              onChanged: (v) => setState(() => _audioEnabled = v),
            ),
            if (_audioEnabled) ...[
              const SizedBox(height: 16),
              _buildSlider(
                label: 'Volume',
                value: _soundVolume,
                min: 0,
                max: 1,
                divisions: 10,
                displayValue: '${(_soundVolume * 100).toInt()}%',
                onChanged: (v) => setState(() => _soundVolume = v),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAdvancedTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSection(
          'Data Management',
          LucideIcons.database,
          [
            _buildSlider(
              label: 'Log Retention',
              value: _logRetentionDays.toDouble(),
              min: 7,
              max: 90,
              divisions: 83,
              displayValue: '$_logRetentionDays days',
              onChanged: (v) => setState(() => _logRetentionDays = v.toInt()),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Export Format',
              value: _exportFormat,
              items: const ['csv', 'text'],
              onChanged: (v) => setState(() => _exportFormat = v!),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          'Logging',
          LucideIcons.fileText,
          [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSwitch(
                  label: 'Verbose Logging',
                  value: _verboseLogging,
                  onChanged: (v) => setState(() => _verboseLogging = v),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.info, color: AppColors.info, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'When enabled, all app logs including debug, warning, and trace information will be saved to daily .log files. Helpful for troubleshooting issues.',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          'History Management',
          LucideIcons.history,
          [
            _buildSlider(
              label: 'History Retention',
              value: _historyRetentionDays.toDouble(),
              min: 7,
              max: 365,
              divisions: 51,
              displayValue: '$_historyRetentionDays days',
              onChanged: (v) => setState(() => _historyRetentionDays = v.toInt()),
            ),
            const SizedBox(height: 16),
            _buildHistoryStatsRow(),
            const SizedBox(height: 16),
            _buildCleanupButton(),
            const SizedBox(height: 12),
            _buildSyncButton(),
          ],
        ),
      ],
    );
  }

  /// Build history stats row
  Widget _buildHistoryStatsRow() {
    return FutureBuilder<int>(
      future: ref.read(historyProvider.notifier).getTotalCount(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        final config = ref.watch(configProvider);
        final lastSync = config.lastHistorySync;
        
        return Container(
          padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.3),
            ),
                      ),
                      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
              Row(
                children: [
                  const Icon(LucideIcons.fileText, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                          Text(
                    'Total Records: $count',
                            style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                              fontSize: 14,
                      fontWeight: FontWeight.w500,
                            ),
                          ),
                ],
              ),
              if (lastSync != null) ...[
                            const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(LucideIcons.refreshCw, color: AppColors.textMuted, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Last Synced: ${DateFormat('MMM d, h:mm a').format(lastSync)}',
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                            ),
                          ],
                        ],
                      ),
        );
      },
    );
  }
  
  /// Build cleanup button
  Widget _buildCleanupButton() {
    return ElevatedButton.icon(
      onPressed: _performCleanup,
      icon: const Icon(LucideIcons.trash2),
      label: const Text('Cleanup Old History'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.warning.withValues(alpha: 0.15),
        foregroundColor: AppColors.warning,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.warning.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
  
  /// Build test API button
  Widget _buildTestApiButton() {
    return ElevatedButton.icon(
      onPressed: _testApiEndpoints,
      icon: const Icon(LucideIcons.network),
      label: const Text('Test API Connection'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.info.withValues(alpha: 0.15),
        foregroundColor: AppColors.info,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.info.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  /// Test all API endpoints
  Future<void> _testApiEndpoints() async {
    if (!mounted) return;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.info),
            const SizedBox(height: 16),
            Text(
              'Testing API endpoints...',
              style: GoogleFonts.inter(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );

    try {
      final config = ref.read(configProvider);
      final apiService = ApiService(
        apiUrl: _apiUrlController.text.isNotEmpty 
            ? _apiUrlController.text 
            : config.apiUrl,
        apiKey: _apiKeyController.text.isNotEmpty 
            ? _apiKeyController.text 
            : config.apiKey,
      );

      final results = await apiService.testAllApiEndpoints();
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show results dialog
        _showApiTestResults(results);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Show API test results dialog with modern design
  void _showApiTestResults(Map<String, dynamic> results) {
    final endpoints = results['endpoints'] as Map<String, dynamic>;
    final overallHealth = results['overallHealth'] as String;
    final isHealthy = overallHealth == 'healthy';
    final isOffline = overallHealth == 'offline';
    
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.card.withValues(alpha: 0.95),
                AppColors.surface.withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 40,
                offset: const Offset(0, 20),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient background
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (isHealthy 
                          ? AppColors.success 
                          : isOffline 
                              ? AppColors.error 
                              : AppColors.warning)
                          .withValues(alpha: 0.15),
                      (isHealthy 
                          ? AppColors.successLight 
                          : isOffline 
                              ? AppColors.errorLight 
                              : AppColors.warningLight)
                          .withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    // Animated icon with glow effect
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: isHealthy 
                            ? AppColors.successGradient 
                            : isOffline
                                ? AppColors.errorGradient
                                : AppColors.warningGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (isHealthy 
                                ? AppColors.success 
                                : isOffline 
                                    ? AppColors.error 
                                    : AppColors.warning)
                                .withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isHealthy 
                            ? LucideIcons.badgeCheck 
                            : isOffline 
                                ? LucideIcons.wifiOff 
                                : LucideIcons.alertCircle,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'API Test Results',
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (isHealthy 
                                  ? AppColors.success 
                                  : isOffline 
                                      ? AppColors.error 
                                      : AppColors.warning)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: (isHealthy 
                                    ? AppColors.success 
                                    : isOffline 
                                        ? AppColors.error 
                                        : AppColors.warning)
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              overallHealth.toUpperCase(),
                              style: GoogleFonts.inter(
                                color: isHealthy 
                                    ? AppColors.success 
                                    : isOffline 
                                        ? AppColors.error 
                                        : AppColors.warning,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content with endpoints
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ENDPOINT STATUS',
                        style: GoogleFonts.inter(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Endpoint results with modern cards
                      ...endpoints.entries.map((entry) {
                        final endpointName = entry.key;
                        final result = entry.value as Map<String, dynamic>;
                        final status = result['status'] as String;
                        final isSuccess = status == 'success' || status == 'reachable';
                        final isWarning = status == 'warning';
                        
                        // Determine status color
                        final statusColor = isSuccess 
                            ? AppColors.success 
                            : isWarning 
                                ? AppColors.warning 
                                : AppColors.error;
                        
                        // Determine status icon
                        final statusIcon = isSuccess 
                            ? LucideIcons.badgeCheck 
                            : isWarning 
                                ? LucideIcons.alertTriangle 
                                : LucideIcons.alertCircle;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.surface.withValues(alpha: 0.6),
                                AppColors.surface.withValues(alpha: 0.4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Status icon
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        statusIcon,
                                        color: statusColor,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            endpointName.replaceAll('_', ' ').toUpperCase(),
                                            style: GoogleFonts.inter(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            status.toUpperCase(),
                                            style: GoogleFonts.inter(
                                              color: statusColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                // Additional info
                                if (result['recordCount'] != null || result['error'] != null || result['note'] != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.background.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (result['recordCount'] != null) ...[
                                          Row(
                                            children: [
                                              Icon(
                                                LucideIcons.fileText,
                                                color: AppColors.primary,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Records: ${result['recordCount']}',
                                                style: GoogleFonts.inter(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (result['note'] != null) ...[
                                          if (result['recordCount'] != null)
                                            const SizedBox(height: 8),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                LucideIcons.info,
                                                color: AppColors.warning,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  result['note'] as String,
                                                  style: GoogleFonts.inter(
                                                    color: AppColors.textSecondary,
                                                    fontSize: 11,
                                                    height: 1.4,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (result['error'] != null) ...[
                                          if (result['recordCount'] != null || result['note'] != null)
                                            const SizedBox(height: 8),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                LucideIcons.info,
                                                color: AppColors.textMuted,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  (result['error'] as String).split('\n').first,
                                                  style: GoogleFonts.inter(
                                                    color: AppColors.textMuted,
                                                    fontSize: 11,
                                                    height: 1.4,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              
              // Footer with close button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Close',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
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

  /// Build sync button
  Widget _buildSyncButton() {
    final historyState = ref.watch(historyProvider);
    
    return ElevatedButton.icon(
      onPressed: historyState.isLoading ? null : _performSync,
      icon: historyState.isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            )
          : const Icon(LucideIcons.download),
      label: Text(historyState.isLoading ? 'Syncing...' : 'Sync All Data from Server'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
  
  /// Perform cleanup
  Future<void> _performCleanup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Cleanup Old History',
          style: GoogleFonts.inter(color: AppColors.textPrimary),
        ),
        content: Text(
          'This will delete all history records older than $_historyRetentionDays days. Continue?',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
              'Cleanup',
              style: GoogleFonts.inter(color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
    );
    
    if (confirmed == true) {
      final deletedCount = await ref.read(historyProvider.notifier).cleanupOldHistory();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted $deletedCount old records'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
  
  /// Perform comprehensive sync (history, schedule, and all API data)
  Future<void> _performSync() async {
    if (!mounted) return;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Syncing from server...',
              style: GoogleFonts.inter(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );

    try {
      // 1. Sync history from server
      await ref.read(historyProvider.notifier).clearAndSyncFromServer();
      
      // 2. Sync gym schedule from server
      await ref.read(gymScheduleProvider.notifier).fetchSchedule();
      
      // 3. Update last sync timestamp
      await ref.read(configProvider.notifier).updateLastHistorySync(DateTime.now());
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        final historyState = ref.read(historyProvider);
        if (historyState.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sync error: ${historyState.error}'),
              backgroundColor: AppColors.error,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(LucideIcons.check, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All data synced successfully from server',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }


  Widget _buildSection(String title, IconData icon, List<Widget> children) {
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
          color: AppColors.border.withValues(alpha: 0.3),
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
          // Section header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          
          // Section content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              obscureText: obscure,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
                filled: true,
                fillColor: AppColors.surface.withValues(alpha: 0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface.withValues(alpha: 0.8),
            AppColors.surface.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayValue,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surface,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10,
              ),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface.withValues(alpha: 0.8),
            AppColors.surface.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary;
                }
                return AppColors.textMuted;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surface.withValues(alpha: 0.8),
                  AppColors.surface.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: AppColors.surface,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item.toUpperCase()),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

