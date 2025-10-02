# MituGym Scanner Flutter - Implementation Guide

## ✅ Completed Steps

1. ✅ Flutter SDK verified (v3.35.5)
2. ✅ Windows desktop support enabled
3. ✅ Project created: `mitugym_scanner_flutter`
4. ✅ All dependencies installed
5. ✅ Project structure ready

## 📦 Installed Packages

- **QR Scanning:** mobile_scanner ^5.2.3
- **State Management:** flutter_riverpod ^2.6.1
- **HTTP:** dio ^5.7.0
- **Storage:** shared_preferences ^2.3.3
- **Animation:** flutter_animate ^4.5.0
- **Window:** window_manager ^0.4.3
- **Audio:** audioplayers ^6.5.1
- **Logging:** logger ^2.6.1

## 🚧 Next Steps - Implementation Roadmap

### Phase 1: Create Folder Structure (15 min)

Create these directories in `lib/`:

```bash
lib/
├── config/
├── models/
├── services/
├── providers/
├── screens/
└── widgets/
```

Create `assets/` directories:

```bash
assets/
├── sounds/
└── images/
```

### Phase 2: Configuration & Models (1-2 hours)

**Files to create:**

1. `lib/config/app_config.dart`
   - Load/save from SharedPreferences
   - Store API URL, API key, camera index, debounce duration
   - Default values: https://mitugym-app-webpanel.vercel.app/

2. `lib/config/theme.dart`
   - Material Design 3 dark theme
   - Colors: primary #1e9b71 (green), background #1a1a1a, surface #2d2d2d
   
3. `lib/models/member_data.dart`
   - memberId, memberName, planName, expiresAt, membershipStatus
   - fromJson factory

4. `lib/models/scan_result.dart`
   - success, message, data (MemberData?), error
   - fromJson factory

5. `lib/models/activity_log.dart`
   - memberName, action, time, success
   - For recent activity list

### Phase 3: Services Layer (2-3 hours)

**Files to create:**

1. `lib/services/api_service.dart`
   ```dart
   class ApiService {
     final Dio _dio;
     
     Future<ScanResult> checkInOut(String qrCode) async {
       // POST to https://mitugym-app-webpanel.vercel.app/api/checkin
       // Headers: Content-Type: application/json
       // Body: { qr_code, api_key, action: "auto" }
       // Timeout: 15 seconds
       // Handle errors: 401, 403, 404, 429, 500
     }
   }
   ```

2. `lib/services/qr_scanner_service.dart`
   - Use MobileScannerController
   - Debouncing logic (5 seconds)
   - Stream of QR codes

3. `lib/services/audio_service.dart`
   - playSuccess(), playError()
   - Use AudioPlayer from audioplayers package

4. `lib/services/logger_service.dart`
   - Log to file in app documents directory
   - Daily log files with timestamps
   - logSuccess(memberName, action), logError(error, details)

### Phase 4: State Management (1-2 hours)

**Files to create:**

1. `lib/providers/config_provider.dart`
   - StateNotifierProvider for AppConfig
   - Save/load config

2. `lib/providers/scan_provider.dart`
   ```dart
   class ScanState {
     bool isScanning;
     bool cooldownActive;
     int cooldownRemaining;
     ScanResult? lastResult;
     List<ActivityLog> recentActivity;
   }
   ```

3. `lib/providers/scanner_provider.dart`
   - Control QR scanner lifecycle
   - Handle QR code events

### Phase 5: UI - Screens (4-5 hours)

**Files to create:**

1. `lib/screens/home_screen.dart`
   ```dart
   Scaffold(
     appBar: AppBar with title and status indicator
     body: Column [
       Camera Preview (Expanded flex: 6)
       Member Info Card
       Activity List (Expanded flex: 3)
       Control Buttons (Start/Stop/Settings)
     ]
   )
   ```

2. `lib/screens/settings_screen.dart`
   - TextFormField for API URL
   - TextFormField for API Key (obscured)
   - Slider for debounce duration (3-10 seconds)
   - SwitchListTile for audio enable/disable
   - Save button

### Phase 6: UI - Widgets (3-4 hours)

**Files to create:**

1. `lib/widgets/camera_preview_widget.dart`
   - MobileScanner widget
   - Overlay with detection box
   - Status text

2. `lib/widgets/member_info_card.dart`
   - AnimatedContainer with gradient background
   - Green gradient for success, red for error
   - Icon, member name, plan, expiry
   - Use flutter_animate for entrance animation

3. `lib/widgets/activity_list_widget.dart`
   - ListView.builder
   - ListTile with icon (check/error), name, action, time
   - Staggered fade-in animations

