import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import '../config/app_colors.dart';

/// Service to manage system tray functionality
class TrayService with TrayListener, WindowListener {
  static final TrayService _instance = TrayService._internal();
  factory TrayService() => _instance;
  TrayService._internal();

  bool _isInitialized = false;
  BuildContext? _context;

  /// Initialize the system tray
  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;
    
    _context = context;
    
    // Set up tray icon
    await trayManager.setIcon(
      Platform.isWindows
          ? 'assets/images/logo.png'
          : 'assets/images/logo.png',
    );
    
    // Set up tray menu
    await _updateTrayMenu();
    
    // Add listeners
    trayManager.addListener(this);
    windowManager.addListener(this);
    
    _isInitialized = true;
  }

  /// Update the tray menu
  Future<void> _updateTrayMenu() async {
    final isVisible = await windowManager.isVisible();
    
    final menu = Menu(
      items: [
        MenuItem(
          key: 'show_hide',
          label: isVisible ? 'Hide Window' : 'Show Window',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'about',
          label: 'About MituGym Scanner',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit',
          label: 'Exit',
        ),
      ],
    );
    
    await trayManager.setContextMenu(menu);
  }

  @override
  void onTrayIconMouseDown() {
    // Show/hide window on tray icon click
    _toggleWindowVisibility();
  }

  @override
  void onTrayIconRightMouseDown() {
    // Show context menu on right-click
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show_hide':
        _toggleWindowVisibility();
        break;
      case 'about':
        _showAboutDialog();
        break;
      case 'exit':
        _exitApplication();
        break;
    }
  }

  /// Toggle window visibility
  Future<void> _toggleWindowVisibility() async {
    final isVisible = await windowManager.isVisible();
    
    if (isVisible) {
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
    }
    
    // Update tray menu to reflect new state
    await _updateTrayMenu();
  }

  /// Show about dialog
  void _showAboutDialog() async {
    await windowManager.show();
    await windowManager.focus();
    
    if (_context != null && _context!.mounted) {
      showAboutDialog(
        context: _context!,
        applicationName: 'MituGym Scanner',
        applicationVersion: '1.0.0',
        applicationIcon: Image.asset(
          'assets/images/logo.png',
          width: 64,
          height: 64,
        ),
        children: [
          const Text('High-performance desktop QR scanner'),
          const SizedBox(height: 8),
          const Text('Built with Flutter'),
        ],
      );
    }
  }

  /// Exit the application
  Future<void> _exitApplication() async {
    await windowManager.destroy();
    exit(0);
  }

  @override
  void onWindowClose() async {
    // This event is triggered when user clicks X button
    // We've set preventClose(true), so we handle the close behavior here
    
    // Always show the dialog to let user choose
    _showCloseDialog();
  }

  @override
  void onWindowFocus() {
    // Update tray menu when window gains focus
    _updateTrayMenu();
  }

  /// Show dialog asking about close behavior
  void _showCloseDialog() {
    if (_context == null || !_context!.mounted) return;

    showDialog(
      context: _context!,
      barrierDismissible: true,
      barrierColor: AppColors.overlay,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 380,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        LucideIcons.power,
                        color: AppColors.primary.withValues(alpha: 0.9),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Close Application',
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Choose an action',
                            style: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.border.withValues(alpha: 0.0),
                      AppColors.border.withValues(alpha: 0.5),
                      AppColors.border.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              
              // Content with buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Minimize to Tray Button
                    _buildActionButton(
                      icon: LucideIcons.minimize2,
                      label: 'Minimize to Tray',
                      onTap: () async {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                        await windowManager.hide();
                        await _updateTrayMenu();
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Exit Button
                    _buildActionButton(
                      icon: LucideIcons.logOut,
                      label: 'Exit Application',
                      onTap: () async {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                        await _exitApplication();
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Cancel Button
                    _buildActionButton(
                      icon: LucideIcons.x,
                      label: 'Cancel',
                      isCancel: true,
                      onTap: () {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build action button for close dialog
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isCancel = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isCancel 
                ? AppColors.surface.withValues(alpha: 0.5)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isCancel
                  ? AppColors.border.withValues(alpha: 0.3)
                  : AppColors.border.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isCancel
                      ? AppColors.textMuted.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  icon,
                  color: isCancel 
                      ? AppColors.textMuted
                      : AppColors.primary.withValues(alpha: 0.9),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    color: isCancel 
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: isCancel
                    ? AppColors.textMuted.withValues(alpha: 0.3)
                    : AppColors.textMuted.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dispose and clean up
  Future<void> dispose() async {
    if (_isInitialized) {
      trayManager.removeListener(this);
      windowManager.removeListener(this);
      await trayManager.destroy();
      _isInitialized = false;
    }
  }
}

