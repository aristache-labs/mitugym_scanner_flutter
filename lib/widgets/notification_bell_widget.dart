import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config/app_colors.dart';
import '../models/admin_notification.dart';
import '../providers/notification_provider.dart';

/// Notification bell widget with dropdown
class NotificationBell extends ConsumerStatefulWidget {
  const NotificationBell({super.key});

  @override
  ConsumerState<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<NotificationBell> {
  bool _isOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Background overlay to close on tap
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _toggleDropdown();
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Dropdown content
          Positioned(
            width: 750,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(-700, 50), // Position below the bell icon
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: Colors.transparent,
                child: _NotificationDropdown(
                  onClose: _toggleDropdown,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    final unreadCount = notificationState.unreadCount;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleDropdown,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  LucideIcons.bell,
                  color: AppColors.textPrimary.withValues(alpha: 0.9),
                  size: 20,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF4DD4D4), // Cyan/teal from web panel
                            const Color(0xFF3FBABA),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4DD4D4).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF0A0F0F), // Dark text on cyan badge
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Notification dropdown content
class _NotificationDropdown extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const _NotificationDropdown({required this.onClose});

  @override
  ConsumerState<_NotificationDropdown> createState() =>
      _NotificationDropdownState();
}

class _NotificationDropdownState extends ConsumerState<_NotificationDropdown> {
  bool _isLoading = false;

  Future<void> _markAllAsRead() async {
    setState(() {
      _isLoading = true;
    });
    await ref.read(notificationProvider.notifier).markAllAsRead();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteAllNotifications() async {
    setState(() {
      _isLoading = true;
    });
    await ref.read(notificationProvider.notifier).deleteAllNotifications();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    final notifications = notificationState.notifications;
    final unreadCount = notificationState.unreadCount;

    return Container(
      constraints: const BoxConstraints(
        maxHeight: 600,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0f1414), // Match web panel dark background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4DD4D4).withValues(alpha: 0.08), // Cyan border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF4DD4D4).withValues(alpha: 0.02), // Cyan glow
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4DD4D4).withValues(alpha: 0.1), // Cyan gradient
                  const Color(0xFF4DD4D4).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF4DD4D4).withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifications',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (notifications.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          unreadCount > 0 ? '$unreadCount unread' : 'All caught up',
                          style: GoogleFonts.inter(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (notifications.isNotEmpty) ...[
                  if (unreadCount > 0)
                    TextButton.icon(
                      onPressed: _isLoading ? null : _markAllAsRead,
                      icon: const Icon(LucideIcons.checkCheck, size: 14),
                      label: const Text('Mark all'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4DD4D4), // Cyan
                        backgroundColor: const Color(0xFF4DD4D4).withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _isLoading ? null : _deleteAllNotifications,
                    icon: const Icon(LucideIcons.trash2, size: 14),
                    label: const Text('Clear all'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFef4444), // Red
                      backgroundColor: const Color(0xFFef4444).withValues(alpha: 0.1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(LucideIcons.x, size: 16),
                  color: AppColors.textMuted,
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),

          // Notifications list
          if (notifications.isEmpty)
            _buildEmptyState()
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _NotificationItem(
                    notification: notification,
                    onMarkAsRead: () async {
                      await ref
                          .read(notificationProvider.notifier)
                          .markAsRead(notification.id);
                    },
                    onDelete: () async {
                      await ref
                          .read(notificationProvider.notifier)
                          .deleteNotification(notification.id);
                    },
                  );
                },
              ),
            ),

          // Footer
          if (notifications.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFF4DD4D4).withValues(alpha: 0.05), // Cyan
                  ],
                ),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFF4DD4D4).withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'Showing ${notifications.length} notification${notifications.length != 1 ? 's' : ''}',
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4DD4D4).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.bell,
              size: 32,
              color: const Color(0xFF4DD4D4).withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You\'re all caught up! New notifications will appear here.',
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Individual notification item
class _NotificationItem extends StatefulWidget {
  final AdminNotification notification;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const _NotificationItem({
    required this.notification,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  @override
  State<_NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<_NotificationItem> {
  bool _isHovered = false;

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: widget.notification.isRead
              ? const Color(0xFF0f1414)
              : const Color(0xFF4DD4D4).withValues(alpha: 0.08),
          border: Border(
            left: BorderSide(
              color: widget.notification.isRead
                  ? AppColors.textMuted.withValues(alpha: 0.5)
                  : const Color(0xFF4DD4D4).withValues(alpha: 0.5),
              width: 3,
            ),
            bottom: BorderSide(
              color: AppColors.border.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.notification.isRead ? null : widget.onMarkAsRead,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon with NEW badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: widget.notification.isRead
                            ? const LinearGradient(
                                colors: [Color(0xFF0f1414), Color(0xFF141a1a)],
                              )
                            : LinearGradient(
                                colors: [
                                  const Color(0xFF4DD4D4).withValues(alpha: 0.3),
                                  const Color(0xFF4DD4D4).withValues(alpha: 0.15),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.notification.isRead
                              ? const Color(0xFF4DD4D4).withValues(alpha: 0.2)
                              : const Color(0xFF4DD4D4).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.notification.type.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    if (!widget.notification.isRead)
                      Positioned(
                        top: -2,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4DD4D4), Color(0xFF3FBABA)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4DD4D4).withValues(alpha: 0.4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            'NEW',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF0A0F0F),
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Content - Takes ALL remaining space
                Expanded(
                  child: Container(
                    color: Colors.transparent, // Debug helper
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title and time
                        Row(
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                widget.notification.title,
                                style: GoogleFonts.inter(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '•',
                                style: GoogleFonts.inter(
                                  color: AppColors.textMuted.withValues(alpha: 0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              _formatTimeAgo(widget.notification.createdAt),
                              style: GoogleFonts.inter(
                                color: AppColors.textMuted.withValues(alpha: 0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Message text - uses full width
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            widget.notification.message.replaceAll(RegExp(r'[\r\n]+'), ' '),
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Action buttons - show on hover
                if (_isHovered) ...[
                  const SizedBox(width: 8),
                  if (!widget.notification.isRead)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF4DD4D4).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: widget.onMarkAsRead,
                        icon: const Icon(LucideIcons.check, size: 16),
                        color: const Color(0xFF4DD4D4),
                        splashRadius: 20,
                        tooltip: 'Mark as read',
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFef4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: widget.onDelete,
                      icon: const Icon(LucideIcons.trash2, size: 16),
                      color: const Color(0xFFef4444),
                      splashRadius: 20,
                      tooltip: 'Delete',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}
