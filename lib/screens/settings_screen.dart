import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../config/app_themes.dart';
import '../providers/config_provider.dart';

/// Modern, clean settings screen
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
    _selectedTheme = config.theme;
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
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'GENERAL'),
            Tab(text: 'DISPLAY'),
            Tab(text: 'AUDIO'),
            Tab(text: 'ADVANCED'),
            Tab(text: 'THEME'),
          ],
        ),
      ),
      body: Form(
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text('Save Settings'),
              ),
            ),
          ],
        ),
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
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: ['blue', 'cyan', 'green', 'purple'].map((themeName) {
                final isSelected = themeName == _selectedTheme;
                final colors = AppThemeColors.getThemeColors(themeName);
                
                return InkWell(
                  onTap: () => setState(() => _selectedTheme = themeName),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: colors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: AppColors.textWhite, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          AppThemeColors.getThemeIcon(themeName),
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppThemeColors.getThemeDisplayName(themeName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isSelected)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Icon(Icons.check_circle, color: Colors.white, size: 18),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
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
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5)),
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                displayValue,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surface,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
            trackHeight: 4,
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
    );
  }

  Widget _buildSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
          Switch(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: AppColors.surface,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
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
    );
  }
}
