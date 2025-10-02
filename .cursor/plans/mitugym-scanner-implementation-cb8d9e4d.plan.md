<!-- cb8d9e4d-a914-4e4b-a599-ad3174142d73 e912d530-a3f9-4e24-a763-e70085fd4640 -->
# Premium MituGym Scanner Enhancement Plan

## 📋 Overview

Transform the MituGym Scanner into a premium, feature-rich desktop application with modern UI, advanced settings, performance optimizations, and offline capabilities.

---

## 🎯 Phase 1: Data Models & Core Infrastructure

### 1.1 Update Member Data Model

**File**: `lib/models/member_data.dart`

- Add `avatarUrl` field to store member profile image URL
- Update `fromJson` to parse `avatar_url` from API response
- Add `hasAvatar` getter to check if avatar exists

### 1.2 Expand App Configuration

**File**: `lib/config/app_config.dart`

- Add new settings:
  - `double fontSize` (default: 14.0, range: 12-20)
  - `double animationSpeed` (default: 1.0, range: 0.5-2.0)
  - `double soundVolume` (default: 1.0, range: 0.0-1.0)
  - `int logRetentionDays` (default: 30)
  - `String exportFormat` (default: 'csv', options: 'csv', 'txt')
  - `bool autoStartScanning` (default: false)
  - `bool minimizeToTray` (default: false)
  - `bool cameraVisible` (default: true)
  - `String theme` (default: 'cyan', options: 'cyan', 'green', 'purple', 'blue')
- Update `loadFromPreferences()` and `saveToPreferences()` methods
- Update `copyWith()` method with all new fields

### 1.3 Create Offline Storage Service

**New File**: `lib/services/offline_storage_service.dart`

- Use `sqflite` for local database
- Store member data, check-in history locally
- Queue failed API calls for retry when online
- Methods: `saveMemberLocally()`, `getOfflineMembers()`, `queueCheckIn()`, `syncWhenOnline()`

### 1.4 Create Search Service

**New File**: `lib/services/search_service.dart`

- Search members by name, ID, plan
- Fuzzy search implementation
- Methods: `searchMembers(query)`, `filterByStatus(status)`, `sortByDate()`

---

## 🎨 Phase 2: Premium UI Redesign

### 2.1 Create New Responsive Layout

**File**: `lib/screens/home_screen.dart`

- **New Layout Structure**:
  ```
  ┌─────────────────────────────────────────────┐
  │  AppBar (Gradient, Logo, Status, Actions)   │
  ├──────────────┬──────────────────────────────┤
  │              │                              │
  │   Sidebar    │    Main Content Area         │
  │   (Left)     │    - Camera (Collapsible)    │
  │              │    - Member Card (Enhanced)  │
  │   - Stats    │    - Countdown               │
  │   - Activity │                              │
  │   - Search   │                              │
  │   - Quick    │                              │
  │     Actions  │                              │
  │              │                              │
  └──────────────┴──────────────────────────────┘
  ```

- Minimum window width: 1200px (update in `main.dart`)
- Use `Row` with `Expanded` for responsive sidebar + main area
- Add floating toggle button to show/hide camera preview

### 2.2 Create Premium Sidebar Widget

**New File**: `lib/widgets/sidebar_widget.dart`

