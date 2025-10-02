# MituGym Scanner 🏋️‍♂️📱

A professional Windows desktop QR code scanner application for gym member check-in/check-out management, built with Flutter.

![Flutter](https://img.shields.io/badge/Flutter-3.35.5-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## ✨ Features

### Core Functionality
- 📸 **Real-time QR Code Scanning** - Windows camera integration with ZXing
- 🔄 **Auto Check-in/Check-out** - Automatic member status detection
- ⏱️ **Smart Cooldown** - Configurable 3-10 second debounce to prevent duplicate scans
- 🔊 **Audio Feedback** - Success/error sound notifications
- 📝 **Activity Logging** - Daily log files with full scan history

### UI/UX
- 🎨 **Modern Design** - Cyan/teal color scheme matching admin panel
- ✨ **Smooth Animations** - Professional transitions and effects
- 🌙 **Dark Theme** - Eye-friendly Material Design 3
- 📊 **Statistics Dashboard** - Real-time analytics and success rates
- 📤 **Export Functionality** - CSV and text format exports

### Technical Features
- 🔐 **API Integration** - RESTful backend communication
- 💾 **Persistent Settings** - SharedPreferences for configuration
- 🪟 **Window Management** - Customizable window size and position
- 🎯 **State Management** - Riverpod for reactive updates
- 📱 **Responsive UI** - Adaptive layouts

## 🎨 Screenshots

### Splash Screen
Beautiful animated intro with logo and branding

### Main Scanner
- Live camera preview with QR detection overlay
- Real-time member information display
- Recent activity list (last 10 scans)
- Status indicators and controls

### Statistics Dashboard
- Total scans counter
- Today's activity
- Success/failure metrics
- Success rate with visual progress

### Settings
- API URL configuration
- API key management
- Cooldown duration slider
- Audio toggle

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

## 📦 Dependencies

### Core
- **flutter** - UI framework
- **flutter_riverpod** (^2.6.1) - State management
- **window_manager** (^0.4.3) - Desktop window control

### Camera & QR
- **camera** (^0.11.0) - Camera access
- **camera_windows** (^0.2.3) - Windows camera support
- **zxing2** (^0.2.3) - QR code detection
- **image** (^4.3.0) - Image processing

### Networking & Storage
- **dio** (^5.7.0) - HTTP client
- **shared_preferences** (^2.3.3) - Local storage
- **path_provider** (^2.1.5) - File system access

### UI & Animation
- **flutter_animate** (^4.5.0) - Smooth animations
- **shimmer** (^3.0.0) - Loading effects

### Utilities
- **audioplayers** (^6.1.0) - Sound feedback
- **logger** (^2.4.0) - Logging system
- **intl** (^0.20.1) - Date formatting

## 🎨 Color Scheme

The app uses a professional cyan/teal palette matching the MituGym admin panel:

| Color | Hex | Usage |
|-------|-----|-------|
| Primary | `#4dd4d4` | Buttons, accents, active states |
| Secondary | `#5cdfdf` | Highlights, gradients |
| Success | `#00e6a6` | Success indicators, check-ins |
| Error | `#ff6b6b` | Error states, failed scans |
| Warning | `#ffd93d` | Warnings, alerts |
| Background | `#0a0f0f` | Main background |
| Surface | `#141a1a` | Cards, containers |
| Text | `#f0fefe` | Primary text |

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

## 🏗️ Project Structure

```
lib/
├── config/          # App configuration & theme
├── models/          # Data models
├── services/        # Business logic & API
├── providers/       # Riverpod state management
├── screens/         # UI screens
├── widgets/         # Reusable components
└── main.dart        # App entry point
```

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

**pateutz1**
- GitHub: [@pateutz1](https://github.com/pateutz1)
- Experienced React Native Developer with expertise in Flutter, Next.js, and SQL

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- ZXing for QR code detection
- Riverpod for state management
- MituGym for the opportunity

## 📞 Support

For support, please open an issue in the GitHub repository.

---

**Made with ❤️ using Flutter**
