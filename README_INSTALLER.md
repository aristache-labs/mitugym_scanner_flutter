# 📦 MituGym Scanner - Windows Installer Documentation

Complete guide for creating professional Windows installers for your Flutter application.

## 📑 Table of Contents
- [Quick Start](#quick-start)
- [Files Overview](#files-overview)
- [Installation Methods](#installation-methods)
- [Build Process](#build-process)
- [Customization](#customization)
- [Distribution](#distribution)
- [Troubleshooting](#troubleshooting)

---

## 🚀 Quick Start

### The Easiest Way (Double-Click):

1. **Double-click:** `build_installer.bat`
2. **Choose** an installer type (press 1 for recommended)
3. **Wait** for the build to complete
4. **Find** your installer in the `Output` folder

**That's it!** 🎉

---

## 📁 Files Overview

### Core Files

| File | Description | When to Use |
|------|-------------|-------------|
| `build_installer.bat` | Simple batch script | Just double-click! |
| `build_installer.ps1` | PowerShell automation | Advanced users |
| `installer_script.iss` | Inno Setup config | Professional installers |
| `installer_script.nsi` | NSIS config | Alternative method |
| `pubspec.yaml` | MSIX configuration | Quick MSIX builds |

### Documentation Files

| File | Description |
|------|-------------|
| `INSTALLER_GUIDE.md` | Detailed guide with all options |
| `INSTALLER_QUICK_START.md` | Quick reference card |
| `README_INSTALLER.md` | This file - comprehensive docs |

---

## 🛠️ Installation Methods

### Method 1: Batch Script (Recommended for Beginners)

```batch
# Just double-click
build_installer.bat
```

**Pros:**
- ✅ No command line needed
- ✅ Interactive menu
- ✅ Automatic error handling
- ✅ Opens output folder when done

### Method 2: PowerShell Script (Recommended for Developers)

```powershell
# Basic usage
.\build_installer.ps1

# Build specific type
.\build_installer.ps1 -InstallerType inno

# Skip Flutter build (faster if already built)
.\build_installer.ps1 -SkipBuild

# Clean build
.\build_installer.ps1 -Clean

# Build all types
.\build_installer.ps1 -InstallerType all
```

**Pros:**
- ✅ Full automation
- ✅ Flexible options
- ✅ Detailed progress output
- ✅ Error handling

### Method 3: Manual MSIX (Quickest)

```powershell
# One-time setup
flutter pub add msix --dev

# Build
flutter build windows --release

# Create MSIX
flutter pub run msix:create
```

**Pros:**
- ✅ Fastest method
- ✅ Built into Flutter
- ✅ Microsoft Store compatible

**Cons:**
- ❌ Windows 10+ only
- ❌ Requires certificate for distribution

### Method 4: Manual Inno Setup (Most Professional)

1. Download Inno Setup: https://jrsoftware.org/isdl.php
2. Build your app:
   ```powershell
   flutter build windows --release
   ```
3. Open `installer_script.iss` in Inno Setup
4. Click **Build → Compile**

**Pros:**
- ✅ Professional installer
- ✅ Works on Windows 7+
- ✅ Full customization
- ✅ No certificate needed for testing

---

## 🔧 Build Process

### What Happens During Build?

```
1. 🧹 Clean (if requested)
   └─ Remove old build files

2. 📦 Flutter Build
   ├─ Get dependencies (flutter pub get)
   ├─ Build for Windows (flutter build windows --release)
   └─ Output to: build\windows\x64\runner\Release\

3. 🔨 Create Installer
   ├─ Package all required files
   ├─ Include DLLs and assets
   └─ Generate installer

4. ✅ Output
   └─ Installer saved to: Output\
```

### Build Requirements

**Minimum:**
- Windows 10 or later
- Flutter SDK 3.0+
- Visual Studio 2022 Build Tools
- 5 GB free disk space

**For Inno Setup:**
- Inno Setup 6 ([Download](https://jrsoftware.org/isdl.php))

**For NSIS:**
- NSIS 3.0+ ([Download](https://nsis.sourceforge.io/Download))

### Build Time Estimates

| Step | Time | Can Skip? |
|------|------|-----------|
| Flutter Clean | 5s | Yes* |
| Flutter Pub Get | 10-30s | No |
| Flutter Build | 2-5 min | Yes* |
| Create Installer | 30s-2min | No |
| **Total** | **3-8 min** | |

*Use `-SkipBuild` if already built

---

## 🎨 Customization

### Change App Name

**In `installer_script.iss`:**
```iss
#define MyAppName "Your App Name"
```

**In `installer_script.nsi`:**
```nsi
!define APP_NAME "Your App Name"
```

**In `pubspec.yaml`:**
```yaml
msix_config:
  display_name: Your App Name
```

### Change Version Number

**In `pubspec.yaml`:**
```yaml
version: 1.0.0+1
```

**In `installer_script.iss`:**
```iss
#define MyAppVersion "1.0.0"
```

**In `installer_script.nsi`:**
```nsi
!define APP_VERSION "1.0.0"
```

### Change Company Name

**In `installer_script.iss`:**
```iss
#define MyAppPublisher "Your Company"
```

**In `windows\runner\Runner.rc`:**
```c
VALUE "CompanyName", "Your Company" "\0"
```

### Change App Icon

Replace: `windows\runner\resources\app_icon.ico`

**Requirements:**
- Format: .ico file
- Sizes: 16x16, 32x32, 48x48, 256x256
- Tool: Use https://icoconvert.com/

### Add Custom Files to Installer

**In `installer_script.iss`:**
```iss
[Files]
Source: "your_file.txt"; DestDir: "{app}"; Flags: ignoreversion
```

### Add Desktop Shortcut (Always)

**In `installer_script.iss`:**
```iss
[Icons]
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: ; Flags:
```

Remove `Tasks: desktopicon` to make it always create.

---

## 📤 Distribution

### For Testing / Internal Use

1. **Build the installer** using any method
2. **Share the file** from the `Output` folder
3. **Test** on a clean Windows machine

**Note:** Windows SmartScreen will show a warning. Users can click:
- "More info" → "Run anyway"

This is **normal** for unsigned applications.

### For Production / Public Distribution

#### Step 1: Get a Code Signing Certificate

**Vendors:**
- DigiCert (Recommended): ~$500/year
- Sectigo: ~$400/year
- GlobalSign: ~$450/year

**Benefits:**
- ✅ No SmartScreen warning
- ✅ Users trust the installer
- ✅ Professional appearance

#### Step 2: Sign the Executable

```powershell
# Sign the main .exe
signtool sign /f certificate.pfx /p password /tr http://timestamp.digicert.com /td sha256 /fd sha256 build\windows\x64\runner\Release\mitugym_scanner_flutter.exe

# Sign the installer
signtool sign /f certificate.pfx /p password /tr http://timestamp.digicert.com /td sha256 /fd sha256 Output\MituGymScanner_Setup_1.0.0.exe
```

#### Step 3: Distribute

**Options:**
- 📧 **Email** - Direct to users
- 🌐 **Website** - Download link
- 💿 **USB Drive** - Physical distribution
- 🏪 **Microsoft Store** - Use MSIX method

### Microsoft Store Submission (MSIX)

1. Create a Microsoft Developer account ($19 one-time)
2. Build with store configuration:
   ```yaml
   msix_config:
     store: true
     publisher: CN=YOUR_PUBLISHER_ID
   ```
3. Generate MSIX package
4. Upload to Partner Center
5. Complete store listing

**Benefits:**
- ✅ Automatic updates
- ✅ Trusted by default
- ✅ Easy distribution

---

## 🐛 Troubleshooting

### Common Issues

#### Flutter Build Fails

**Error:** `Exception: Unable to generate build files`

**Solution:**
```powershell
flutter clean
flutter pub get
flutter doctor -v
flutter build windows --release
```

#### Inno Setup Not Found

**Error:** `Inno Setup not found at expected location`

**Solution:**
1. Download from https://jrsoftware.org/isdl.php
2. Install to default location
3. Or update path in `build_installer.ps1`

#### Missing DLL Errors

**Error:** `The code execution cannot proceed because XXX.dll was not found`

**Solution:**
- Install Visual C++ Redistributable 2015-2022
- Download: https://aka.ms/vs/17/release/vc_redist.x64.exe

#### App Won't Start After Installation

**Possible causes:**
1. Missing dependencies (DLLs)
2. Incorrect build configuration
3. Assets not packaged

**Solution:**
```powershell
# Rebuild with verbose output
flutter build windows --release --verbose

# Check build output contains all files
dir build\windows\x64\runner\Release
```

#### SmartScreen Blocks Installer

**This is normal!** 

**For users:**
- Click "More info"
- Click "Run anyway"

**For developers:**
- Get a code signing certificate
- Sign your installer

#### MSIX Installation Fails

**Error:** `App installation failed with error message: Cannot install...`

**Solution:**
1. Check if developer mode is enabled (Windows Settings → For developers)
2. Or: Sign the MSIX with a trusted certificate
3. Or: Use traditional installer (Inno Setup)

### Debug Mode

Run with verbose output:

```powershell
# PowerShell with detailed output
.\build_installer.ps1 -Verbose

# Flutter with debug info
flutter build windows --release --verbose
```

### Get Help

1. **Check logs** in console output
2. **Run diagnostics:**
   ```powershell
   flutter doctor -v
   ```
3. **Verify build exists:**
   ```powershell
   dir build\windows\x64\runner\Release
   ```
4. **Test on clean machine** (important!)

---

## 📊 Installer Comparison

### Quick Comparison

| Feature | MSIX | Inno Setup | NSIS |
|---------|------|------------|------|
| **Setup Time** | 5 min ⚡ | 10 min | 15 min |
| **Build Time** | Fast ⚡ | Medium | Medium |
| **File Size** | Medium | Small ⚡ | Small ⚡ |
| **Professional Look** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Windows 7** | ❌ | ✅ | ✅ |
| **Windows 10+** | ✅ | ✅ | ✅ |
| **Store Compatible** | ✅ | ❌ | ❌ |
| **Auto Updates** | ✅ | ❌* | ❌* |
| **Custom UI** | Limited | Full | Full |
| **Cert Required** | Yes† | Optional | Optional |
| **Ease of Use** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |

*Can be added with additional code  
†Required for public distribution

### When to Use Each

#### Use MSIX When:
- ✅ Targeting Windows 10+ only
- ✅ Distributing via Microsoft Store
- ✅ Want automatic updates
- ✅ Need quick testing builds

#### Use Inno Setup When:
- ✅ Need Windows 7+ support ⚡
- ✅ Want professional installer ⚡
- ✅ Distributing directly to users ⚡
- ✅ Need full customization
- ✅ **This is recommended for most cases**

#### Use NSIS When:
- ✅ Need maximum customization
- ✅ Want advanced scripting
- ✅ Already familiar with NSIS
- ✅ Need specific features not in Inno

---

## 🎯 Best Practices

### Before Building

- ✅ Test your app thoroughly
- ✅ Update version number in pubspec.yaml
- ✅ Clean build: `flutter clean`
- ✅ Check all assets are included
- ✅ Test on a clean Windows VM

### During Building

- ✅ Use release mode (not debug)
- ✅ Include all required DLLs
- ✅ Package the `data` folder
- ✅ Verify icon displays correctly

### After Building

- ✅ Test installer on clean machine
- ✅ Verify app launches correctly
- ✅ Check all features work
- ✅ Test uninstaller
- ✅ Scan with antivirus

### For Distribution

- ✅ Sign with code certificate (production)
- ✅ Test on multiple Windows versions
- ✅ Provide clear installation instructions
- ✅ Include system requirements
- ✅ Set up support channel

---

## 📝 Checklist

### Pre-Release Checklist

```
Before creating installer:
□ App version updated in pubspec.yaml
□ All features tested and working
□ No debug code or console logs left
□ Assets and images included
□ Icon file is correct (.ico format)
□ Tested on clean Windows installation
□ Release notes prepared

During installer creation:
□ Chose appropriate installer type
□ Custom company name and info set
□ Build completed without errors
□ Installer file created successfully
□ File size is reasonable

Post-installer testing:
□ Tested installation on clean machine
□ App launches successfully
□ All features work correctly
□ Shortcuts created properly
□ Uninstaller works correctly
□ No leftover files after uninstall

Before distribution:
□ Installer signed (if code certificate available)
□ Tested by multiple users
□ Installation instructions prepared
□ Support contact information included
□ Download location secured
```

---

## 📚 Additional Resources

### Official Documentation
- [Flutter Windows](https://docs.flutter.dev/platform-integration/windows/building)
- [Inno Setup](https://jrsoftware.org/ishelp/)
- [NSIS](https://nsis.sourceforge.io/Docs/)
- [MSIX Packaging](https://docs.microsoft.com/en-us/windows/msix/)

### Tools
- [Inno Setup](https://jrsoftware.org/isdl.php) - Professional installer creator
- [NSIS](https://nsis.sourceforge.io/Download) - Scriptable installer system
- [ICO Converter](https://icoconvert.com/) - Create .ico files
- [SignTool](https://docs.microsoft.com/en-us/windows/win32/seccrypto/signtool) - Code signing utility

### Testing
- [Windows 10 VM](https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/) - Free VMs for testing
- [VirusTotal](https://www.virustotal.com/) - Scan your installer
- [Windows App Certification Kit](https://developer.microsoft.com/en-us/windows/develop/app-certification-kit) - Verify compatibility

---

## 📞 Support

### If you need help:

1. **Check this documentation** thoroughly
2. **Review error messages** carefully
3. **Test on a clean Windows machine**
4. **Check Flutter doctor**: `flutter doctor -v`
5. **Verify build exists**: Check `build\windows\x64\runner\Release\`

### Common Commands Reference

```powershell
# Flutter diagnostics
flutter doctor -v

# Clean rebuild
flutter clean && flutter pub get && flutter build windows --release

# Quick MSIX
flutter pub run msix:create

# PowerShell script
.\build_installer.ps1 -InstallerType inno

# Check build output
dir build\windows\x64\runner\Release
```

---

## 🎉 Success!

You now have everything you need to create professional Windows installers for your Flutter application!

**Recommended workflow:**
1. **Development:** Use MSIX for quick testing
2. **Production:** Use Inno Setup for distribution
3. **Store:** Use signed MSIX for Microsoft Store

**Need to start?** Just double-click `build_installer.bat`! 🚀

---

*Last updated: 2025*  
*MituGym Scanner - Professional Windows Installer System*

