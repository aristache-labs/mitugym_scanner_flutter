# 🎨 MituGym Scanner - Premium Features Documentation

## Overview
MituGym Scanner is now a feature-rich, premium desktop application with modern UI, advanced settings, and enterprise-ready capabilities.

---

## ✨ Key Features

### 🖥️ **Premium UI Design**
- **Sidebar Layout**: Professional 320px sidebar with main content area (1400x900 default window)
- **4 Theme Presets**: Cyan (default), Green, Purple, Blue - switch instantly
- **Collapsible Camera**: Toggle camera preview with smooth animations
- **Google Fonts**: Inter typography for modern, clean look
- **Gradient Accents**: Beautiful gradients throughout the app
- **Responsive Design**: Minimum 1200px width for optimal experience

### 👤 **Member Avatars**
- **Network Images**: Cached avatar loading from API (`avatar_url` field)
- **Shimmer Loading**: Premium loading effect while fetching images
- **Fallback Avatars**: Gradient circles with member initials (e.g., "AJ" for Alex Johnson)
- **Everywhere**: Avatars in member cards, sidebar activity, and activity list

### ⚙️ **Advanced Settings (5 Tabs)**

#### 1️⃣ **General Tab**
- API URL configuration
- API Key (secure, obscured input)
- Camera device index (0-5)

#### 2️⃣ **UI Customization Tab**
- **Theme Selector**: Visual color swatches for 4 themes
- **Font Size**: 12-20px slider (default: 14px)
- **Animation Speed**: 0.5x-2.0x slider (default: 1.0x)

#### 3️⃣ **Audio Tab**
- Enable/Disable audio feedback
- Sound volume slider (0-100%)

#### 4️⃣ **Performance Tab**
- **Camera Frame Rate**: 5-30 FPS (default: 10 FPS)
- **Scan Cooldown**: 2-15 seconds (default: 5s)
- **Log Retention**: 7-90 days (default: 30 days)

#### 5️⃣ **Advanced Tab**
- Auto-start scanning on launch
- Show camera preview by default
- Minimize to system tray
- Default export format (CSV/Text)

### 🗄️ **Offline Database (SQLite)**
- Local member data storage
- Check-in history persistence
- Sync queue for failed API calls
- Automatic sync when connection restored

### 🔍 **Search & Filter**
- Search members by name or ID
- Fuzzy search algorithm
- Filter by membership status (Active/Expired/Inactive)
- Filter by plan type
- Sort by name or date

### 📊 **Statistics & Reporting**
- Today's check-ins counter
- Success rate tracking
- Error count monitoring
- Recent activity feed (8 items in sidebar)
- Export to CSV or Text format

### 🌐 **Connectivity**
- Online/offline detection
- Pending sync count badge
- Manual sync trigger
- Offline-first architecture

### 🔗 **Admin Panel Integration**
- Direct link to MituGym web panel
- Opens in default browser: `https://mitugym-app-webpanel.vercel.app/`
- One-click access from sidebar

---

## 🎯 Usage Guide

### First Launch
1. App opens with splash screen (3 seconds)
2. Camera initializes automatically
3. If **Auto-start scanning** is enabled, scanning begins immediately

### Scanning a Member
1. Click **START** button (or enable auto-start in settings)
2. Present QR code to camera
3. **Success**: Green border, member avatar, check-in/out message, success sound
4. **Error**: Red border, error details, error sound
5. 5-second cooldown (configurable) before next scan

### Viewing Recent Activity
- **Sidebar**: Last 8 activities with avatars and status icons
- **Main View** (if no sidebar): Scrollable list with all recent activities

### Changing Theme
1. Click **Settings** (gear icon in header or sidebar)
2. Navigate to **UI** tab
3. Tap desired theme swatch (Cyan/Green/Purple/Blue)
4. Click **Save Settings**
5. Restart app for full effect

### Exporting Data
1. Click **Export** button in sidebar
2. Choose format: **CSV** or **Text**
3. File saves to `Documents/MituGymScanner/exports/`
4. Toast notification shows file path

### Hiding Camera
1. Click the **eye icon** above camera preview
2. Camera collapses smoothly
3. Small status indicator remains
4. Preference saved automatically

---

## 🔧 Configuration Files

### AppConfig Settings
All settings stored in `SharedPreferences`:

```dart
- apiUrl: String
- apiKey: String
- cameraIndex: int (0-5)
- debounceDuration: int (2-15 seconds)
- audioEnabled: bool
- fontSize: double (12-20px)
- animationSpeed: double (0.5-2.0x)
- soundVolume: double (0.0-1.0)
- logRetentionDays: int (7-90)
- exportFormat: String ('csv'|'text')
- autoStartScanning: bool
- minimizeToTray: bool
- cameraVisible: bool
- theme: String ('cyan'|'green'|'purple'|'blue')
- cameraFrameRate: int (5-30 FPS)
```

### Theme Colors

#### Cyan (Default)
```dart
Primary: #4dd4d4
Secondary: #5cdfdf
Success: #00e6a6
Error: #ff6b6b
```

#### Green
```dart
Primary: #1e9b71
Secondary: #26b584
Success: #00e6a6
Error: #ff6b6b
```

#### Purple
```dart
Primary: #a855f7
Secondary: #c084fc
Success: #00e6a6
Error: #ff6b6b
```

#### Blue
```dart
Primary: #3b82f6
Secondary: #60a5fa
Success: #00e6a6
Error: #ff6b6b
```

---

## 📁 File Structure

