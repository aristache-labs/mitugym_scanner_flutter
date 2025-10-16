# Testing Login Authentication System

## Prerequisites

Before testing, ensure the following Supabase tables exist:

### 1. `api_keys` table
```sql
CREATE TABLE IF NOT EXISTS api_keys (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  key TEXT NOT NULL UNIQUE,
  name TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 2. `device_logins` table
```sql
CREATE TABLE IF NOT EXISTS device_logins (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  device_name TEXT,
  api_key TEXT,
  logged_in_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 3. `locations` table (should already exist)
Verify it has:
- `id` (UUID)
- `name` (TEXT)

### 4. `profiles` table (should already exist)
Verify it has:
- `id` (UUID)
- `first_name` (TEXT)
- `last_name` (TEXT)
- `location_id` (UUID) - foreign key to locations

---

## Backend API Testing

### Test 1: Login API

**Endpoint**: `POST /api/auth/login`

**Using cURL:**
```bash
curl -X POST https://mitugym-app-webpanel.vercel.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "your-email@example.com",
    "password": "your-password",
    "device_name": "Test Scanner"
  }'
```

**Expected Response (Success):**
```json
{
  "success": true,
  "api_key": "abc123...",
  "user_name": "John Doe",
  "location_name": "Main Gym",
  "email": "your-email@example.com"
}
```

**Expected Response (Failure):**
```json
{
  "success": false,
  "error": "Invalid email or password"
}
```

### Test 2: Validate API

**Endpoint**: `POST /api/auth/validate`

**Using cURL:**
```bash
curl -X POST https://mitugym-app-webpanel.vercel.app/api/auth/validate \
  -H "Content-Type: application/json" \
  -d '{
    "api_key": "your-api-key-from-login"
  }'
```

**Expected Response (Valid):**
```json
{
  "valid": true,
  "user_name": "John Doe",
  "location_name": "Main Gym"
}
```

**Expected Response (Invalid):**
```json
{
  "valid": false,
  "error": "Invalid or inactive API key"
}
```

---

## Flutter App Testing

### Step 1: Deploy Backend APIs

1. Push changes to Vercel:
```bash
cd c:\Personal\mitugym-app-webpanel
git add .
git commit -m "Add login and session validation APIs"
git push
```

2. Wait for Vercel deployment to complete

### Step 2: Run Flutter App

1. Ensure dependencies are installed:
```bash
cd c:\Personal\mitugym_scanner_flutter
flutter pub get
```

2. Run the app:
```bash
flutter run -d windows
```

### Step 3: Test Auth Models

Create a test file to verify models work:

**File**: `test/auth_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mitugym_scanner_flutter/models/auth_session.dart';
import 'package:mitugym_scanner_flutter/models/pending_action.dart';

void main() {
  test('AuthSession serialization', () {
    final session = AuthSession(
      email: 'test@example.com',
      apiKey: 'test-key',
      userName: 'Test User',
      locationName: 'Test Location',
      loginTime: DateTime.now(),
    );

    final json = session.toJson();
    final restored = AuthSession.fromJson(json);

    expect(restored.email, session.email);
    expect(restored.apiKey, session.apiKey);
  });

  test('PendingAction creation', () {
    final action = PendingAction.create(
      qrCode: 'test-qr',
      apiKey: 'test-key',
    );

    expect(action.qrCode, 'test-qr');
    expect(action.synced, false);
    expect(action.retryCount, 0);
  });
}
```

Run tests:
```bash
flutter test test/auth_test.dart
```

### Step 4: Test Database Migrations

The app will auto-migrate on first run. Check logs for:
```
[INFO] Initializing offline database at: ...
[INFO] Created pending_actions table
[INFO] Added sync_status column to checkin_history table
```

### Step 5: Manual API Testing from Dart

Create a test script:

**File**: `test_scripts/test_auth_service.dart`
```dart
import 'package:mitugym_scanner_flutter/services/auth_service.dart';

void main() async {
  final authService = AuthService(
    apiUrl: 'https://mitugym-app-webpanel.vercel.app',
  );

  print('Testing login...');
  try {
    final session = await authService.login(
      email: 'your-email@example.com',
      password: 'your-password',
      deviceName: 'Test Device',
    );
    
    print('✅ Login successful!');
    print('API Key: ${session.apiKey}');
    print('User: ${session.userName}');
    print('Location: ${session.locationName}');
    
    // Test validation
    print('\nTesting validation...');
    final isValid = await authService.validateSession(session.apiKey);
    print('Valid: $isValid');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

---

## Checklist

### Backend Setup:
- [ ] `api_keys` table created in Supabase
- [ ] `device_logins` table created in Supabase
- [ ] `locations` table exists with data
- [ ] `profiles` table has `location_id` column
- [ ] Test user account created in Supabase Auth
- [ ] APIs deployed to Vercel

### Flutter Setup:
- [ ] Dependencies installed (`flutter pub get`)
- [ ] No linter errors
- [ ] Database migrations run successfully
- [ ] Models can serialize/deserialize

### Integration Testing:
- [ ] Login API returns valid response
- [ ] Validate API confirms session
- [ ] Auth service can login successfully
- [ ] Session persists in SharedPreferences
- [ ] Offline queue service can queue actions
- [ ] Database queries work correctly

---

## Common Issues

### Issue 1: "User profile not found"
**Solution**: Ensure the user has a profile in the `profiles` table with matching `id` to `auth.users.id`

### Issue 2: "Failed to create API key"
**Solution**: Check that the `api_keys` table exists and has proper permissions

### Issue 3: Database not migrating
**Solution**: Delete the database file and restart:
```bash
# Find database location (shown in logs)
# Delete: C:\Users\<user>\AppData\Local\<app>\databases\mitugym_offline.db
```

### Issue 4: Network errors
**Solution**: Ensure API URL is correct and Vercel deployment succeeded

---

## Next Steps After Testing

Once basic testing passes:
1. Implement Login Screen UI
2. Update Splash Screen with session check
3. Integrate offline queue into scan flow
4. Add sync triggers on connectivity change
5. Update Settings with Account tab

---

## Quick Test Commands

```bash
# Backend: Deploy to Vercel
cd c:\Personal\mitugym-app-webpanel && git push

# Flutter: Clean and run
cd c:\Personal\mitugym_scanner_flutter
flutter clean
flutter pub get
flutter run -d windows

# Check database
# SQLite Browser: Open mitugym_offline.db
# Look for: pending_actions table, sync_status column
```

