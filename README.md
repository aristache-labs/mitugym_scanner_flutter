<div align="center">

<img src="assets/images/logo.png" width="76" alt="MituGym Scanner">

# MituGym · Scanner

<em>Windows desktop QR scanner for gym member check-in and check-out.</em>

<br />

<a href="https://github.com/pateutz1/mitugym_scanner_flutter">MituGym Scanner</a>

<br />

<img src="showcase/MituGym%20Scanner%20%C2%B7%20Prezentare%401x.png" width="100%" alt="MituGym Scanner · Presentation">

<br />

![Flutter](https://shields.io/badge/Flutter-Windows-76f5e1?style=flat-square&labelColor=0f6e68)
![Stars](https://shields.io/github/stars/pateutz1/mitugym_scanner_flutter?style=flat-square&labelColor=0f6e68&color=76f5e1)
![Contributors](https://shields.io/github/contributors/pateutz1/mitugym_scanner_flutter?style=flat-square&labelColor=0f6e68&color=76f5e1)
![License: MIT](https://shields.io/github/license/pateutz1/mitugym_scanner_flutter?style=flat-square&labelColor=0f6e68&color=76f5e1)
![Last commit](https://shields.io/github/last-commit/pateutz1/mitugym_scanner_flutter?style=flat-square&labelColor=0f6e68&color=76f5e1)
![Issues](https://shields.io/github/issues/pateutz1/mitugym_scanner_flutter?style=flat-square&labelColor=0f6e68&color=76f5e1)
![Watchers](https://shields.io/github/watchers/pateutz1/mitugym_scanner_flutter?style=flat-square&labelColor=0f6e68&color=76f5e1)

<strong>Windows desktop &middot; camera QR scanning &middot; local SQLite history &middot; offline queue &middot; live occupancy</strong><br>
<sub>Built with Flutter, Dart and Riverpod. Camera frames are decoded with ZXing; member activity is stored locally and synchronized with the MituGym backend. Validation commands: <code>flutter analyze</code> and <code>flutter test</code>.</sub>

<br />

[Stack](#stack) &middot; [The app](#the-app) &middot; [Local setup](#local-setup) &middot; [Settings panel](#settings-panel) &middot; [Deployment](#deployment)

<sub><b>Windows packaging:</b> installer workflows and distribution options are documented in <a href="README_INSTALLER.md"><code>README_INSTALLER.md</code></a>.</sub>

</div>

---

## Overview

MituGym Scanner is a Windows desktop application for managing gym member check-ins and check-outs through QR codes. Built with Flutter, it combines camera scanning, membership details, searchable member records, persistent activity history, and occupancy charts in a Material Design 3 interface. Local SQLite storage and an offline action queue keep activity available during connectivity interruptions, with synchronization when the connection returns. Staff can filter and export history, track active sessions, and configure camera, audio, and retention settings from the app.

## Table of Contents

- [MituGym · Scanner](#mitugym--scanner)
  - [Overview](#overview)
  - [Table of Contents](#table-of-contents)
  - [Stack](#stack)
  - [The app](#the-app)
  - [Architecture overview](#architecture-overview)
  - [Prerequisites](#prerequisites)
  - [Local setup](#local-setup)
    - [1. Clone and install](#1-clone-and-install)
    - [2. Backend configuration](#2-backend-configuration)
    - [3. Local database](#3-local-database)
    - [4. Camera setup](#4-camera-setup)
    - [5. Run the app](#5-run-the-app)
  - [Commands](#commands)
  - [Settings panel](#settings-panel)
  - [Deployment](#deployment)
  - [Contributing](#contributing)
  - [Contributors](#contributors)
  - [License](#license)
  - [Support the project](#support-the-project)
  - [Connect](#connect)

---

## Stack

| Layer | Technology |
| ----- | ---------- |
| Framework | Flutter (Windows desktop) |
| Language | Dart, SDK constraint `^3.9.2` |
| UI | Material Design 3, Google Fonts, Lucide icons |
| State management | Riverpod 3 |
| Camera | `camera`, `camera_windows` |
| QR decoding | `zxing2`, `image` |
| Networking | Dio, `connectivity_plus` |
| Local database | SQLite via `sqflite_common_ffi` |
| Preferences | `shared_preferences`, local configuration file |
| Charts | `fl_chart` |
| Animation | `flutter_animate`, `flutter_staggered_animations` |
| Audio | `audioplayers` |
| Desktop integration | `window_manager`, `tray_manager`, `launch_at_startup` |
| Export | CSV, text, `pdf` |
| Tests | `flutter_test` |
| Distribution | Windows release bundle, Inno Setup, NSIS, MSIX configuration |

---

## The app

The desktop interface brings daily gym operations into one workspace:

1. **Dashboard** - scan totals, check-ins, check-outs, denied access, and today's activity.
2. **Scanner** - camera preview, QR detection, member details, scan cooldown, and audio feedback.
3. **History** - persistent activity records with date and status filters, sorting, and exports.
4. **Member search** - searchable member records, membership status, plan details, and avatars.
5. **Statistics** - occupancy charts, peak activity, and gym schedule integration.
6. **Settings** - backend connection, camera, display, audio, retention, and desktop behavior.

The splash and login screens initialize the app and restore an existing session when available. An offline banner shows connectivity status and pending synchronization work.

---

## Architecture overview

- **Entry point** - `lib/main.dart` initializes the desktop app and its services.
- **Configuration** - `lib/config/` contains app settings, colors, and theme definitions.
- **State** - Riverpod providers in `lib/providers/` coordinate authentication, scanning, history, connectivity, and the offline queue.
- **Screens and widgets** - `lib/screens/` defines the main views; `lib/widgets/` contains shared navigation, member cards, camera previews, and dialogs.
- **Scanning** - the Windows scanner service captures camera frames and decodes QR codes with ZXing. Scan handling applies cooldown rules and sends check-in/check-out requests to the backend.
- **Backend** - services in `lib/services/` handle authentication, member lookup, activity synchronization, and gym schedules through the MituGym API.
- **Local data** - SQLite stores member records, activity history, and queued offline actions. Models live in `lib/models/`.
- **Feedback and reporting** - audio, logging, and export services provide scan feedback and activity reports.

---

## Prerequisites

- **Flutter SDK** with a bundled Dart version satisfying `^3.9.2`.
- **Windows** with desktop development enabled in Flutter.
- **Visual Studio** with the **Desktop development with C++** workload for Windows builds.
- A **camera** available to Windows and camera access enabled for desktop apps.
- Access to a **MituGym backend**, its API configuration, and a valid staff account.
- **Git** to clone the repository.

---

## Local setup

### 1. Clone and install

```powershell
git clone https://github.com/pateutz1/mitugym_scanner_flutter.git
cd mitugym_scanner_flutter
flutter pub get
```

### 2. Backend configuration

Open the app's settings and configure the API base URL and API key for your MituGym backend. Sign in with a valid staff account.

The default backend URL is `https://mitugym-app-webpanel.vercel.app`. Defaults are defined in `lib/config/app_config.dart`; deployment-specific connection settings can be changed from the app.

| Setting | Purpose |
| ------- | ------- |
| API URL | Base URL of the MituGym backend |
| API key | Backend API authentication |
| Staff credentials | Login and session creation |

### 3. Local database

The app manages its local SQLite database through `lib/services/offline_storage_service.dart`. No separate database server is required for the desktop client.

Member records, activity history, and pending offline actions are persisted locally. History retention and cleanup options are available in Settings.

### 4. Camera setup

Check the Windows toolchain and connected devices:

```powershell
flutter doctor
flutter devices
```

Select the camera in Settings, adjust the capture frame rate, and set the scan cooldown. Enable audio feedback and the camera preview as needed.

### 5. Run the app

```powershell
flutter run -d windows
```

Sign in, confirm the backend connection, and scan a member QR code from the Scanner screen.

---

## Commands

| Command | Description |
| ------- | ----------- |
| `flutter pub get` | Install dependencies |
| `flutter doctor` | Check the Flutter and Windows build toolchain |
| `flutter devices` | List available target devices |
| `flutter run -d windows` | Run the Windows app in debug mode |
| `flutter analyze` | Run static analysis |
| `flutter test` | Run the test suite |
| `dart format lib test` | Format Dart source and tests |
| `flutter build windows --release` | Build the Windows release bundle |
| `.\build_installer.ps1` | Run the installer build workflow |
| `.\build_installer.ps1 -InstallerType inno` | Build an Inno Setup installer |
| `.\build_installer.ps1 -SkipBuild` | Package an existing build |
| `flutter clean` | Remove generated build artifacts |

Installer requirements and additional packaging options are documented in [README_INSTALLER.md](README_INSTALLER.md).

---

## Settings panel

The settings panel controls the scanner workstation:

- **General** - API URL and key, camera selection, and capture frame rate.
- **Display** - scan cooldown, camera preview, automatic scanning, font size, animations, and theme preferences.
- **Audio** - success/error feedback and volume.
- **Advanced** - log and history retention, export preferences, database cleanup, synchronization, verbose logging, and desktop options.

The configuration model is in `lib/config/app_config.dart`. Authentication, local history, and offline synchronization are handled by their respective providers and services.

---

## Deployment

The app is distributed as a Windows desktop application.

1. Install dependencies with `flutter pub get`.
2. Run `flutter analyze` and `flutter test` and resolve failures before packaging.
3. Build with `flutter build windows --release`.
4. Package the complete release bundle using `build_installer.bat` or `build_installer.ps1`.
5. Install on the target workstation, configure its backend connection and camera, then verify login and a member scan.

Distribute the complete Flutter Windows bundle, including its DLLs and data directory. The executable depends on these files.

See [README_INSTALLER.md](README_INSTALLER.md) for Inno Setup, NSIS, and MSIX workflows.

---

## Contributing

Contributions are welcome. Fork the repository, create a branch, and open a pull request with a description of the change and its validation. Run `flutter analyze` and `flutter test` before submitting.

Bugs and feature requests go to [Issues][issues]. Include the Windows version, reproduction steps, and relevant logs when reporting a scanner or synchronization problem.

## Contributors

Thanks to everyone who has contributed to MituGym Scanner.

<a href="https://github.com/pateutz1/mitugym_scanner_flutter/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=pateutz1/mitugym_scanner_flutter" alt="Contributors" />
</a>

## License

Licensed under the **MIT** license. See [LICENSE](LICENSE).

## Support the project

MituGym Scanner is MIT licensed and free to fork. Star the [repository][repo], report reproducible issues, or contribute improvements through a [pull request][pulls].

## Connect

<div align="center">

**Adrian Cristache** · [aristache.dev](https://www.aristache.dev)

<a href="https://github.com/pateutz1"><img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub" /></a>
<a href="https://www.aristache.dev"><img src="https://img.shields.io/badge/Site-0f6e68?style=for-the-badge&logo=googlechrome&logoColor=white" alt="aristache.dev" /></a>

</div>

[repo]: https://github.com/pateutz1/mitugym_scanner_flutter
[issues]: https://github.com/pateutz1/mitugym_scanner_flutter/issues
[pulls]: https://github.com/pateutz1/mitugym_scanner_flutter/pulls
[contributors]: https://github.com/pateutz1/mitugym_scanner_flutter/graphs/contributors