4. `lib/widgets/countdown_timer.dart`
   - LinearProgressIndicator
   - Shows cooldown progress (5 → 0)

5. `lib/widgets/control_buttons.dart`
   - Start Scanning button
   - Stop button
   - Settings button
   - Clear Activity button

### Phase 7: Main App & Window Setup (30 min)

**Update `lib/main.dart`:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await windowManager.ensureInitialized();
  
  windowManager.waitUntilReadyToShow(
    WindowOptions(
      size: Size(800, 900),
      minimumSize: Size(600, 700),
      center: true,
      title: 'MituGym Scanner',
      titleBarStyle: TitleBarStyle.hidden,
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );
  
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'MituGym Scanner',
        theme: appTheme,
        home: HomeScreen(),
      ),
    ),
  );
}
```

### Phase 8: Polish & Testing (2-3 hours)

1. Add animations to all widgets
2. Test QR scanning with mobile app
3. Test API integration
4. Test error handling
5. Test cooldown functionality
6. Add sound files to assets/sounds/
7. Test audio feedback

### Phase 9: Build & Package (1 hour)

```powershell
# Build Windows release
flutter build windows --release

# Output will be in:
# build\windows\x64\runner\Release\
```

## 🎨 Design System

### Colors
- Primary: `#1e9b71` (Green)
- Background: `#1a1a1a` (Dark)
- Surface: `#2d2d2d` (Dark gray)
- Error: `#e74c3c` (Red)

### Typography
- Title: 24px, bold
- Subtitle: 18px, medium
- Body: 14px, regular
- Caption: 12px, light

### Spacing
- Small: 8px
- Medium: 16px
- Large: 24px
- XLarge: 32px

## 📝 Implementation Checklist

- [ ] Create folder structure
- [ ] Implement AppConfig
- [ ] Implement data models
- [ ] Implement ApiService
- [ ] Implement QRScannerService
- [ ] Implement AudioService
- [ ] Implement LoggerService
- [ ] Create state providers
- [ ] Build HomeScreen
- [ ] Build SettingsScreen
- [ ] Build CameraPreviewWidget
- [ ] Build MemberInfoCard
- [ ] Build ActivityListWidget
- [ ] Build CountdownTimer
- [ ] Setup main.dart with window manager
- [ ] Add animations
- [ ] Test with real API
- [ ] Add sound assets
- [ ] Build Windows release
- [ ] Test Windows executable

## 🔧 Development Commands

```powershell
# Run in debug mode
cd C:\Personal\mitugym_scanner_flutter
C:\Users\adrian.cristache\develop\flutter\bin\flutter.bat run -d windows

# Hot reload: Press 'r' in terminal
# Hot restart: Press 'R' in terminal

# Build release
C:\Users\adrian.cristache\develop\flutter\bin\flutter.bat build windows --release

# Generate code (for Riverpod)
C:\Users\adrian.cristache\develop\flutter\bin\flutter.bat packages pub run build_runner build
```

## 📚 Key Resources

- **mobile_scanner docs:** https://pub.dev/packages/mobile_scanner
- **flutter_riverpod docs:** https://riverpod.dev/
- **dio docs:** https://pub.dev/packages/dio
- **Material 3 design:** https://m3.material.io/

## 🎯 Performance Targets

- QR detection: < 100ms
- UI refresh: 60 FPS
- App size: < 50MB
- Memory usage: < 150MB
- Startup time: < 3 seconds

## 🔐 API Integration Details

**Endpoint:** `POST https://mitugym-app-webpanel.vercel.app/api/checkin`

**Request:**
```json
{
  "qr_code": "member_id:totp_code",
  "api_key": "847a6e2605d0674043fd8c6fef6e4f2ffb34fcfe8d5cd772636da8fc4b42bb78",
  "action": "auto"
}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Check-in successful",
  "data": {
    "member_id": "uuid",
    "member_name": "Andrei Cristache",
    "plan_name": "Premium",
    "expires_at": "2025-12-31T23:59:59Z",
    "membership_status": "active"
  }
}
```

## ⏱️ Estimated Timeline

- **Phase 1-2:** 2-3 hours (Config & Models)
- **Phase 3-4:** 3-4 hours (Services & State)
- **Phase 5-6:** 7-9 hours (UI)
- **Phase 7-9:** 3-4 hours (Polish & Build)

**Total:** ~15-20 hours

## 💡 Quick Start for Next Session

1. Open VS Code in `C:\Personal\mitugym_scanner_flutter`
2. Create folder structure in `lib/`
3. Start with `lib/config/app_config.dart`
4. Then create models
5. Then services
6. Then build UI

The foundation is ready! Dependencies installed, project created. Ready to code! 🚀

