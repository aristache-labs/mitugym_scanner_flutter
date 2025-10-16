import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../providers/offline_provider.dart';
import '../providers/offline_queue_provider.dart';

/// Offline mode banner that appears at the top when no internet connection
class OfflineBannerWidget extends ConsumerWidget {
  const OfflineBannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(offlineProvider);
    final queueState = ref.watch(offlineQueueProvider);
    final pendingCount = queueState.pendingActions.length;
    
    if (offlineState.isOnline && pendingCount == 0) {
      return const SizedBox.shrink();
    }

    // Show banner if offline OR if there are pending actions
    final showOfflineBanner = !offlineState.isOnline;
    final showSyncingBanner = offlineState.isOnline && queueState.isSyncing;
    final showPendingBanner = offlineState.isOnline && pendingCount > 0 && !queueState.isSyncing;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: (showOfflineBanner || showSyncingBanner || showPendingBanner) ? 60 : 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border(
            bottom: BorderSide(
              color: showOfflineBanner
                  ? AppColors.error.withValues(alpha: 0.3)
                  : showSyncingBanner
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : AppColors.accent.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Icon with colored background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: showOfflineBanner
                        ? [AppColors.error, AppColors.error.withValues(alpha: 0.8)]
                        : showSyncingBanner
                            ? [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)]
                            : [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (showOfflineBanner
                              ? AppColors.error
                              : showSyncingBanner
                                  ? AppColors.primary
                                  : AppColors.accent)
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  showOfflineBanner
                      ? Icons.cloud_off_rounded
                      : showSyncingBanner
                          ? Icons.sync_rounded
                          : Icons.pending_actions_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              
              // Message - Centered
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    showOfflineBanner
                        ? 'Offline Mode'
                        : showSyncingBanner
                            ? 'Syncing...'
                            : 'Pending Sync',
                    style: GoogleFonts.inter(
                      color: showOfflineBanner
                          ? AppColors.error
                          : showSyncingBanner
                              ? AppColors.primary
                              : AppColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    showOfflineBanner
                        ? pendingCount > 0
                            ? '$pendingCount action${pendingCount > 1 ? 's' : ''} queued for sync'
                            : 'Scans will be saved locally'
                        : showSyncingBanner
                            ? 'Uploading ${queueState.syncedCount} of $pendingCount actions...'
                            : '$pendingCount action${pendingCount > 1 ? 's' : ''} waiting to sync',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Action button - Pending count badge
              if (showOfflineBanner && pendingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.pending_actions_rounded,
                        color: AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$pendingCount',
                        style: GoogleFonts.inter(
                          color: AppColors.error,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (showPendingBanner) ...[
                ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(offlineQueueProvider.notifier).syncPendingActions();
                  },
                  icon: const Icon(Icons.sync_rounded, color: Colors.white, size: 16),
                  label: Text(
                    'Sync Now',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      // Show confirmation dialog
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.card,
                          title: Text('Clear Queue', style: GoogleFonts.inter(color: AppColors.textPrimary)),
                          content: Text(
                            'Clear all $pendingCount pending actions? This cannot be undone.',
                            style: GoogleFonts.inter(color: AppColors.textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Clear', style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirmed == true) {
                        await ref.read(offlineQueueProvider.notifier).clearAllPending();
                      }
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                    tooltip: 'Clear queue',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
              
              if (showSyncingBanner)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Offline mode indicator for sidebar (small badge)
class OfflineIndicatorWidget extends ConsumerWidget {
  const OfflineIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(offlineProvider);
    final queueState = ref.watch(offlineQueueProvider);
    final pendingCount = queueState.pendingActions.length;
    
    if (offlineState.isOnline && pendingCount == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Online',
            style: GoogleFonts.inter(
              color: AppColors.success,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: offlineState.isOnline
            ? AppColors.accent.withValues(alpha: 0.2)
            : AppColors.warning.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: offlineState.isOnline ? AppColors.accent : AppColors.warning,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            offlineState.isOnline ? Icons.pending_actions : Icons.cloud_off,
            color: offlineState.isOnline ? AppColors.accent : AppColors.warning,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            offlineState.isOnline ? 'Pending' : 'Offline',
            style: GoogleFonts.inter(
              color: offlineState.isOnline ? AppColors.accent : AppColors.warning,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (pendingCount > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: offlineState.isOnline ? AppColors.accent : AppColors.warning,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$pendingCount',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Offline sync dialog showing pending items
class OfflineSyncDialog extends ConsumerWidget {
  const OfflineSyncDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(offlineProvider);
    
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.sync,
              color: AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Offline Sync',
            style: TextStyle(color: AppColors.text),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            offlineState.isOnline
                ? 'Connection restored!'
                : 'No internet connection detected.',
            style: TextStyle(
              color: AppColors.muted.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          
          if (offlineState.pendingSyncCount > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.pending_actions,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pending Syncs',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${offlineState.pendingSyncCount} check-in${offlineState.pendingSyncCount > 1 ? 's' : ''} waiting',
                          style: TextStyle(
                            color: AppColors.muted.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              offlineState.isOnline
                  ? 'Items will sync automatically when connection is restored.'
                  : 'Scans are being saved locally and will sync when online.',
              style: TextStyle(
                color: AppColors.muted.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All items synced',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (offlineState.pendingSyncCount > 0 && offlineState.isOnline)
          TextButton.icon(
            onPressed: () {
              ref.read(offlineProvider.notifier).syncNow();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.sync, size: 18),
            label: const Text('Sync Now'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Close',
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      ],
    );
  }
}

