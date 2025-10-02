<!-- cb8d9e4d-a914-4e4b-a599-ad3174142d73 f71f3e82-61f2-4fd1-8ca4-cef94afa277f -->
# MituGym Scanner - Phase-by-Phase Implementation

## Overview

Build a complete QR scanner desktop application for gym member check-in/check-out with Material Design 3 dark theme, real-time scanning, API integration, and activity logging.

## Phase 1: Create Folder Structure

Create the following directory structure:

```
lib/
├── config/
├── models/
├── services/
├── providers/
├── screens/
└── widgets/

assets/
├── sounds/
└── images/
```

## Phase 2: Configuration & Models (4 files)

### 1. `lib/config/app_config.dart`

- Class to store: API URL, API key, camera index, debounce duration, audio enabled
- Methods: `loadFromPreferences()`, `saveToPreferences()`
- Default API URL: `https://mitugym-app-webpanel.vercel.app/`
- Default API key: `847a6e2605d0674043fd8c6fef6e4f2ffb34fcfe8d5cd772636da8fc4b42bb78`
- Default debounce: 5 seconds

### 2. `lib/config/theme.dart`

- Material Design 3 dark theme with:
  - Primary color: `#1e9b71` (green)
  - Background: `#1a1a1a`
  - Surface: `#2d2d2d`
  - Error: `#e74c3c`
- Export `ThemeData appTheme`

### 3. `lib/models/member_data.dart`

```dart
class MemberData {
  final String memberId;
  final String memberName;
  final String planName;
  final String expiresAt;
  final String membershipStatus;
  
  factory MemberData.fromJson(Map<String, dynamic> json)
}
```

### 4. `lib/models/scan_result.dart`

```dart
class ScanResult {
  final bool success;
  final String message;
  final MemberData? data;
  final String? error;
  
  factory ScanResult.fromJson(Map<String, dynamic> json)
}
```

### 5. `lib/models/activity_log.dart`

```dart
class ActivityLog {
  final String memberName;
  final String action;
  final DateTime time;
  final bool success;
}
```

## Phase 3: Services Layer (4 files)

### 1. `lib/services/api_service.dart`

- `Future<ScanResult> checkInOut(String qrCode, String apiKey)`
- POST to `/api/checkin` with body: `{qr_code, api_key, action: "auto"}`
- 15 second timeout
- Error handling for 401, 403, 404, 429, 500

### 2. `lib/services/qr_scanner_service.dart`

- Use `MobileScannerController`
- Implement debouncing logic (configurable seconds)
- Stream of detected QR codes
- Methods: `startScanning()`, `stopScanning()`, `dispose()`

### 3. `lib/services/audio_service.dart`

- `playSuccess()` and `playError()` methods
- Use `AudioPlayer` from audioplayers package
- Check if audio is enabled in config

### 4. `lib/services/logger_service.dart`

- Log to files in app documents directory
- Daily log files with format: `mitugym_YYYY-MM-DD.log`
- Methods: `logSuccess(memberName, action)`, `logError(error, details)`

## Phase 4: State Management (3 providers)

### 1. `lib/providers/config_provider.dart`

- `StateNotifierProvider<ConfigNotifier, AppConfig>`
- Load config on init
- Methods to update and persist config

### 2. `lib/providers/scan_provider.dart`

```dart
class ScanState {
  final bool isScanning;
  final bool cooldownActive;
  final int cooldownRemaining;
  final ScanResult? lastResult;
  final List<ActivityLog> recentActivity;
}
```

- Handle QR code scanning workflow
- Manage cooldown timer
- Call API service
- Add to activity log

### 3. `lib/providers/scanner_provider.dart`

- Manage `QRScannerService` lifecycle
- Listen to QR code stream
- Trigger scan state updates

## Phase 5: UI Screens (2 files)

### 1. `lib/screens/home_screen.dart`

- AppBar with title "MituGym Scanner" and status indicator
- Camera preview (Expanded flex: 6)
- Member info card (shows last scan result)
- Activity list (Expanded flex: 3, recent 10 scans)
- Control buttons row: Start/Stop/Settings/Clear Activity

### 2. `lib/screens/settings_screen.dart`

- TextFormField for API URL
- TextFormField for API Key (obscured with `obscureText: true`)
- Slider for debounce duration (3-10 seconds)
- SwitchListTile for audio enable/disable
- Save button (validates and saves to SharedPreferences)

## Phase 6: UI Widgets (5 files)

### 1. `lib/widgets/camera_preview_widget.dart`

- `MobileScanner` widget
- Overlay with detection box in center
- Status text ("Scanning...", "Cooldown active", etc.)

### 2. `lib/widgets/member_info_card.dart`

- `AnimatedContainer` with gradient background
- Green gradient (#1e9b71 → darker) for success
- Red gradient (#e74c3c → darker) for error
- Display: icon, member name, plan name, expiry date
- Use `flutter_animate` for slide-in animation

### 3. `lib/widgets/activity_list_widget.dart`

- `ListView.builder` with recent activity (max 10)
- Each `ListTile`: icon (✓ or ✗), member name, action, timestamp
- Staggered fade-in animations using `flutter_animate`

### 4. `lib/widgets/countdown_timer.dart`

- `LinearProgressIndicator` showing cooldown progress
- Text showing seconds remaining (5 → 0)
- Updates every second

### 5. `lib/widgets/control_buttons.dart`

- Start Scanning button (primary green)
- Stop button (secondary)
- Settings button (icon button)
- Clear Activity button (text button)

## Phase 7: Main App Setup

Update `lib/main.dart`:

- Initialize `windowManager` with size 800x900, minimum 600x700
- Set title "MituGym Scanner"
- Initialize `ProviderScope` for Riverpod
- Apply custom theme from `lib/config/theme.dart`
- Set `HomeScreen` as home

## Phase 8: Assets & Polish

- Add placeholder sound files to `assets/sounds/` (success.mp3, error.mp3)
- Test all animations
- Ensure all widgets follow design system (colors, spacing, typography)
- Add loading states and error boundaries

---

**Implementation Approach:**

- Complete each phase fully before moving to the next
- Test each component as it's built
- Follow Material Design 3 guidelines
- Use Riverpod for all state management
- Keep code modular and maintainable

### To-dos

- [ ] Create folder structure (lib/ and assets/ directories)
- [ ] Implement configuration and data models (5 files)
- [ ] Implement services layer (API, QR Scanner, Audio, Logger)
- [ ] Create Riverpod state providers for config and scanning
- [ ] Build HomeScreen and SettingsScreen
- [ ] Create all UI widgets (camera, info card, activity list, countdown, buttons)
- [ ] Update main.dart with window manager and app initialization
- [ ] Add assets, test animations, and final polish