```
lib/
├── config/
│   ├── app_config.dart          # Application settings
│   ├── app_colors.dart          # Original color constants
│   ├── app_themes.dart          # 4 theme presets (NEW)
│   └── theme.dart               # Material theme with Google Fonts
│
├── models/
│   ├── activity_log.dart        # Activity log with avatarUrl (ENHANCED)
│   ├── member_data.dart         # Member with avatar support (ENHANCED)
│   └── scan_result.dart         # Scan result model
│
├── providers/
│   ├── config_provider.dart     # App config state (EXPANDED)
│   ├── offline_provider.dart    # Offline mode state (NEW)
│   ├── scan_provider.dart       # Scan state with avatar support (ENHANCED)
│   └── windows_scanner_provider.dart
│
├── screens/
│   ├── home_screen.dart         # Premium sidebar layout (REDESIGNED)
│   ├── settings_screen.dart     # 5-tab advanced settings (REDESIGNED)
│   ├── splash_screen.dart       # Animated splash
│   └── stats_screen.dart        # Statistics dashboard
│
├── services/
│   ├── api_service.dart         # API with offline support (ENHANCED)
│   ├── audio_service.dart       # Sound effects
│   ├── connectivity_service.dart # Online/offline detection (NEW)
│   ├── export_service.dart      # CSV/Text export
│   ├── logger_service.dart      # File logging
│   ├── offline_storage_service.dart # SQLite database (NEW)
│   ├── search_service.dart      # Member search (NEW)
│   └── windows_qr_scanner_service.dart
│
└── widgets/
    ├── activity_list_widget.dart    # Activity list with avatars (ENHANCED)
    ├── collapsible_camera_widget.dart # Toggleable camera (NEW)
    ├── control_buttons.dart         # Start/Stop/Settings buttons
    ├── countdown_timer.dart         # Cooldown progress
    ├── member_info_card.dart        # Member card with avatar (ENHANCED)
    ├── sidebar_widget.dart          # Premium sidebar (NEW)
    └── windows_camera_preview_widget.dart
```

---

## 🚀 Performance Optimizations

### Current
- ✅ `const` constructors wherever possible
- ✅ `ListView.builder` for efficient lists
- ✅ Cached network images (max 50 in memory)
- ✅ Proper disposal of controllers/streams
- ✅ Debounced QR scanning

### Planned (Future)
- Isolates for QR processing
- Image compression for avatars
- Lazy loading for large member lists
- Background sync scheduling

---

## 📊 Database Schema

### Members Table
```sql
CREATE TABLE members (
  member_id TEXT PRIMARY KEY,
  member_name TEXT NOT NULL,
  plan_name TEXT NOT NULL,
  expires_at TEXT NOT NULL,
  membership_status TEXT NOT NULL,
  avatar_url TEXT,
  last_updated INTEGER NOT NULL
)
```

### Check-in History Table
```sql
CREATE TABLE checkin_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  member_id TEXT NOT NULL,
  member_name TEXT NOT NULL,
  action TEXT NOT NULL,
  timestamp INTEGER NOT NULL,
  success INTEGER NOT NULL,
  synced INTEGER DEFAULT 0
)
```

### Sync Queue Table
```sql
CREATE TABLE sync_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  qr_code TEXT NOT NULL,
  action TEXT NOT NULL,
  timestamp INTEGER NOT NULL,
  retry_count INTEGER DEFAULT 0
)
```

---

## 🎨 UI Components

### Sidebar Sections
1. **Header**: Logo, online/offline status, sync badge
2. **Quick Stats**: Today's check-ins, errors, total scans
3. **Recent Activity**: Scrollable list with avatars
4. **Quick Actions**: Admin Panel, Export, Statistics, Settings

### Main Content
1. **Collapsible Camera**: Full preview or minimized status
2. **Member Card**: Avatar, name, plan, expiry, status badge
3. **Countdown Timer**: Circular progress during cooldown
4. **Control Buttons**: Start/Stop, Settings, Clear Activity

---

## 🔐 Security Notes

- API Key is obscured in settings input
- No sensitive data logged to files
- Local database encrypted at OS level
- HTTPS-only API communication

---

## 📱 Keyboard Shortcuts (Future)

- `Ctrl+S`: Open Settings
- `Ctrl+E`: Export Activity
- `Ctrl+H`: Toggle Camera
- `Space`: Start/Stop Scanning
- `Ctrl+R`: Refresh

---

## 🆘 Troubleshooting

### Camera Not Working
1. Check camera index in Settings > General
2. Try indices 0-5 to find your camera
3. Restart app after changing camera

### Offline Mode Stuck
1. Check internet connection
2. Click sync button in sidebar header
3. Check pending sync count badge

### Settings Not Saving
1. Ensure app has write permissions
2. Check `SharedPreferences` storage
3. Try "Reset to Defaults" button

### Theme Not Changing
1. Restart app after changing theme
2. Some UI elements need full restart
3. Check if theme is saved in settings

---

## 📈 Roadmap

### Future Enhancements
- [ ] Member search screen with filters
- [ ] Member details view with history
- [ ] History screen with pagination
- [ ] Enhanced charts (daily trends, peak hours)
- [ ] PDF export support
- [ ] Multi-language support
- [ ] Desktop notifications
- [ ] Keyboard shortcuts
- [ ] System tray integration
- [ ] Auto-update mechanism

---

## 📞 Support

For issues or feature requests:
- Email: ops@mitugym.dev
- Web Panel: https://mitugym-app-webpanel.vercel.app/

---

**Version**: 1.0.0  
**Last Updated**: October 2, 2025  
**Built with**: Flutter 3.9.2, Riverpod 3.0, SQLite, Material Design 3

