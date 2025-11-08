import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../config/app_colors.dart';
import '../providers/config_provider.dart';
import '../providers/history_provider.dart';
import '../providers/gym_schedule_provider.dart';
import '../providers/windows_scanner_provider.dart';
import '../providers/language_provider.dart';
import '../services/api_service.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/animated_tab_switcher.dart';

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
  late String _exportPath;
  late bool _autoStartScanning;
  late bool _cameraVisible;
  late bool _startWithWindows;
  late int _historyRetentionDays;
  late bool _verboseLogging;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
    
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
    _exportPath = config.exportPath;
    _autoStartScanning = config.autoStartScanning;
    _cameraVisible = config.cameraVisible;
    _startWithWindows = config.startWithWindows;
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

  Future<void> _selectExportPath() async {
    // Show dialog with text field to enter path and browse button
    final TextEditingController pathController = TextEditingController(text: _exportPath);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            'Set Export Path',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select or enter the folder path where export files should be saved:',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: pathController,
                      decoration: InputDecoration(
                        hintText: 'C:\\Users\\YourName\\Documents\\exports',
                        hintStyle: GoogleFonts.inter(
                          color: AppColors.textMuted.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: AppColors.surface.withValues(alpha: 0.3),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                        ),
                      ),
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                      if (selectedDirectory != null) {
                        pathController.text = selectedDirectory;
                      }
                    },
                    icon: const Icon(LucideIcons.folderSearch, size: 14),
                    label: Text(
                      'Browse',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      foregroundColor: AppColors.primary.withValues(alpha: 0.95),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Leave empty to use default location',
                style: GoogleFonts.inter(
                  color: AppColors.textMuted.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, pathController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                foregroundColor: AppColors.primary.withValues(alpha: 0.95),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    
    if (result != null) {
      setState(() {
        _exportPath = result;
      });
    }
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
    
    // Save settings from General tab
    await ref.read(configProvider.notifier).updateStartWithWindows(_startWithWindows);
    
    // Save settings from Audio tab
    await ref.read(configProvider.notifier).updateSoundVolume(_soundVolume);
    
    // Save settings from Advanced tab
    await ref.read(configProvider.notifier).updateCameraFrameRate(_cameraFrameRate);
    await ref.read(configProvider.notifier).updateLogRetentionDays(_logRetentionDays);
    await ref.read(configProvider.notifier).updateExportPath(_exportPath);
    await ref.read(configProvider.notifier).updateVerboseLogging(_verboseLogging);
    
    // Update scanner service with new settings
    ref.read(windowsScannerControllerProvider.notifier).updateDebounceDuration(_debounceDuration);
    ref.read(windowsScannerControllerProvider.notifier).updateFrameRate(_cameraFrameRate);

    if (mounted) {
      _showPremiumToast(
        context: context,
        message: 'Settings saved successfully',
        icon: LucideIcons.checkCircle,
        type: ToastType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Modern header with tabs
            _buildModernHeader(),
            
            // Content with bottom padding for the action bar
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80), // Space for bottom bar
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
            ),
          ],
        ),
        
        // Modern bottom bar - positioned at the bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomActionBar(),
        ),
      ],
    );
  }

  /// Build premium header with tabs - Ultra Professional with Sliding Animation
  Widget _buildModernHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.card.withValues(alpha: 0.6),
            AppColors.card.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: AnimatedTabSwitcher(
          tabs: const [
            TabItem(label: 'General', icon: LucideIcons.home),
            TabItem(label: 'Display', icon: LucideIcons.monitor),
            TabItem(label: 'Audio', icon: LucideIcons.volume2),
            TabItem(label: 'Advanced', icon: LucideIcons.settings2),
          ],
          selectedIndex: _tabController.index,
          onTabSelected: (index) {
            _tabController.animateTo(index);
          },
          height: 64,
          tabWidth: 165,
        ),
      ),
    );
  }


  /// Build modern bottom action bar
  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.card.withValues(alpha: 0.9),
            AppColors.surface.withValues(alpha: 0.7),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
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
                  _exportPath = config.exportPath;
                  _autoStartScanning = config.autoStartScanning;
                  _cameraVisible = config.cameraVisible;
                  _startWithWindows = config.startWithWindows;
                  _historyRetentionDays = config.historyRetentionDays;
                });
              },
              icon: const Icon(LucideIcons.rotateCcw, size: 16),
              label: Text(
                'Reset',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface.withValues(alpha: 0.3),
                foregroundColor: AppColors.textSecondary.withValues(alpha: 0.85),
                minimumSize: const Size(double.infinity, 44),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(LucideIcons.save, size: 16),
              label: Text(
                'Save Settings',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                foregroundColor: AppColors.primary.withValues(alpha: 0.95),
                minimumSize: const Size(double.infinity, 44),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    width: 1,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column (equal width)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // API Configuration Card
                _buildModernCard(
                  icon: LucideIcons.cloud,
                  title: 'API Configuration',
                  subtitle: 'Manage your API connection',
                  child: Column(
                    children: [
                      _buildInlineTextField(
                        controller: _apiUrlController,
                        label: 'API URL',
                        hint: 'https://api.example.com',
                        icon: LucideIcons.link,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInlineTextField(
                              controller: _apiKeyController,
                              label: 'API Key',
                              hint: 'Enter your API key',
                              icon: LucideIcons.key,
                              obscure: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: _buildTestApiButton(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Application Preferences Card
                _buildModernCard(
                  icon: LucideIcons.settings,
                  title: 'Application Preferences',
                  subtitle: 'Startup and behavior settings',
                  child: Column(
                    children: [
                      _buildLanguageSelector(),
                      const SizedBox(height: 12),
                      _buildInlineSwitch(
                        label: 'Start with Windows',
                        description: 'Launch automatically when Windows starts',
                        icon: LucideIcons.power,
                        value: _startWithWindows,
                        onChanged: (v) => setState(() => _startWithWindows = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Right column (equal width)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Camera Settings Card
                _buildModernCard(
                  icon: LucideIcons.video,
                  title: 'Camera',
                  subtitle: 'Device and capture settings',
                  child: Column(
                    children: [
                      _buildCompactSlider(
                        label: 'Device',
                        icon: LucideIcons.camera,
                        value: _cameraIndex.toDouble(),
                        min: 0,
                        max: 5,
                        divisions: 5,
                        displayValue: 'Camera $_cameraIndex',
                        onChanged: (v) => setState(() => _cameraIndex = v.toInt()),
                      ),
                      const SizedBox(height: 12),
                      _buildCompactSlider(
                        label: 'Frame Rate',
                        icon: LucideIcons.zap,
                        value: _cameraFrameRate.toDouble(),
                        min: 5,
                        max: 30,
                        divisions: 25,
                        displayValue: '$_cameraFrameRate FPS',
                        onChanged: (v) => setState(() => _cameraFrameRate = v.toInt()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Scanner Settings Card
                _buildModernCard(
                  icon: LucideIcons.qrCode,
                  title: 'Scanner',
                  subtitle: 'QR code scanning behavior',
                  child: Column(
                    children: [
                      _buildCompactSlider(
                        label: 'Scan Cooldown',
                        icon: LucideIcons.timer,
                        value: _debounceDuration.toDouble(),
                        min: 2,
                        max: 15,
                        divisions: 13,
                        displayValue: '$_debounceDuration sec',
                        onChanged: (v) => setState(() => _debounceDuration = v.toInt()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Right column
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Display Preferences Card
                _buildModernCard(
                  icon: LucideIcons.eye,
                  title: 'Display Preferences',
                  subtitle: 'Camera and UI settings',
                  child: Column(
                    children: [
                      _buildInlineSwitch(
                        label: 'Show Camera by Default',
                        description: 'Display camera preview on scanner screen',
                        icon: LucideIcons.video,
                        value: _cameraVisible,
                        onChanged: (v) => setState(() => _cameraVisible = v),
                      ),
                      const SizedBox(height: 12),
                      _buildInlineSwitch(
                        label: 'Auto-start Scanning',
                        description: 'Begin scanning when app launches',
                        icon: LucideIcons.playCircle,
                        value: _autoStartScanning,
                        onChanged: (v) => setState(() => _autoStartScanning = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Sound Settings Card
                _buildModernCard(
                  icon: LucideIcons.volume2,
                  title: 'Sound Settings',
                  subtitle: 'Audio feedback configuration',
                  child: Column(
                    children: [
                      _buildInlineSwitch(
                        label: 'Enable Audio Feedback',
                        description: 'Play sound when scanning QR codes',
                        icon: LucideIcons.volumeX,
                        value: _audioEnabled,
                        onChanged: (v) => setState(() => _audioEnabled = v),
                      ),
                      if (_audioEnabled) ...[
                        const SizedBox(height: 16),
                        _buildCompactSlider(
                          label: 'Volume',
                          icon: LucideIcons.volume2,
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
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Right column - Empty placeholder for future settings
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.music,
                        size: 32,
                        color: AppColors.textMuted.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'More audio settings\ncoming soon',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: AppColors.textMuted.withValues(alpha: 0.7),
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
        ],
      ),
    );
  }

  Widget _buildAdvancedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Data Management Card
                _buildModernCard(
                  icon: LucideIcons.database,
                  title: 'Data Management',
                  subtitle: 'Log and data retention settings',
                  child: Column(
                    children: [
                      _buildCompactSlider(
                        label: 'Log Retention',
                        icon: LucideIcons.fileText,
                        value: _logRetentionDays.toDouble(),
                        min: 7,
                        max: 90,
                        divisions: 83,
                        displayValue: '$_logRetentionDays days',
                        onChanged: (v) => setState(() => _logRetentionDays = v.toInt()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Export Settings Card
                _buildModernCard(
                  icon: LucideIcons.folderOutput,
                  title: 'Export Settings',
                  subtitle: 'Configure export file location',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.folder,
                            color: AppColors.primary.withValues(alpha: 0.7),
                            size: 16,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Export Path',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _exportPath.isEmpty
                                      ? 'Using default location'
                                      : _exportPath,
                                  style: GoogleFonts.inter(
                                    color: AppColors.textMuted.withValues(alpha: 0.8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _selectExportPath,
                            icon: const Icon(LucideIcons.folderSearch, size: 14),
                            label: Text(
                              'Browse',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                              foregroundColor: AppColors.primary.withValues(alpha: 0.95),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Logging Card
                _buildModernCard(
                  icon: LucideIcons.terminal,
                  title: 'Logging',
                  subtitle: 'Application logging configuration',
                  child: Column(
                    children: [
                      _buildInlineSwitch(
                        label: 'Verbose Logging',
                        description: 'Save debug, warning, and trace logs to files',
                        icon: LucideIcons.bug,
                        value: _verboseLogging,
                        onChanged: (v) => setState(() => _verboseLogging = v),
                      ),
                      if (_verboseLogging) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.info.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.info,
                                color: AppColors.info.withValues(alpha: 0.8),
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Helpful for troubleshooting issues',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Right column
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // History Management Card
                _buildModernCard(
                  icon: LucideIcons.history,
                  title: 'History Management',
                  subtitle: 'Scan history and sync settings',
                  child: Column(
                    children: [
                      _buildCompactSlider(
                        label: 'History Retention',
                        icon: LucideIcons.clock,
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
                ),
              ],
            ),
          ),
        ],
      ),
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
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: _testApiEndpoints,
        icon: const Icon(LucideIcons.network, size: 16),
        label: Text(
          'Test API',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary.withValues(alpha: 0.08),
          foregroundColor: AppColors.primary.withValues(alpha: 0.9),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.15),
              width: 1,
            ),
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
        _showPremiumToast(
          context: context,
          message: 'Test failed: $e',
          icon: LucideIcons.xCircle,
          type: ToastType.error,
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
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x, size: 16),
                  label: Text(
                    'Close',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    foregroundColor: AppColors.primary.withValues(alpha: 0.95),
                    minimumSize: const Size(double.infinity, 44),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        width: 1,
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.card.withValues(alpha: 0.95),
                AppColors.surface.withValues(alpha: 0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        LucideIcons.trash2,
                        color: AppColors.warning.withValues(alpha: 0.9),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cleanup Old History',
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Confirm deletion',
                            style: GoogleFonts.inter(
                              color: AppColors.textMuted.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.alertTriangle,
                            color: AppColors.warning.withValues(alpha: 0.8),
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This will permanently delete all history records older than $_historyRetentionDays days. This action cannot be undone.',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(false),
                        icon: const Icon(LucideIcons.x, size: 16),
                        label: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surface.withValues(alpha: 0.3),
                          foregroundColor: AppColors.textSecondary.withValues(alpha: 0.85),
                          minimumSize: const Size(double.infinity, 44),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: AppColors.border.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(true),
                        icon: const Icon(LucideIcons.trash2, size: 16),
                        label: Text(
                          'Cleanup',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning.withValues(alpha: 0.12),
                          foregroundColor: AppColors.warning.withValues(alpha: 0.95),
                          minimumSize: const Size(double.infinity, 44),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: AppColors.warning.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    if (confirmed == true) {
      final deletedCount = await ref.read(historyProvider.notifier).cleanupOldHistory();
      
      if (mounted) {
        _showPremiumToast(
          context: context,
          message: 'Deleted $deletedCount old records',
          icon: LucideIcons.trash2,
          type: ToastType.success,
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
          _showPremiumToast(
            context: context,
            message: 'Sync error: ${historyState.error}',
            icon: LucideIcons.alertCircle,
            type: ToastType.error,
          );
        } else {
          _showPremiumToast(
            context: context,
            message: 'All data synced successfully from server',
            icon: LucideIcons.refreshCw,
            type: ToastType.success,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showPremiumToast(
          context: context,
          message: 'Sync failed: $e',
          icon: LucideIcons.xCircle,
          type: ToastType.error,
        );
      }
    }
  }


  /// Build modern card with icon, title, subtitle and content
  Widget _buildModernCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.primary.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Card content
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  /// Build inline text field (label on top, compact)
  Widget _buildInlineTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                color: AppColors.textMuted.withValues(alpha: 0.4),
                fontSize: 13,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: AppColors.primary, size: 13),
              ),
              filled: true,
              fillColor: AppColors.surface.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.8),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build language selector dropdown
  Widget _buildLanguageSelector() {
    final currentLocale = ref.watch(languageProvider);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(LucideIcons.languages, color: AppColors.primary, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Language',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Select your preferred language',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: DropdownButton<Locale>(
              value: currentLocale,
              isDense: true,
              underline: const SizedBox(),
              dropdownColor: AppColors.card,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              icon: Icon(
                LucideIcons.chevronDown,
                size: 14,
                color: AppColors.textMuted,
              ),
              items: LanguageNotifier.supportedLocales.map((locale) {
                return DropdownMenuItem<Locale>(
                  value: locale,
                  child: Text(LanguageNotifier.getLocaleName(locale)),
                );
              }).toList(),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  ref.read(languageProvider.notifier).changeLocale(newLocale);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build inline switch with description
  Widget _buildInlineSwitch({
    required String label,
    required String description,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: AppColors.primary, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.95,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.75),
              inactiveTrackColor: AppColors.surface.withValues(alpha: 0.9),
              inactiveThumbColor: AppColors.textSecondary,
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary;
                }
                return AppColors.textSecondary;
              }),
              trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary.withValues(alpha: 0.6);
                }
                return AppColors.border.withValues(alpha: 0.6);
              }),
              trackOutlineWidth: WidgetStateProperty.all(2.5),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }


  /// Build compact slider with smaller padding
  Widget _buildCompactSlider({
    required String label,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface.withValues(alpha: 0.6),
            AppColors.surface.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
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
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: AppColors.primary, size: 12),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Text(
                  displayValue,
                  style: GoogleFonts.inter(
                    color: AppColors.primary.withValues(alpha: 0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary.withValues(alpha: 0.6),
              inactiveTrackColor: AppColors.primary.withValues(alpha: 0.08),
              thumbColor: AppColors.primary.withValues(alpha: 0.85),
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
              trackHeight: 5,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 8,
                elevation: 2,
                pressedElevation: 4,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 16,
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

  /// Show premium toast notification
  void _showPremiumToast({
    required BuildContext context,
    required String message,
    required IconData icon,
    required ToastType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    final colorMap = {
      ToastType.success: AppColors.success,
      ToastType.error: AppColors.error,
      ToastType.info: AppColors.info,
      ToastType.warning: AppColors.warning,
    };
    
    final color = colorMap[type]!;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _PremiumToast(
        message: message,
        icon: icon,
        color: color,
        onDismiss: () => overlayEntry.remove(),
        duration: duration,
      ),
    );
    
    overlay.insert(overlayEntry);
  }
}

/// Toast type enum
enum ToastType { success, error, info, warning }

/// Premium toast widget
class _PremiumToast extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback onDismiss;
  final Duration duration;

  const _PremiumToast({
    required this.message,
    required this.icon,
    required this.color,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_PremiumToast> createState() => _PremiumToastState();
}

class _PremiumToastState extends State<_PremiumToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      reverseCurve: Curves.easeOut,
    ));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: double.infinity,
                  minWidth: 300,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.card.withValues(alpha: 0.95),
                      AppColors.surface.withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                      spreadRadius: -4,
                    ),
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.2),
                      blurRadius: 16,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: widget.color.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color.withValues(alpha: 0.9),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        widget.message,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

