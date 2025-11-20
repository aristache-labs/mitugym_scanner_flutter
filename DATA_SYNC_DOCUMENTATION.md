# Data Sync Service Documentation

## Overview

The `DataSyncService` is a comprehensive synchronization coordinator that ensures all data across the app stays up-to-date. It's automatically triggered after QR code scans and when the device reconnects to the internet.

## Features

### Automatic Sync Triggers

1. **After QR Code Scan** - Quick sync of history data
2. **Connection Restored** - Full sync including offline queue
3. **Manual Sync** - User-initiated full refresh

### Sync Components

The service coordinates synchronization of:

- **History Data** - Recent check-in/check-out activity logs
- **Gym Schedule** - Current day's operating hours
- **Offline Queue** - Pending actions from offline scans

## Service Architecture

### Main Service: `DataSyncService`

Located in: `lib/services/data_sync_service.dart`

#### Main Methods

```dart
// Sync all data with custom options
Future<SyncResult> syncAllData({
  bool forceSync = false,
  bool syncHistory = true,
  bool syncSchedule = true,
  bool syncOfflineQueue = true,
})

// Quick sync - only essential data (history)
Future<SyncResult> quickSync()

// Full sync - all data including schedule and offline queue
Future<SyncResult> fullSync()

// Sync after coming back online
Future<SyncResult> syncAfterReconnect()
```

### Integration Points

#### 1. Scan Provider (`lib/providers/scan_provider.dart`)

After a successful QR code scan:
```dart
Future.delayed(const Duration(milliseconds: 500), () {
  _syncAllData(); // Calls dataSyncService.quickSync()
});
```

#### 2. Offline Provider (`lib/providers/offline_provider.dart`)

When device reconnects to internet:
```dart
Future<void> _triggerAutoSync() async {
  final syncService = ref.read(dataSyncServiceProvider);
  final result = await syncService.syncAfterReconnect();
  // Handle result...
}
```

## Usage Examples

### Manual Sync in UI

```dart
// In your widget
final syncService = ref.read(dataSyncServiceProvider);

// Full sync button
ElevatedButton(
  onPressed: () async {
    final result = await syncService.fullSync();
    if (result.success) {
      // Show success message
    } else {
      // Show error: result.errors
    }
  },
  child: Text('Refresh All Data'),
)
```

### Custom Sync Operation

```dart
// Sync only history and schedule, skip offline queue
final result = await syncService.syncAllData(
  syncHistory: true,
  syncSchedule: true,
  syncOfflineQueue: false,
);
```

### Check Sync Status

```dart
final syncService = ref.read(dataSyncServiceProvider);

if (syncService.isSyncing) {
  // Show loading indicator
}
```

## Sync Result

The service returns a `SyncResult` object:

```dart
class SyncResult {
  final bool success;              // Overall success
  final String message;            // Summary message
  final Map<String, bool> syncedItems; // Individual component results
  final List<String> errors;       // Error messages if any
  final Duration? duration;        // Time taken to sync
}
```

### Example Result Handling

```dart
final result = await syncService.fullSync();

print(result.success);           // true or false
print(result.message);           // "All data synced successfully"
print(result.syncedItems);       // {history: true, schedule: true, offlineQueue: true}
print(result.errors);            // [] if no errors
print(result.duration);          // Duration(milliseconds: 1234)
```

## Sync Flow

### After QR Code Scan

1. User scans QR code
2. API processes check-in/check-out
3. Member data saved locally
4. Success/error feedback played
5. **500ms delay**
6. `quickSync()` triggered
   - Refreshes history from server
   - Updates dashboard with latest data

### After Reconnection

1. Device detects internet connection
2. `syncAfterReconnect()` triggered
3. Syncs in order:
   - Offline queue (pending scans)
   - History from server
   - Gym schedule
4. Updates all UI components

## Error Handling

The service is resilient to errors:

- Individual sync failures don't stop the entire process
- All errors are logged and returned in the result
- Partial success is supported (some components sync, others fail)

```dart
final result = await syncService.fullSync();

if (!result.success) {
  for (final error in result.errors) {
    print('Sync error: $error');
  }
  
  // Check which components succeeded
  if (result.syncedItems['history'] == true) {
    print('History synced successfully');
  }
  if (result.syncedItems['schedule'] == false) {
    print('Schedule sync failed');
  }
}
```

## Performance Considerations

- **Quick Sync**: ~100-500ms (history only)
- **Full Sync**: ~500-2000ms (all components)
- Duplicate sync calls are prevented with `_isSyncing` flag
- 500ms delay after scans allows server processing time

## Logging

The service provides detailed logging:

```
🔄 Starting comprehensive data sync...
📤 Syncing offline queue...
✅ Offline queue synced (3 items)
📥 Syncing history from server...
✅ History synced successfully
📅 Refreshing gym schedule...
✅ Gym schedule refreshed
✅ All data synced successfully in 1234ms
```

## Best Practices

1. **Use Quick Sync After Scans** - Faster, only syncs essential data
2. **Use Full Sync On Startup** - Ensures everything is fresh
3. **Check isSyncing** - Prevent duplicate operations
4. **Handle Errors Gracefully** - Show user-friendly messages
5. **Log Results** - Monitor sync health in production

## Future Enhancements

Potential additions:
- Member list sync
- Settings sync across devices
- Background periodic sync
- Selective history range sync
- Sync retry with exponential backoff

