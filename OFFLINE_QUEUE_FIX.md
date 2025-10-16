# Offline Queue API Key Fix

## Issue
When scanning QR codes offline, the queued actions were using the **staff member's personal API key** (from login), but the `/api/checkin` endpoint expects the **location's API key** (from Settings).

This caused 401 errors when syncing:
```
⛔ DioException: badResponse - status code 401
🐛 Response data: {success: false, message: Invalid API key, error: Authentication failed}
```

## Solution
Updated `lib/providers/scan_provider.dart` to use **two separate API keys**:

### 1. User API Key (from login)
- **Purpose**: Authentication & validation
- **Used for**: Logging into the scanner app, validating sessions
- **Source**: `authProvider.session.apiKey`

### 2. Location API Key (from settings)
- **Purpose**: Check-in/out operations
- **Used for**: All QR code scans (online and offline queued)
- **Source**: `configProvider.apiKey`

## Changes Made

### File: `lib/providers/scan_provider.dart`

**Before:**
```dart
// Used auth session API key (wrong!)
final apiKey = authState.session?.apiKey ?? config.apiKey;
await _apiService.checkInOut(qrCode, apiKey);
await _handleOfflineScan(qrCode, apiKey);
```

**After:**
```dart
// Use location API key from settings (correct!)
final locationApiKey = config.apiKey;
await _apiService.checkInOut(qrCode, locationApiKey);
await _handleOfflineScan(qrCode, locationApiKey);
```

## Testing

### 1. Test Offline Queue
1. Go to QR Scanner page
2. Disconnect from internet (turn off WiFi)
3. Scan a member's QR code
4. ✅ Should hear success sound
5. ✅ Should see "Queued for sync" message
6. ✅ Offline banner should show "1 action queued for sync"

### 2. Test Sync When Online
1. Reconnect to internet (turn on WiFi)
2. Banner should change to "Pending Sync" with "Sync Now" button
3. Click "Sync Now"
4. ✅ Should sync successfully (no 401 error!)
5. ✅ Banner should disappear
6. ✅ Check-in should appear in Dashboard/History

### 3. Test Connection Error
1. While online, scan a QR code
2. If connection fails (timeout, etc.)
3. ✅ Should automatically queue the scan
4. ✅ Should sync when connection restored

## API Key Configuration

Make sure the **Location API Key** is set in Settings:

1. Go to Settings > API Configuration
2. Enter the **Location/Gym API Key** (not your personal user API key)
3. This is the API key that has permission to check members in/out
4. Save settings

## Architecture

```
┌─────────────────────────────────────────────┐
│         SCANNER APP LOGIN                   │
│  Email: staff@gym.com                       │
│  Password: ••••••••                         │
│                                             │
│  → Generates: USER API KEY                  │
│    (for authentication only)                │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│         SCANNER APP SETTINGS                │
│  API URL: https://your-gym.vercel.app       │
│  API Key: LOCATION_API_KEY                  │
│                                             │
│  → This key is used for all scans           │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│         SCAN QR CODE                        │
│  QR: member-id:timestamp                    │
│                                             │
│  → Calls: /api/checkin                      │
│  → With: LOCATION_API_KEY                   │
│  → Result: Check-in successful              │
└─────────────────────────────────────────────┘
```

## TOTP / 2FA Notes

- **Staff accounts**: Login uses email + password (TOTP optional)
- **Member accounts**: May use TOTP in mobile app
- **Scanner app**: Staff login is one-time setup per device
- **Offline scans**: Work even when offline, sync later

If staff accounts have TOTP enabled, the login flow would need to be updated to support two-factor authentication. Current implementation assumes TOTP is disabled for staff accounts.

## Status
✅ **FIXED** - Offline queue now uses correct API key
✅ **TESTED** - Scans queue successfully when offline
✅ **READY** - Ready for production testing

