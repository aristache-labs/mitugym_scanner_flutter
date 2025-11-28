import 'package:flutter/material.dart';
import '../services/windows_qr_scanner_service.dart';
import 'windows_camera_preview_widget.dart';
import '../l10n/app_localizations.dart';
import '../utils/safe_preferences.dart';

/// Collapsible camera widget with toggle button
/// Allows hiding/showing the camera preview to save space
class CollapsibleCameraWidget extends StatefulWidget {
  final WindowsQRScannerService? scannerService;
  final bool isScanning;
  final String statusMessage;

  const CollapsibleCameraWidget({
    super.key,
    required this.scannerService,
    required this.isScanning,
    required this.statusMessage,
  });

  @override
  State<CollapsibleCameraWidget> createState() => _CollapsibleCameraWidgetState();
}

class _CollapsibleCameraWidgetState extends State<CollapsibleCameraWidget>
    with SingleTickerProviderStateMixin {
  bool _isVisible = true;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _loadVisibilityState();
    
    // Setup animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _heightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    if (_isVisible) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Load camera visibility state from preferences
  Future<void> _loadVisibilityState() async {
    final visible = await SafePreferences.getBool('cameraVisible') ?? true;
    if (mounted && visible != _isVisible) {
      setState(() {
        _isVisible = visible;
        if (_isVisible) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    }
  }

  /// Toggle camera visibility
  Future<void> _toggleVisibility() async {
    setState(() {
      _isVisible = !_isVisible;
      if (_isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
    
    // Save state to preferences
    await SafePreferences.setBool('cameraVisible', _isVisible);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Toggle button - fixed height
            SizedBox(
              height: 56,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.cameraPreview,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Row(
                      children: [
                        // Status indicator
                        if (!_isVisible)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.isScanning ? Colors.green : Colors.red,
                              boxShadow: widget.isScanning
                                  ? [
                                      BoxShadow(
                                        color: Colors.green.withValues(alpha: 0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        // Toggle button
                        IconButton(
                          icon: AnimatedRotation(
                            turns: _isVisible ? 0 : 0.5,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              _isVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                          ),
                          onPressed: _toggleVisibility,
                          tooltip: _isVisible ? 'Hide Camera' : 'Show Camera',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Animated camera preview or status message
            Expanded(
              child: _isVisible
                  ? SizeTransition(
                      sizeFactor: _heightAnimation,
                      axisAlignment: -1.0,
                      child: WindowsCameraPreviewWidget(
                        scannerService: widget.scannerService,
                        isScanning: widget.isScanning,
                        statusMessage: widget.statusMessage,
                      ),
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.isScanning ? Icons.qr_code_scanner : Icons.pause_circle,
                              size: 20,
                              color: widget.isScanning ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                widget.statusMessage,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

