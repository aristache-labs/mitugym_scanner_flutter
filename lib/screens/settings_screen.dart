import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../providers/config_provider.dart';
import '../providers/windows_scanner_provider.dart';

/// Settings screen
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _apiUrlController;
  late TextEditingController _apiKeyController;
  late double _debounceDuration;
  late bool _audioEnabled;

  @override
  void initState() {
    super.initState();
    final config = ref.read(configProvider);
    _apiUrlController = TextEditingController(text: config.apiUrl);
    _apiKeyController = TextEditingController(text: config.apiKey);
    _debounceDuration = config.debounceDuration.toDouble();
    _audioEnabled = config.audioEnabled;
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newConfig = AppConfig(
      apiUrl: _apiUrlController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      debounceDuration: _debounceDuration.toInt(),
      audioEnabled: _audioEnabled,
    );

    await ref.read(configProvider.notifier).updateConfig(newConfig);
    
    // Update scanner debounce duration
    ref.read(windowsScannerControllerProvider.notifier)
        .updateDebounceDuration(_debounceDuration.toInt());

    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // API Configuration Section
            Text(
              'API Configuration',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // API URL Field
            TextFormField(
              controller: _apiUrlController,
              decoration: const InputDecoration(
                labelText: 'API URL',
                hintText: 'https://mitugym-app-webpanel.vercel.app',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter API URL';
                }
                if (!value.startsWith('http://') && !value.startsWith('https://')) {
                  return 'URL must start with http:// or https://';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // API Key Field
            TextFormField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'Enter your API key',
                prefixIcon: Icon(Icons.key),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter API key';
                }
                if (value.length < 16) {
                  return 'API key seems too short';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Scanner Settings Section
            Text(
              'Scanner Settings',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Debounce Duration Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan Cooldown: ${_debounceDuration.toInt()} seconds',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _debounceDuration,
                  min: 3,
                  max: 10,
                  divisions: 7,
                  label: '${_debounceDuration.toInt()}s',
                  onChanged: (value) {
                    setState(() {
                      _debounceDuration = value;
                    });
                  },
                ),
                Text(
                  'Time to wait before allowing the next scan',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Audio Settings
            SwitchListTile(
              title: const Text('Audio Feedback'),
              subtitle: const Text('Play sounds for scan results'),
              value: _audioEnabled,
              onChanged: (value) {
                setState(() {
                  _audioEnabled = value;
                });
              },
              secondary: const Icon(Icons.volume_up),
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Text('Save Settings'),
              ),
            ),
            const SizedBox(height: 16),

            // Reset to Defaults Button
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset Settings'),
                    content: const Text(
                      'Are you sure you want to reset all settings to defaults?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await ref.read(configProvider.notifier).resetToDefaults();
                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Reset to Defaults'),
            ),
          ],
        ),
      ),
    );
  }
}