- **Sections**:

  1. **Quick Stats Card** (Today's check-ins, Active now, Total today)
  2. **Recent Activity** (Scrollable list with avatars)
  3. **Quick Search** (Search bar with instant results)
  4. **Quick Actions** (Admin Panel button, Export, Settings)

- Premium card design with gradients, shadows, hover effects
- Collapsible sections with smooth animations

### 2.3 Enhance Member Info Card with Avatar

**File**: `lib/widgets/member_info_card.dart`

- Add `CircleAvatar` widget with:
  - Network image from `avatarUrl`
  - Fallback to gradient icon with member initials
  - Border with success/error color
  - Size: 80x80px
- Add shimmer effect while loading image
- Position avatar at top-left of card
- Add dependencies: `cached_network_image`, `shimmer`

### 2.4 Create Collapsible Camera Widget

**File**: `lib/widgets/collapsible_camera_widget.dart`

- Wrap `WindowsCameraPreviewWidget` with `AnimatedContainer`
- Add toggle button (eye icon) to show/hide camera
- Smooth height animation (300ms)
- Persist state in `SharedPreferences`
- When collapsed: Show small status indicator only

### 2.5 Update Activity List with Avatars

**File**: `lib/widgets/activity_list_widget.dart`

- Add small avatar (32x32) to each activity item
- Show member name, action, time, status icon
- Add hover effect for premium feel
- Limit to 8 items, add "View All" button

### 2.6 Create Theme Customization

**File**: `lib/config/app_themes.dart`

- Define 4 theme presets: Cyan (current), Green, Purple, Blue
- Each theme has: primary, secondary, accent, success, error colors
- Export `getThemeColors(themeName)` function
- Update `theme.dart` to use dynamic colors from config

---

## ⚙️ Phase 3: Advanced Settings Screen

### 3.1 Redesign Settings Screen

**File**: `lib/screens/settings_screen.dart`

- **Tabbed Interface** with 5 tabs:

  1. **General**: API URL, API Key, Camera Index
  2. **UI Customization**: Font size slider, Animation speed, Theme picker
  3. **Audio**: Sound volume slider, Enable/disable audio
  4. **Performance**: Camera frame rate, Log retention days
  5. **Advanced**: Auto-start scanning, Minimize to tray, Export format

- Use `TabBarView` with premium card layouts
- Add visual preview for font size changes
- Theme picker with color swatches
- Sliders with real-time value display
- Save button with confirmation animation

---

## 🚀 Phase 4: Performance Optimizations

### 4.1 Optimize QR Scanner Service

**File**: `lib/services/windows_qr_scanner_service.dart`

- Add frame rate control setting (default: 10 fps, configurable 5-30)
- Skip frames intelligently when not scanning
- Use `Isolate` for image processing (move QR detection off main thread)
- Add `compute()` function for heavy operations
- Cache decoded QR codes for 100ms to prevent duplicates

### 4.2 Optimize Memory Usage

**Files**: All widgets

- Use `const` constructors wherever possible
- Implement `AutomaticKeepAliveClientMixin` for complex widgets
- Add image caching with size limits (max 50 avatars in memory)
- Dispose controllers and streams properly
- Use `ListView.builder` instead of `ListView` for activity list

### 4.3 Improve Startup Performance

**File**: `lib/main.dart`

- Load config asynchronously during splash screen
- Preload audio files
- Initialize camera after UI is displayed
- Use `FutureBuilder` for async initialization

### 4.4 Optimize Logging Service

**File**: `lib/services/logger_service.dart`

- Implement log rotation (delete logs older than `logRetentionDays`)
- Write logs in batches instead of immediately
- Use `isolate` for file I/O operations
- Add compression for old logs

---

## 🔍 Phase 5: Member Search Feature

### 5.1 Create Search Screen

**New File**: `lib/screens/search_screen.dart`

- Search bar at top
- Filters: Status (Active/Expired/All), Plan type
- Results grid with member cards (avatar, name, plan, status)
- Tap to view full member details
- Export search results button

### 5.2 Create Member Details Screen

**New File**: `lib/screens/member_details_screen.dart`

- Show full member info with large avatar
- Check-in history for this member
- QR code display option
- Action button: Manual check-in/out

### 5.3 Add Search to Sidebar

**File**: `lib/widgets/sidebar_widget.dart`

- Compact search bar
- Show first 5 results as dropdown
- "View All" button to open search screen

---

## 📊 Phase 6: Check-in History & Reports

### 6.1 Enhanced Stats Screen

**File**: `lib/screens/stats_screen.dart`

- Add date range picker
- Export filtered data
- Charts: Daily trend, Peak hours, Popular plans
- Total revenue estimation (if plan prices available)

### 6.2 Create History Screen

**New File**: `lib/screens/history_screen.dart`

- Paginated check-in history (100 per page)
- Filters: Date range, Member name, Status
- Export to CSV/PDF
- Use `DataTable` widget for desktop-optimized display

---

## 🌐 Phase 7: Offline Mode Support

### 7.1 Implement Connectivity Detection

**New File**: `lib/services/connectivity_service.dart`

- Use `connectivity_plus` package
- Monitor online/offline status
- Show banner when offline

### 7.2 Update API Service for Offline

**File**: `lib/services/api_service.dart`

- Check connectivity before API calls
- If offline: Save to queue, return cached data
- Auto-sync when connection restored
- Show sync progress indicator

### 7.3 Create Offline Provider

**New File**: `lib/providers/offline_provider.dart`

- Track offline state
- Count pending sync items
- Trigger manual sync
- Show offline badge in UI

---

## 🔗 Phase 8: Admin Dashboard Integration

### 8.1 Add Dashboard Button

**Files**: `lib/widgets/sidebar_widget.dart`, `lib/screens/home_screen.dart`

- Add prominent "Admin Panel" button to sidebar
- Use `url_launcher` package
- Open `https://mitugym-app-webpanel.vercel.app/` in default browser
- Add icon: `Icons.admin_panel_settings`

### 8.2 Add Quick Actions Menu

**New File**: `lib/widgets/quick_actions_widget.dart`

- Floating action menu (bottom-right)
- Actions: Admin Panel, Export Today, Manual Entry, Refresh
- Premium circular design with animation

---

## 📦 Phase 9: Dependencies & Packages

### 9.1 Add to `pubspec.yaml`

```yaml
dependencies:
  # Existing...
  cached_network_image: ^3.4.1  # Avatar caching
  shimmer: ^3.0.0               # Loading effects
  sqflite: ^2.4.1               # Offline database
  connectivity_plus: ^6.1.2     # Network detection
  url_launcher: ^6.3.1          # Open admin panel
  flutter_staggered_animations: ^1.1.1  # Premium animations
  syncfusion_flutter_charts: ^28.1.33   # Better charts
  intl: ^0.19.0                 # Date formatting
  badges: ^3.1.2                # Notification badges
```

---

## 🎨 Phase 10: Premium UI Polish

### 10.1 Add Micro-interactions

- Ripple effects on all buttons
- Hover states for cards
- Loading skeletons
- Success/error toast animations
- Particle effects on successful check-in

### 10.2 Update Color Scheme

**File**: `lib/config/app_colors.dart`

- Add glassmorphism effects
- Card elevation with subtle shadows
- Gradient backgrounds for premium feel
- Add `shimmer` colors for loading states

### 10.3 Typography Enhancement

**File**: `lib/config/theme.dart`

- Use Google Fonts: Inter for UI, Roboto Mono for codes
- Responsive font scaling based on `fontSize` setting
- Better text hierarchy (H1-H6, body, caption)

---

## ✅ Final Testing & Optimization

### 11.1 Performance Testing

- Test with 1000+ member records
- Measure memory usage
- Test camera performance at different frame rates
- Optimize based on results

### 11.2 UI/UX Testing

- Test all theme variants
- Verify responsive layout at different window sizes
- Test offline mode thoroughly
- Verify all animations are smooth

---

## 📝 Implementation Order Summary

1. ✅ Update data models (member avatar, expanded config)
2. ✅ Create offline storage & search services
3. ✅ Redesign home screen with sidebar layout
4. ✅ Add member avatars to cards
5. ✅ Create collapsible camera widget
6. ✅ Build advanced settings with tabs
7. ✅ Implement performance optimizations
8. ✅ Add member search feature
9. ✅ Enhanced stats & history
10. ✅ Offline mode support
11. ✅ Admin dashboard integration
12. ✅ Premium UI polish & animations
13. ✅ Testing & final optimizations

---

## 🎯 Expected Outcomes

- **Modern Premium UI**: Sleek, professional design with smooth animations
- **Better Performance**: 50%+ faster QR detection, lower memory usage
- **Enhanced Functionality**: Search, offline mode, detailed history
- **Professional Features**: Admin integration, advanced settings, theming
- **Improved UX**: Collapsible camera, sidebar layout, avatar display
- **Enterprise Ready**: Robust offline support, data export, detailed reports

### To-dos

- [ ] Create folder structure (lib/ and assets/ directories)
- [ ] Implement configuration and data models (5 files)
- [ ] Implement services layer (API, QR Scanner, Audio, Logger)
- [ ] Create Riverpod state providers for config and scanning
- [ ] Build HomeScreen and SettingsScreen
- [ ] Create all UI widgets (camera, info card, activity list, countdown, buttons)
- [ ] Update main.dart with window manager and app initialization
- [ ] Add assets, test animations, and final polish