<!-- cccd666e-de1e-4466-9e35-1c7c66b6e387 4be1b7b6-4287-44cd-87fd-5bd2f675134e -->
# Login Authentication System with Offline Support

## Overview

Add email/password login that fetches an API key from the web panel, enables full offline functionality with action queuing, validates sessions on startup, and maintains single-user persistence.

## 1. Backend API Development (Web Panel)

### Create Login API Endpoint

**File**: `c:\Personal\mitugym-app-webpanel\src\app\api\auth\login\route.ts` (new)

```typescript
// POST /api/auth/login
// Request: { email, password, device_name }
// Response: { success, api_key, user_name, location_name }
```

Key features:

- Verify email/password against Supabase Auth
- Generate or retrieve API key for the authenticated user
- Return user info + API key for scanner app
- Log device authentication

### Create Session Validation Endpoint

**File**: `c:\Personal\mitugym-app-webpanel\src\app\api\auth\validate\route.ts` (new)

```typescript
// POST /api/auth/validate
// Request: { api_key }
// Response: { valid: true/false, user_name, location_name }
```

## 2. Flutter Models

### Create Auth Models

**File**: `lib/models/auth_session.dart` (new)

```dart
class AuthSession {
  final String email;
  final String apiKey;
  final String userName;
  final String locationName;
  final DateTime loginTime;
  final DateTime? lastValidated;
}
```

### Create Pending Action Model

**File**: `lib/models/pending_action.dart` (new)

```dart
class PendingAction {
  final String id; // UUID
  final String type; // 'checkin', 'checkout'
  final String qrCode;
  final DateTime timestamp;
  final String apiKey;
  final bool synced;
}
```

## 3. Services

### Auth Service

**File**: `lib/services/auth_service.dart` (new)

Methods:

- `login(email, password, deviceName)` - Call web panel login API
- `validateSession(apiKey)` - Validate existing session on startup
- `logout()` - Clear session data
- `isLoggedIn()` - Check if valid session exists

### Offline Queue Service

**File**: `lib/services/offline_queue_service.dart` (new)

Methods:

- `queueAction(qrCode, action)` - Store scan when offline
- `syncPendingActions()` - Upload queued scans when online
- `getPendingCount()` - Get unsynced action count
- SQLite table: `pending_actions`

### Update Connectivity Service

**File**: `lib/services/connectivity_service.dart`

Add:

- Auto-trigger sync when connection restored
- Emit events for online/offline transitions

## 4. State Management

### Auth Provider

**File**: `lib/providers/auth_provider.dart` (new)

```dart
class AuthState {
  final bool isAuthenticated;
  final AuthSession? session;
  final bool isValidating;
  final String? error;
}
```

Methods:

- `login()` - Authenticate user
- `validateOnStartup()` - Check session validity
- `logout()` - Clear auth state
- `updateLastValidated()` - Track validation time

### Offline Queue Provider

**File**: `lib/providers/offline_queue_provider.dart` (new)

```dart
class OfflineQueueState {
  final List<PendingAction> pendingActions;
  final bool isSyncing;
  final int syncedCount;
}
```

## 5. UI Screens

### Login Screen

**File**: `lib/screens/login_screen.dart` (new)

Features:

