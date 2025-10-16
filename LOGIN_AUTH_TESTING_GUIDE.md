# Login Authentication System - Testing Guide

## ✅ Current Status

### **Completed Components:**

1. **Backend APIs** ✅
   - `/api/auth/login` - Email/password login with API key generation
   - `/api/auth/validate` - Session validation
   - TypeScript errors fixed

2. **Flutter Models** ✅
   - `auth_session.dart` - Session management
   - `pending_action.dart` - Offline queue model
   - **All unit tests passed (8/8)** ✓

3. **Services** ✅
   - `auth_service.dart` - Authentication logic
   - `offline_queue_service.dart` - Queue management

4. **State Management** ✅
   - `auth_provider.dart` - Auth state
   - `offline_queue_provider.dart` - Queue state

5. **Database** ✅
   - `pending_actions` table migration
   - `sync_status` column migration
   - Database version 6

---

## 📋 Testing Checklist

### Step 1: Setup Supabase Tables

Run this SQL in Supabase SQL Editor:

```bash
# File location
supabase_auth_tables_migration.sql
```

This creates:
- ✅ `api_keys` table
- ✅ `device_logins` table
- ✅ RLS policies
- ✅ Indexes

### Step 2: Deploy Backend to Vercel

```bash
cd c:\Personal\mitugym-app-webpanel
git add .
git commit -m "Add login and session validation APIs"
git push
```

Wait for Vercel deployment: https://vercel.com/dashboard

### Step 3: Test Backend APIs

Run PowerShell test script:

```powershell
cd c:\Personal\mitugym_scanner_flutter
.\test_auth_implementation.ps1
```

This tests:
- ✅ Login API with valid credentials
- ✅ Session validation with valid key
- ✅ Session rejection with invalid key
- ✅ Optional: Checkin API with authenticated key

### Step 4: Test Flutter Models (Already Done!)

```bash
flutter test test/auth_models_test.dart
```

**Results**: ✅ All 8 tests passed!
- AuthSession serialization/deserialization
- Session revalidation logic
- PendingAction creation with UUID
- Retry logic (max 5 attempts)
- Mark as synced functionality

### Step 5: Test Database Migrations

Run the app once to trigger migrations:

```bash
flutter run -d windows
```

Check console logs for:
```
[INFO] Initializing offline database at: ...
[INFO] Created pending_actions table
[INFO] Added sync_status column to checkin_history table
```

---

## 🧪 Manual Testing Steps

### Test 1: Backend Login API

**Using PowerShell:**
```powershell
$body = @{
    email = "your-email@example.com"
    password = "your-password"
    device_name = "Test Scanner"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://mitugym-app-webpanel.vercel.app/api/auth/login" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body
```

**Expected Output:**
```json
{
  "success": true,
  "api_key": "abc123...",
  "user_name": "John Doe",
  "location_name": "Main Gym",
  "email": "your-email@example.com"
}
```

### Test 2: Session Validation

```powershell
$body = @{
    api_key = "your-api-key-from-step-1"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://mitugym-app-webpanel.vercel.app/api/auth/validate" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body
```

**Expected Output:**
```json
{
  "valid": true,
  "user_name": "John Doe",
  "location_name": "Main Gym"
}
```

---

## 📦 Implementation Progress

### ✅ Completed (50%):

**Backend:**
- [x] Login API endpoint
- [x] Validate API endpoint
- [x] TypeScript errors fixed
- [x] SQL migration script

**Flutter - Data Layer:**
- [x] AuthSession model (with tests)
- [x] PendingAction model (with tests)
- [x] AuthService
- [x] OfflineQueueService
- [x] AuthProvider
- [x] OfflineQueueProvider
- [x] Database migrations (v6)
- [x] Dependencies installed (uuid)

### ⏳ Remaining (50%):

**Flutter - UI Layer:**
- [ ] Login Screen (new)
- [ ] Update Splash Screen (session check)
- [ ] Update Main Layout (offline banner)
- [ ] Update Settings Screen (Account tab)

**Flutter - Integration:**
- [ ] Update Scan Provider (offline queuing)
- [ ] Update main.dart (add AuthProvider)
- [ ] Update Connectivity Service (auto-sync)
- [ ] Update App Config (user fields)

---

## 🎯 Next Steps

### Immediate (Before UI):

1. **Run Supabase migration:**
   ```
   Open Supabase → SQL Editor → Paste supabase_auth_tables_migration.sql → Run
   ```

2. **Deploy backend:**
   ```bash
   cd c:\Personal\mitugym-app-webpanel
   git push
   ```

3. **Test APIs:**
   ```powershell
   .\test_auth_implementation.ps1
   ```

4. **Verify Flutter migrations:**
   ```bash
   flutter run -d windows
   # Check logs for database migration messages
   ```

### After Backend Testing:

5. **Implement Login Screen UI**
   - Modern gradient design
   - Email/password inputs
   - Loading states
   - Error handling
   - Offline detection

6. **Update Splash Screen**
   - Check for saved session
   - Validate with server if online
   - Route to Login or Main App

7. **Integrate Offline Queue**
   - Update scan provider
   - Add offline banner
   - Implement auto-sync

8. **Update Settings**
   - Add Account tab
   - Show user info
   - Add logout button
   - Remove manual API key entry

---

## 🐛 Troubleshooting

### Backend Issues:

**"User profile not found"**
- Check that user exists in `profiles` table
- Verify `location_id` is set

**"Failed to create API key"**
- Verify `api_keys` table exists
- Check RLS policies allow inserts

**"Invalid email or password"**
- Verify credentials in Supabase Auth
- Check if user is confirmed

### Flutter Issues:

**Tests fail**
- Run `flutter pub get`
- Check for import errors
- Verify model classes exist

**Database migration fails**
- Delete database file: `mitugym_offline.db`
- Restart app
- Check logs for errors

**"Undefined class 'ApiService'"**
- Already fixed with imports
- Run `flutter pub get` if needed

---

## 📊 Test Results Summary

| Component | Status | Tests |
|-----------|--------|-------|
| Backend Login API | ⏳ Pending Deploy | Manual |
| Backend Validate API | ⏳ Pending Deploy | Manual |
| AuthSession Model | ✅ Passed | 4/4 |
| PendingAction Model | ✅ Passed | 4/4 |
| Database Migrations | ⏳ Pending Run | Manual |
| Auth Service | ✅ Ready | N/A |
| Queue Service | ✅ Ready | N/A |
| Auth Provider | ✅ Ready | N/A |
| Queue Provider | ✅ Ready | N/A |

---

## 📝 Notes

- All TypeScript and Dart linting errors are fixed
- Unit tests validate core functionality
- Database schema is version 6 (up from 5)
- UUID package successfully installed
- RLS policies ensure user data isolation
- API keys are unique and indexed
- Retry logic limits to 5 attempts
- Sessions validate every 24 hours

---

Ready to proceed with backend deployment and testing!

