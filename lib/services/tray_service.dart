import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import '../config/app_colors.dart';
import '../main.dart' show navigatorKey;
import '../widgets/about_dialog_widget.dart';

/// Service to manage system tray functionality
class TrayService with TrayListener, WindowListener {
  static final TrayService _instance = TrayService._internal();
  factory TrayService() => _instance;
  TrayService._internal();

  bool _isInitialized = false;

  /// Initialize the system tray
  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;
    
    // Set up tray icon
    // Windows: Use .ico for best results in system tray
    // macOS/Linux: Use .png
    await trayManager.setIcon(
      Platform.isWindows
          ? 'assets/images/logo.ico'
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
    
    // Get the current navigator context from global key
    final navigatorContext = navigatorKey.currentContext;
    
    if (navigatorContext != null && navigatorContext.mounted) {
      showPremiumAboutDialog(navigatorContext);
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
    // Get the current navigator context from global key (works even after logout/navigation changes)
    final navigatorContext = navigatorKey.currentContext;
    
    if (navigatorContext == null || !navigatorContext.mounted) {
      // If no valid context, just exit the application
      _exitApplication();
      return;
    }

    showDialog(
      context: navigatorContext,
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
    return _ActionButton(
      icon: icon,
      label: label,
      onTap: onTap,
      isCancel: isCancel,
    );
  }
}

/// Stateful action button with hover and press animations
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isCancel;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isCancel = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: Transform.scale(
          scale: _isPressed ? 0.98 : 1.0,
          child: Transform.translate(
            offset: Offset(0.0, _isPressed ? 1.0 : 0.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
            color: _isHovered
                ? (widget.isCancel 
                    ? AppColors.surface.withValues(alpha: 0.7)
                    : AppColors.cardHover)
                : (widget.isCancel 
                    ? AppColors.surface.withValues(alpha: 0.5)
                    : AppColors.surface),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered
                  ? (widget.isCancel
                      ? AppColors.border.withValues(alpha: 0.5)
                      : AppColors.primary.withValues(alpha: 0.4))
                  : (widget.isCancel
                      ? AppColors.border.withValues(alpha: 0.3)
                      : AppColors.border.withValues(alpha: 0.5)),
              width: 1,
            ),
            boxShadow: _isHovered && !widget.isCancel
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? (widget.isCancel
                          ? AppColors.textMuted.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.2))
                      : (widget.isCancel
                          ? AppColors.textMuted.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isCancel 
                      ? AppColors.textMuted
                      : AppColors.primary.withValues(alpha: 0.9),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  style: GoogleFonts.inter(
                    color: _isHovered
                        ? (widget.isCancel 
                            ? AppColors.textSecondary
                            : AppColors.textWhite)
                        : (widget.isCancel 
                            ? AppColors.textMuted
                            : AppColors.textPrimary),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                  child: Text(widget.label),
                ),
              ),
              Transform.translate(
                offset: Offset(_isHovered ? 2.0 : 0.0, 0.0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  opacity: 1.0,
                  child: Icon(
                    LucideIcons.chevronRight,
                    color: widget.isCancel
                        ? AppColors.textMuted.withValues(alpha: _isHovered ? 0.5 : 0.3)
                        : AppColors.textMuted.withValues(alpha: _isHovered ? 0.7 : 0.5),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
            ),
          ),
        ),
      ),
    );
  }
}

class TrayServiceExtension {
  /// Dispose and clean up the tray service
  static Future<void> disposeTrayService(TrayService service) async {
    await service.dispose();
  }
}

// Extension on TrayService to add dispose method
extension TrayServiceDispose on TrayService {
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

