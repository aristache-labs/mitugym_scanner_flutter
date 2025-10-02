import 'package:flutter/material.dart';

/// Control buttons widget
/// Contains Start/Stop, Settings, and Clear Activity buttons
class ControlButtons extends StatelessWidget {
  final bool isScanning;
  final VoidCallback onStartStop;
  final VoidCallback onSettings;
  final VoidCallback onClearActivity;

  const ControlButtons({
    super.key,
    required this.isScanning,
    required this.onStartStop,
    required this.onSettings,
    required this.onClearActivity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Start/Stop button
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: onStartStop,
            icon: Icon(
              isScanning ? Icons.stop : Icons.play_arrow,
              size: 24,
            ),
            label: Text(
              isScanning ? 'STOP' : 'START',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isScanning
                  ? Colors.red
                  : theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Settings button
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: IconButton(
            onPressed: onSettings,
            icon: const Icon(Icons.settings),
            iconSize: 28,
            tooltip: 'Settings',
          ),
        ),
        const SizedBox(width: 12),

        // Clear activity button
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: IconButton(
            onPressed: onClearActivity,
            icon: const Icon(Icons.clear_all),
            iconSize: 28,
            tooltip: 'Clear Activity',
          ),
        ),
      ],
    );
  }
}

