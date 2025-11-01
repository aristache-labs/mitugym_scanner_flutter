# MituGym Scanner 🏋️‍♂️📱

A **premium** Windows desktop QR code scanner application for gym member check-in/check-out management, built with Flutter. Features a modern Material Design 3 UI, real-time member tracking, offline-first architecture, persistent history database, and comprehensive analytics.

![Flutter](https://img.shields.io/badge/Flutter-3.35.5-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Riverpod](https://img.shields.io/badge/Riverpod-3.0.1-purple.svg)

## 📋 Table of Contents
- [Key Features](#-key-features)
- [Application Screens](#-application-screens)
- [Getting Started](#-getting-started)
- [Configuration](#-configuration)
- [Dependencies & Technologies](#-dependencies--technologies)
- [Design System](#-design-system)
- [Export Formats](#-export-formats)
- [Logs & Data Storage](#-logs--data-storage)
- [Project Architecture](#-project-architecture)
- [Core Functionalities](#-core-functionalities)
- [Technical Implementation](#-technical-implementation)
- [Contributing](#-contributing)
- [License](#-license)
- [Author](#-author)
- [Project Status](#-project-status)

## ✨ Key Features

### 🎨 Modern UI & UX
- **Material Design 3** - Clean, modern interface with Google Fonts (Inter)
- **Modern Sidebar Navigation** - 320px sidebar with 5 main sections + settings
- **Member Avatars** - Network images with gradient fallbacks and initials
- **Responsive Layout** - 1400x900 window, minimum 1200x700
- **Gradient Accents** - Beautiful gradients and smooth animations throughout
- **Theme Colors** - Primary green (#1e9b71) with dark mode theme
- **Collapsible Camera** - Toggle camera preview with smooth animations
- **Animated Splash Screen** - Professional branding intro

### 📸 QR Code Scanning
- **Real-time QR Scanning** - Windows camera support with ZXing decoder
- **Configurable Frame Rate** - 5-30 FPS for optimal performance
- **Smart Cooldown** - 2-15 second configurable debounce to prevent double scans
- **Auto Check-in/Checkout** - Automatic detection based on member status
- **TOTP Verification** - Time-based one-time password validation
- **Visual Feedback** - Real-time scan status and member information display
- **Audio Feedback** - Success/error sounds with volume control (0-100%)

### 🗄️ Offline-First Architecture
- **SQLite Database** - Local storage for members and activity history
- **Offline Queue** - Automatic queuing of scans when offline
- **Auto-Sync** - Background sync when connection restored
- **Duplicate Prevention** - Smart duplicate detection within cooldown period
- **Conflict Resolution** - Automatic handling of offline/online conflicts
- **Persistent History** - Configurable retention (7-365 days)
- **Verbose Logging** - Optional detailed logging for debugging

### 📊 Dashboard & Analytics
- **Real-time Stats** - Total scans, check-ins, check-outs, denied access
- **Success Rate Tracking** - Visual progress indicators and percentages
- **Peak Hours Analysis** - Morning, afternoon, evening breakdown
- **Today's Activity** - Detailed view with sortable columns
- **Member Duration Tracking** - Automatic calculation of gym session time
- **Active Session Monitoring** - Track members currently in the gym
- **Live Occupancy Chart** - Real-time line chart showing gym occupancy by hour
- **Peak Occupancy Tracking** - Display maximum gym occupancy for the day
- **Gym Schedule Integration** - Shows occupancy only during gym operating hours
- **Hourly Auto-Sync** - Automatic data refresh every hour

### 📜 History & Search
- **Complete History View** - All activity logs with pagination
- **Advanced Filtering** - By status (all/success/failed), date range, member name
- **Date Grouping** - Activities grouped by date with expand/collapse
- **Sortable Columns** - Sort by member, check-in, check-out, duration, time
- **Member Search** - Real-time search across all members
- **Status Filtering** - Filter by active/expired membership
- **Export Functionality** - CSV and Text format exports
- **Date Range Picker** - Modern compact modal with quick presets (today, yesterday, last 7 days, last 30 days, this month, last month)
- **Visual Date Selection** - Interactive calendar with range selection
- **Filter Chips** - Visual filter indicators with clear all option

### 👥 Member Management
- **Member Database** - Local SQLite cache of all members
- **Search Interface** - Real-time search with status filters
- **Member Details Modal** - Comprehensive member information view
- **Avatar Modal** - Expandable avatar viewer with member info
- **Plan Tracking** - Membership plan and expiration date
- **Status Indicators** - Visual active/expired/inactive status

### ⚙️ Advanced Settings (4 Tabs)
- **General Tab**
  - API URL configuration
  - API Key management
  - Camera device selection (0-5)
  - Frame rate adjustment (5-30 FPS)
  
- **Display Tab**
  - Scan cooldown duration (2-15 seconds)
  - Show camera by default toggle
  - Auto-start scanning toggle
  - Font size adjustment
  - Animation speed control
  - Theme selection
  
- **Audio Tab**
  - Enable/disable audio feedback
  - Volume control slider (0-100%)
  
- **Advanced Tab**
  - Log retention (7-90 days)
  - History retention (7-365 days)
  - Export format (CSV/Text)
  - Database cleanup tools
  - Server sync functionality
  - Verbose logging toggle
  - Minimize to tray option

### 🔐 Authentication & Security
- **Session-based Auth** - Secure authentication with session tokens
- **Persistent Sessions** - Stay logged in across app restarts
- **Auto-logout** - Automatic logout on session expiry
- **Secure Storage** - Encrypted local storage for sensitive data
- **TOTP Validation** - Time-based token verification for scans

### 🔗 Connectivity & Sync
- **Connectivity Detection** - Real-time online/offline status monitoring
- **Offline Banner** - Visual indicator with pending sync count
- **Background Sync** - Automatic sync of queued actions
- **History Sync** - Server sync for activity history
- **Retry Logic** - Automatic retry for failed network requests

## 📱 Application Screens

### 1. Splash Screen
- Animated logo with gradient background
- Loading progress indicator
- Auto-transitions to login or main screen based on session

### 2. Login Screen
- Modern authentication interface
- Username/password fields with validation
- Remember me functionality
- Session persistence
- Error handling with user feedback

### 3. Dashboard Screen (Home)
- **Stats Overview Cards**: Total scans, check-ins, check-outs, denied access
- **Today's Activity Table**: Recent check-ins with sortable columns
  - Member column (avatar + name)
  - Check-in time column
  - Check-out time column
  - Duration column
- **Sorting**: Click column headers to sort by member, check-in, check-out, or duration
- **Member Modals**: Click avatar or name to view details

### 4. Scanner Screen
- **Left Panel**: Camera preview with controls
  - Collapsible camera widget
  - Start/Stop scanner button
  - Real-time status messages
  - Frame rate: 5-30 FPS (configurable)
- **Right Panel**: Member information display
  - Last scanned member details
  - Cooldown timer (when active)
  - Success/error status indicators

### 5. Check-ins Screen (Stats)
- **Quick Stats Cards**: Total, check-ins, check-outs, denied
- **Success Rate Card**: Visual progress bar with percentage
- **Peak Hours Analysis**: Morning, afternoon, evening breakdown
- **Recent Activity**: Last 5 activities with full details
- **Sortable Table**: Same structure as dashboard
- **Live Occupancy Chart**: Real-time line chart with fl_chart
  - Shows current gym occupancy by hour
  - Live data (solid line) vs projected data (dashed line)
  - Filtered by gym schedule (opening/closing hours)
  - Peak occupancy indicator
  - Updates hourly automatically
  - Interactive tooltips with hour and occupancy count

### 6. History Screen
- **Search & Filters**:
  - Real-time search by member name
  - Filter chips: All, Success, Denied
  - Modern date range picker modal with quick presets
  - Clear filters button
- **Date Grouping**: Activities grouped by date with expand/collapse
- **Sortable Columns**: Member, check-in, check-out, duration, time
- **Pagination**: Lazy loading with infinite scroll (loads more at 90% scroll)
- **Export Button**: Export filtered results to CSV or Text
- **Activity Details**: Click member to view full details
- **Date Range Picker Modal**:
  - Quick presets: Today, Yesterday, Last 7 Days, Last 30 Days, This Month, Last Month
  - Interactive calendar with visual date selection
  - Range selection with start and end dates
  - Month navigation
  - Modern Material Design 3 UI with gradients

### 7. Search Screen (Members)
- **Search Bar**: Real-time search across all members
- **Status Filters**: All, Active, Expired
- **Sortable Table**:
  - Member column (avatar + name)
  - Plan column
  - Expiration date column
  - Status column (with colored badges)
- **Member Details**: Click any member to view full profile

### 8. Settings Screen
- **Tab-based Navigation**: General, Display, Audio, Advanced
- **General Tab**:
  - API URL text field
  - API Key text field (obscured)
  - Camera device slider (0-5)
  - Frame rate slider (5-30 FPS)
- **Display Tab**:
  - Scan cooldown slider (2-15 seconds)
  - Show camera toggle
  - Auto-start scanning toggle
- **Audio Tab**:
  - Enable audio toggle
  - Volume slider (0-100%)
- **Advanced Tab**:
  - Log retention slider (7-90 days)
  - History retention slider (7-365 days)
  - Export format dropdown (CSV/Text)
  - Database stats display
  - Cleanup old history button
  - Sync from server button
- **Save/Reset Buttons**: Modern action bar at bottom

## 🚀 Getting Started

### Prerequisites
- Windows 10/11
- Flutter SDK 3.35.5 or higher
- Webcam/camera device

### Installation

1. **Clone the repository**
```powershell
git clone https://github.com/pateutz1/mitugym_scanner_flutter.git
cd mitugym_scanner_flutter
```

2. **Install dependencies**
```powershell
flutter pub get
```

3. **Run the application**
```powershell
flutter run -d windows
```

### Building for Release

```powershell
flutter build windows --release
```

The executable will be in: `build\windows\x64\runner\Release\`

## 🔧 Configuration

### API Setup
1. Open **Settings** in the app
2. Enter your API URL (default: `https://mitugym-app-webpanel.vercel.app`)
3. Enter your API key
4. Adjust scan cooldown (3-10 seconds)
5. Enable/disable audio feedback

### API Endpoint
```
POST /api/checkin
Content-Type: application/json

{
  "qr_code": "member_id:totp_code",
  "api_key": "your_api_key",
  "action": "auto"
}
```

### Response Format
```json
{
  "success": true,
  "message": "Check-in successful",
  "data": {
    "member_id": "uuid",
    "member_name": "John Doe",
    "plan_name": "Premium",
    "expires_at": "2025-12-31T23:59:59Z",
    "membership_status": "active"
  }
}
```

## 📦 Dependencies & Technologies

### Core Framework
- **Flutter SDK** (^3.35.5) - Cross-platform UI framework
- **Dart** (^3.9.2) - Programming language

### State Management
- **flutter_riverpod** (^3.0.1) - Reactive state management
- **riverpod_annotation** (^3.0.1) - Code generation for providers
- **riverpod_generator** (^3.0.1) - Dev dependency for code generation

### Camera & QR Code Scanning
- **camera** (^0.11.0+2) - Camera access and control
- **camera_windows** (^0.2.3) - Windows-specific camera implementation
- **zxing2** (^0.2.3) - QR code detection and decoding
- **image** (^4.3.0) - Image processing and manipulation

### Networking & HTTP
- **dio** (^5.7.0) - HTTP client with interceptors
- **connectivity_plus** (^7.0.0) - Network connectivity detection

### Local Storage & Database
- **shared_preferences** (^2.3.3) - Key-value persistent storage
- **sqflite** (^2.4.1) - SQLite database for Flutter
- **sqflite_common_ffi** (^2.3.4) - FFI-based SQLite for desktop
- **path_provider** (^2.1.5) - File system path access

### UI Components & Styling
- **google_fonts** (^6.2.1) - Inter font family
- **cached_network_image** (^3.4.1) - Network image caching
- **shimmer** (^3.0.0) - Loading shimmer effects
- **badges** (^3.1.2) - Badge widgets for notifications
- **fl_chart** (^1.1.1) - Charts and graphs for live occupancy visualization
- **flutter_animate** (^4.5.0) - Animation utilities
- **flutter_staggered_animations** (^1.1.1) - Staggered list animations
- **lucide_icons** (^0.257.0) - Modern icon library

### Desktop Support
- **window_manager** (^0.5.1) - Window control for desktop platforms

### Utilities
- **audioplayers** (^6.1.0) - Audio playback for feedback sounds
- **logger** (^2.4.0) - Logging and debugging
- **intl** (^0.20.1) - Internationalization and date formatting
- **uuid** (^4.5.1) - UUID generation
- **url_launcher** (^6.3.1) - Launch URLs in external browser

### Development Dependencies
- **flutter_test** - Testing framework
- **flutter_lints** (^6.0.0) - Linting rules
- **build_runner** (^2.4.13) - Code generation runner

## 🎨 Design System

### Color Palette
The app uses a dark theme with green primary accent:

| Color | Hex | Usage |
|-------|-----|-------|
| Primary | `#1e9b71` | Primary buttons, accents, active states, gradients |
| Primary Light | `#2bc799` | Hover states, highlights |
| Success | `#00e6a6` | Success indicators, check-ins, completed actions |
| Success Light | `#00ffc5` | Success highlights |
| Error | `#ff6b6b` | Error states, failed scans, denied access |
| Error Light | `#ff8787` | Error highlights |
| Warning | `#ffd93d` | Warnings, check-outs, pending states |
| Warning Light | `#ffe66d` | Warning highlights |
| Background | `#0a0f0f` | Main app background |
| Surface | `#141a1a` | Cards, elevated surfaces |
| Card | `#1a2222` | Card backgrounds |
| Border | `#2a3a3a` | Borders, dividers |
| Text Primary | `#f0fefe` | Primary text |
| Text Secondary | `#c0d0d0` | Secondary text |
| Text Muted | `#809090` | Disabled, muted text |

### Typography
- **Font Family**: Inter (Google Fonts)
- **Sizes**: 10px - 36px depending on context
- **Weights**: Regular (400), Medium (500), Semi-bold (600), Bold (700)

### UI Components
- **Border Radius**: 8px - 24px (cards and containers)
- **Shadows**: Subtle shadows with blur radius 8-20px
- **Gradients**: Linear gradients for cards, buttons, and accents
- **Spacing**: 4px base unit (4, 8, 12, 16, 20, 24px)

## 📊 Export Formats

### CSV Export
```csv
Member Name,Action,Date,Time,Status
"John Doe","Check-in successful","2025-10-02","18:30:45","Success"
```

### Text Export
```
============================================================
MituGym Scanner - Activity Report
Generated: 2025-10-02 18:35:22
Total Activities: 10
============================================================

STATISTICS
------------------------------------------------------------
Successful: 8
Failed: 2
Success Rate: 80.0%
```

## 📝 Logs

Activity logs are saved to:
```
%USERPROFILE%\Documents\mitugym_logs\
Format: mitugym_YYYY-MM-DD.log
```

Exports are saved to:
```
%USERPROFILE%\Documents\mitugym_exports\
```

## 🏗️ Project Architecture

### Directory Structure
```
lib/
├── config/                         # Configuration & theming
│   ├── app_colors.dart            # Color constants and gradients
│   ├── app_config.dart            # App configuration model
│   ├── app_themes.dart            # Theme presets (unused)
│   └── theme.dart                 # Material theme configuration
│
├── models/                        # Data models & entities
│   ├── activity_log.dart          # Activity/scan log model
│   ├── auth_session.dart          # Authentication session model
│   ├── gym_schedule.dart          # Gym schedule model (opening/closing hours)
│   ├── member_data.dart           # Member information model
│   ├── pending_action.dart        # Offline queue action model
│   └── scan_result.dart           # QR scan result model
│
├── providers/                     # Riverpod state management
│   ├── auth_provider.dart         # Authentication state
│   ├── config_provider.dart       # App configuration state
│   ├── gym_schedule_provider.dart # Gym schedule state
│   ├── history_provider.dart      # Activity history state
│   ├── logger_provider.dart       # Logger service provider
│   ├── offline_provider.dart      # Offline mode state
│   ├── offline_queue_provider.dart # Offline queue state
│   ├── scan_provider.dart         # Scan state & logic
│   └── windows_scanner_provider.dart # Scanner controller state
│
├── screens/                       # Application screens
│   ├── dashboard_screen.dart      # Home/Dashboard view
│   ├── history_screen.dart        # Activity history with filters
│   ├── login_screen.dart          # Authentication screen
│   ├── main_layout_screen.dart    # Main app layout with sidebar
│   ├── scanner_screen.dart        # QR scanning interface
│   ├── search_screen.dart         # Member search interface
│   ├── settings_screen.dart       # Settings with tabs
│   ├── splash_screen.dart         # Splash/loading screen
│   └── stats_screen.dart          # Statistics & analytics
│
├── services/                      # Business logic & external services
│   ├── api_service.dart           # HTTP API communication
│   ├── audio_service.dart         # Sound playback service
│   ├── auth_service.dart          # Authentication service
│   ├── connectivity_service.dart  # Network connectivity detection
│   ├── export_service.dart        # CSV/Text export functionality
│   ├── history_sync_service.dart  # History synchronization
│   ├── logger_service.dart        # Logging service
│   ├── mock_qr_scanner_service.dart # Mock scanner for testing
│   ├── offline_queue_service.dart # Offline action queue management
│   ├── offline_storage_service.dart # SQLite database operations
│   ├── search_service.dart        # Member search functionality
│   └── windows_qr_scanner_service.dart # Windows QR scanner implementation
│
├── widgets/                       # Reusable UI components
│   ├── activity_list_widget.dart  # Activity list component
│   ├── collapsible_camera_widget.dart # Camera preview with collapse
│   ├── control_buttons.dart       # Scanner control buttons
│   ├── countdown_timer.dart       # Cooldown timer widget
│   ├── date_range_picker_modal.dart # Modern date range picker modal
│   ├── member_avatar_modal.dart   # Avatar expansion modal
│   ├── member_details_modal.dart  # Member info modal
│   ├── member_info_card.dart      # Member information card
│   ├── mock_camera_preview_widget.dart # Mock camera for testing
│   ├── modern_sidebar_widget.dart # Main navigation sidebar
│   ├── offline_banner_widget.dart # Offline status banner
│   ├── sidebar_widget.dart        # Legacy sidebar (unused)
│   └── windows_camera_preview_widget.dart # Windows camera preview
│
└── main.dart                      # App entry point & initialization

assets/
├── images/
│   └── logo.png                   # App logo
└── sounds/
    ├── success.mp3                # Success scan sound
    └── error.mp3                  # Error scan sound

windows/                           # Windows platform configuration
├── runner/                        # Windows runner code
└── CMakeLists.txt                # Windows build configuration
```

### Key Components

#### State Management (Providers)
- **AuthProvider**: Manages authentication state and session persistence
- **ConfigProvider**: Handles app settings and preferences
- **GymScheduleProvider**: Manages gym schedule (opening/closing hours) and occupancy tracking
- **HistoryProvider**: Manages activity logs with pagination and filtering
- **LoggerProvider**: Provides singleton logger service with verbose logging configuration
- **OfflineProvider**: Tracks online/offline connectivity status
- **OfflineQueueProvider**: Manages queued actions when offline
- **ScanProvider**: Controls QR scanning state and results
- **WindowsScannerProvider**: Manages Windows camera and scanner lifecycle

#### Services Layer
- **ApiService**: RESTful API communication with MituGym backend
- **AudioService**: Plays success/error sounds with volume control
- **AuthService**: Handles login, logout, session management
- **ConnectivityService**: Monitors internet connection status
- **ExportService**: Exports activity data to CSV or Text files
- **HistorySyncService**: Syncs activity history with server
- **LoggerService**: Centralized logging with file output
- **OfflineStorageService**: SQLite database operations for members and history
- **OfflineQueueService**: Manages and processes offline action queue
- **SearchService**: Implements member search with fuzzy matching
- **WindowsQrScannerService**: QR code scanning using camera and ZXing

#### Data Models
- **ActivityLog**: Represents a member check-in/check-out event
- **AuthSession**: Stores authentication session data
- **GymSchedule**: Gym schedule model with opening/closing hours and occupancy calculations
- **MemberData**: Member profile information
- **PendingAction**: Queued action for offline sync
- **ScanResult**: Result from QR code scan operation

#### Widgets
- **ModernSidebarWidget**: Main navigation with 5 sections + settings
- **MemberInfoCard**: Displays member details after scan
- **MemberDetailsModal**: Full member profile modal
- **MemberAvatarModal**: Expandable avatar viewer
- **DateRangePickerModal**: Modern date range picker with presets and calendar
- **OfflineBannerWidget**: Shows offline status and sync queue
- **CollapsibleCameraWidget**: Camera preview with show/hide
- **CountdownTimer**: Visual cooldown timer
- **ActivityListWidget**: Reusable activity list component

## 🔑 Core Functionalities

### QR Code Scanning Flow
1. **Scanner Initialization**: Camera device selected (0-5), frame rate configured (5-30 FPS)
2. **QR Detection**: ZXing continuously scans frames for QR codes
3. **Code Validation**: Validates QR format (member_id:totp_code)
4. **TOTP Verification**: Time-based token validated against server
5. **Member Lookup**: Checks local database first, then API if needed
6. **Auto Check-in/Checkout**: Determines action based on current member status
7. **Duplicate Prevention**: Cooldown period (2-15s) prevents duplicate scans
8. **Result Display**: Shows member info, plan, expiration, status
9. **Audio Feedback**: Plays success/error sound based on result
10. **History Logging**: Saves to both SQLite database and activity logs

### Offline Mode Operation
1. **Connectivity Detection**: Continuous monitoring via ConnectivityService
2. **Queue Management**: Failed actions automatically queued in SQLite
3. **Background Sync**: Auto-retry when connection restored
4. **Conflict Resolution**: Server state takes precedence on sync
5. **Visual Feedback**: Offline banner shows queue count
6. **Data Integrity**: Transactions ensure database consistency

### History & Reporting System
1. **Persistent Storage**: SQLite database with configurable retention (7-365 days)
2. **Pagination**: Lazy loading for efficient large dataset handling
3. **Filtering**: Real-time filters by status, date range, member name
4. **Sorting**: Multi-column sorting (member, check-in, check-out, duration)
5. **Date Grouping**: Automatic grouping by date with expand/collapse
6. **Export**: CSV and Text format with filtered data
7. **Sync**: Server synchronization for cross-device consistency
8. **Cleanup**: Automated cleanup of old records

### Member Management
1. **Local Cache**: All members stored in SQLite for offline access
2. **Auto-Update**: Member data refreshed on each successful scan
3. **Search**: Fuzzy search across member names
4. **Status Tracking**: Active/expired/inactive membership status
5. **Plan Tracking**: Membership plan and expiration dates
6. **Avatar Support**: Network images with gradient fallbacks

### Authentication & Sessions
1. **Login**: Username/password authentication
2. **Session Tokens**: Secure session token storage
3. **Persistence**: Sessions persist across app restarts
4. **Auto-Login**: Automatic login if valid session exists
5. **Logout**: Clean session termination
6. **Expiry Handling**: Automatic logout on session expiry

### Gym Schedule & Occupancy Tracking
1. **Schedule Fetching**: Automatic retrieval of daily gym schedule from API
2. **Opening Hours**: Dynamic opening and closing hour tracking
3. **Occupancy Calculation**: Real-time calculation of gym occupancy by hour
4. **Chart Visualization**: Live occupancy displayed via fl_chart line graph
5. **Peak Tracking**: Identification and display of peak occupancy times
6. **Schedule Integration**: Chart displays only during gym operating hours
7. **Hourly Updates**: Automatic data refresh every hour
8. **Closed Day Handling**: Support for gym closure days

## 🛠️ Technical Implementation

### Database Schema

#### Members Table
```sql
CREATE TABLE members (
  member_id TEXT PRIMARY KEY,
  member_name TEXT NOT NULL,
  plan_name TEXT,
  expires_at TEXT,
  membership_status TEXT,
  avatar_url TEXT,
  created_at TEXT,
  updated_at TEXT
)
```

#### Activity Logs Table
```sql
CREATE TABLE activity_logs (
  id TEXT PRIMARY KEY,
  member_id TEXT,
  member_name TEXT,
  action TEXT,
  success INTEGER,
  error_message TEXT,
  check_in_time TEXT,
  check_out_time TEXT,
  duration_minutes INTEGER,
  avatar_url TEXT,
  timestamp TEXT,
  FOREIGN KEY (member_id) REFERENCES members (member_id)
)
```

#### Offline Queue Table
```sql
CREATE TABLE offline_queue (
  id TEXT PRIMARY KEY,
  action_type TEXT,
  qr_code TEXT,
  payload TEXT,
  timestamp TEXT,
  retry_count INTEGER
)
```

### API Integration

**Base URL**: Configurable in settings  
**Default**: `https://mitugym-app-webpanel.vercel.app`

#### Endpoints Used:
- `POST /api/auth/login` - User authentication
- `POST /api/auth/logout` - Session termination
- `POST /api/checkin` - Check-in/checkout with TOTP validation (supports offline scan flag)
- `GET /api/checkins/history` - Fetch activity history
- `GET /api/gym-schedule` - Fetch daily gym schedule (opening/closing hours)

### Configuration Storage
All settings stored in SharedPreferences:
- `api_url`: API base URL
- `api_key`: API authentication key
- `camera_index`: Selected camera device (0-5)
- `debounce_duration`: Scan cooldown (2-15s)
- `audio_enabled`: Audio feedback toggle
- `sound_volume`: Volume level (0.0-1.0)
- `camera_frame_rate`: Frame rate (5-30 FPS)
- `log_retention_days`: Log file retention (7-90 days)
- `history_retention_days`: Database retention (7-365 days)
- `export_format`: Default export format (csv/text)
- `auto_start_scanning`: Auto-start scanner on app launch
- `camera_visible`: Show camera preview by default
- `session_token`: Authentication session token
- `last_history_sync`: Last sync timestamp
- `font_size`: UI font size adjustment
- `animation_speed`: Animation speed multiplier
- `theme`: Theme selection
- `verbose_logging`: Detailed debug logging toggle
- `minimize_to_tray`: Minimize to system tray option

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

**Adrian Cristache**
- GitHub: [@pateutz1](https://github.com/pateutz1)
- Full-stack Developer specializing in Flutter, React Native, Next.js, and SQL
- Focus on offline-first mobile and desktop applications

## 🎯 Project Status

**Version**: 1.0.0  
**Status**: ✅ Production Ready  
**Platform**: Windows Desktop  
**Last Updated**: January 2025

### Recent Updates
- ✅ Persistent SQLite history database
- ✅ Session-based authentication
- ✅ Offline-first architecture with queue management
- ✅ Advanced filtering and sorting
- ✅ Configurable history retention
- ✅ Server synchronization
- ✅ Member search functionality
- ✅ Duplicate prevention system
- ✅ Live occupancy tracking with fl_chart
- ✅ Gym schedule integration
- ✅ Modern date range picker modal
- ✅ Verbose logging system
- ✅ Lucide icons integration
- ✅ Hourly auto-sync for stats

### Future Enhancements
- [ ] Multi-platform support (macOS, Linux)
- [ ] Member photo capture
- [ ] Export to PDF
- [ ] Multi-language support
- [ ] Dark/Light theme toggle
- [ ] Advanced chart filtering options
- [ ] Email reporting functionality

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing cross-platform framework
- **ZXing** - For reliable QR code detection
- **Riverpod** - For elegant state management
- **Google Fonts** - For the beautiful Inter font family
- **MituGym** - For the opportunity and requirements
- **Open Source Community** - For the excellent packages and tools

## 📞 Support & Issues

For support, bug reports, or feature requests:
- Open an issue in the [GitHub repository](https://github.com/pateutz1/mitugym_scanner_flutter/issues)
- Provide detailed information about your environment and steps to reproduce
- Include relevant logs from `%USERPROFILE%\Documents\mitugym_logs\`

## 📚 Related Documentation

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [ZXing Documentation](https://github.com/zxing/zxing)
- [SQLite Documentation](https://www.sqlite.org/docs.html)

---

**Built with ❤️ using Flutter and Dart**  
**© 2025 Adrian Cristache. All rights reserved.**