- Email input field
- Password input field (obscured)
- Device name input (optional, auto-generate from hostname)
- Login button with loading state
- Error message display
- "Remember Me" toggle
- Offline indicator (can't login when offline)
- Modern gradient design matching app theme

### Update Splash Screen

**File**: `lib/screens/splash_screen.dart`

Add session check:

1. Check if logged in (session exists)
2. If online: validate session with server
3. If valid or offline: proceed to main app
4. If invalid: redirect to login screen

### Update Main Layout

**File**: `lib/screens/main_layout_screen.dart`

Add:

- Offline mode banner with pending sync count
- Queue indicator in header
- Auto-sync trigger on connectivity change

### Update Settings Screen

**File**: `lib/screens/settings_screen.dart`

Add "Account" tab:

- Logged in user info (email, location)
- Last validated timestamp
- Logout button
- Pending actions count + manual sync button
- Remove API URL/Key manual entry (now from login)

## 6. Offline Functionality

### Update Scan Provider

**File**: `lib/providers/scan_provider.dart`

Modify `processScan()`:

```dart
if (isOnline) {
  // Existing API call
  final result = await apiService.checkInOut(qrCode, apiKey);
} else {
  // Queue for later sync
  await offlineQueueService.queueAction(qrCode, 'auto');
  // Show local success message
  // Save to local history as "pending"
}
```

### Update Offline Storage

**File**: `lib/services/offline_storage_service.dart`

Add:

- `pending_actions` table
- Methods to save/retrieve queued actions
- Mark actions as synced after upload

## 7. App Configuration

### Update App Config

**File**: `lib/config/app_config.dart`

Add fields:

```dart
final String? userEmail;
final String? userName;
final String? locationName;
final DateTime? sessionValidatedAt;
```

Remove:

- Direct API key entry (now from login)
- Keep API URL for flexibility

## 8. App Flow

### Startup Flow

```
1. Splash Screen
   ↓
2. Check saved session
   ↓
3a. No session → Login Screen
3b. Has session + Online → Validate with server
   ↓
4. Valid session → Main App
5. Invalid session → Login Screen
```

### Login Flow

```
1. User enters email/password
   ↓
2. Check connectivity
   ↓
3a. Offline → Show error "Must be online to login"
3b. Online → Call /api/auth/login
   ↓
4. Receive API key + user info
   ↓
5. Save session to SharedPreferences
   ↓
6. Navigate to Main App
```

### Offline Scan Flow

```
1. User scans QR code
   ↓
2. Check connectivity
   ↓
3a. Online → API call (existing)
3b. Offline → Queue action locally
   ↓
4. Save to pending_actions table
   ↓
5. Show success message "Queued for sync"
   ↓
6. Display in history with "Pending" badge
```

### Sync Flow

```
1. App detects online connection
   ↓
2. Fetch pending actions from DB
   ↓
3. Upload each action to /api/checkin
   ↓
4. Mark as synced if successful
   ↓
5. Update local history records
   ↓
6. Clear synced actions
   ↓
7. Refresh UI
```

## 9. Database Migrations

### SQLite Schema Updates

**File**: `lib/services/offline_storage_service.dart`

Add table:

```sql
CREATE TABLE pending_actions (
  id TEXT PRIMARY KEY,
  qr_code TEXT NOT NULL,
  action TEXT NOT NULL,
  api_key TEXT NOT NULL,
  timestamp INTEGER NOT NULL,
  synced INTEGER DEFAULT 0,
  retry_count INTEGER DEFAULT 0,
  error TEXT
)
```

Update `checkin_history` table:

```sql
ALTER TABLE checkin_history ADD COLUMN sync_status TEXT DEFAULT 'synced';
-- Values: 'synced', 'pending', 'failed'
```

## 10. Security Considerations

- Store API key encrypted in SharedPreferences (use flutter_secure_storage)
- Don't log passwords or API keys
- Clear sensitive data on logout
- Add session timeout (e.g., re-validate after 24 hours)
- Handle failed validation gracefully (allow offline use, require online re-auth)

## 11. UI Indicators

### Pending Sync Badge

Display in:

- Sidebar (next to History/Dashboard)
- Settings screen
- Offline banner

### Session Status

Display in Settings:

- "Logged in as: user@example.com"
- "Location: Gym Name"
- "Last validated: 2 hours ago"
- "Status: Online ✓" or "Offline (X pending)"

## Key Files Summary

**New Files**:

- `lib/screens/login_screen.dart`
- `lib/models/auth_session.dart`
- `lib/models/pending_action.dart`
- `lib/services/auth_service.dart`
- `lib/services/offline_queue_service.dart`
- `lib/providers/auth_provider.dart`
- `lib/providers/offline_queue_provider.dart`

**Modified Files**:

- `lib/main.dart` (add AuthProvider)
- `lib/screens/splash_screen.dart` (session validation)
- `lib/screens/main_layout_screen.dart` (offline banner, sync triggers)
- `lib/screens/settings_screen.dart` (account tab, remove API key entry)
- `lib/providers/scan_provider.dart` (offline queuing)
- `lib/services/offline_storage_service.dart` (pending actions table)
- `lib/config/app_config.dart` (session fields)

**Backend API** (Web Panel):

- `/api/auth/login` (new)
- `/api/auth/validate` (new)