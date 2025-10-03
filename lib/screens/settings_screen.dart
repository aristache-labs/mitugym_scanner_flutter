import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_colors.dart';
import '../config/app_themes.dart';
import '../providers/config_provider.dart';

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
  late double _fontSize;
  late double _animationSpeed;
  late double _soundVolume;
  late int _cameraFrameRate;
  late int _logRetentionDays;
  late String _exportFormat;
  late bool _autoStartScanning;
  late bool _cameraVisible;
  late String _selectedTheme;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    // Initialize from current config
    final config = ref.read(configProvider);
    _apiUrlController = TextEditingController(text: config.apiUrl);
    _apiKeyController = TextEditingController(text: config.apiKey);
    _cameraIndex = config.cameraIndex;
    _debounceDuration = config.debounceDuration;
    _audioEnabled = config.audioEnabled;
    _fontSize = config.fontSize;
    _animationSpeed = config.animationSpeed;
    _soundVolume = config.soundVolume;
    _cameraFrameRate = config.cameraFrameRate;
    _logRetentionDays = config.logRetentionDays;
    _exportFormat = config.exportFormat;
    _autoStartScanning = config.autoStartScanning;
    _cameraVisible = config.cameraVisible;
    _selectedTheme = config.theme.isEmpty ? 'purple' : config.theme;
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

    // Update each setting individually
    await ref.read(configProvider.notifier).updateApiUrl(_apiUrlController.text);
    await ref.read(configProvider.notifier).updateApiKey(_apiKeyController.text);
    await ref.read(configProvider.notifier).updateCameraIndex(_cameraIndex);
    await ref.read(configProvider.notifier).updateDebounceDuration(_debounceDuration);
    await ref.read(configProvider.notifier).updateAudioEnabled(_audioEnabled);

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
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              const Text('Settings saved successfully'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppThemeColors.getThemeColors(_selectedTheme).getBackgroundDecoration(),
        child: Column(
          children: [
            // Modern app bar with gradient
            _buildModernAppBar(),
            
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
                    _buildThemeTab(),
                  ],
                ),
              ),
            ),
            
            // Modern bottom bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  /// Build modern app bar with gradient
  Widget _buildModernAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.9),
            AppColors.accent.withValues(alpha: 0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Customize your experience',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
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
                Tab(text: 'THEME'),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: -0.3, duration: 400.ms, curve: Curves.easeOut);
  }

  /// Build modern bottom action bar
  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface.withValues(alpha: 0.9),
            AppColors.surface,
          ],
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
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
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Save Settings',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
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
          Icons.cloud,
          [
            _buildTextField(
              controller: _apiUrlController,
              label: 'API URL',
              hint: 'https://api.example.com',
              icon: Icons.link,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _apiKeyController,
              label: 'API Key',
              hint: 'Your API key',
              icon: Icons.key,
              obscure: true,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          'Camera',
          Icons.camera_alt,
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
          'Text & Appearance',
          Icons.text_fields,
          [
            _buildSlider(
              label: 'Font Size',
              value: _fontSize,
              min: 12,
              max: 20,
              divisions: 8,
              displayValue: '${_fontSize.toInt()}px',
              onChanged: (v) => setState(() => _fontSize = v),
            ),
            const SizedBox(height: 16),
            _buildSlider(
              label: 'Animation Speed',
              value: _animationSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              displayValue: '${_animationSpeed.toStringAsFixed(1)}x',
              onChanged: (v) => setState(() => _animationSpeed = v),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          'Scanner',
          Icons.qr_code_scanner,
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
          Icons.volume_up,
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
          Icons.storage,
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
      ],
    );
  }

  Widget _buildThemeTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSection(
          'Color Theme',
          Icons.palette,
          [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: ['purple', 'blue', 'cyan', 'green'].map((themeName) {
                final isSelected = themeName == _selectedTheme;
                final colors = AppThemeColors.getThemeColors(themeName);
                
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _selectedTheme = themeName),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: colors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(
                                color: Colors.white,
                                width: 3,
                              )
                            : Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.3),
                            blurRadius: isSelected ? 20 : 10,
                            offset: const Offset(0, 8),
                            spreadRadius: isSelected ? 2 : -2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              AppThemeColors.getThemeIcon(themeName),
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppThemeColors.getThemeDisplayName(themeName),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ).animate().scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 200.ms,
                  curve: Curves.easeOut,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Theme preview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface.withValues(alpha: 0.8),
                    AppColors.surface.withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Preview',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AppThemeColors.getThemeColors(_selectedTheme).primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Primary',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppThemeColors.getThemeColors(_selectedTheme).success,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Success',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
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
    ).animate().slideX(begin: 0.1, duration: 300.ms, curve: Curves.easeOut)
        .fadeIn(duration: 200.ms);
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

