# MituGym Scanner - Windows Installer Guide

This guide will help you create a professional Windows installer for your Flutter application.

## Prerequisites

1. Build your Flutter Windows app in release mode:
```powershell
flutter build windows --release
```

The built app will be in: `build\windows\x64\runner\Release\`

---

## Option 1: MSIX Installer (Easiest - Microsoft Store Compatible)

### Step 1: Add MSIX Package Dependency

Add to `pubspec.yaml` under `dev_dependencies`:

```yaml
dev_dependencies:
  msix: ^3.16.7
```

Then run:
```powershell
flutter pub get
```

### Step 2: Configure MSIX

Add this configuration at the end of your `pubspec.yaml`:

```yaml
msix_config:
  display_name: MituGym Scanner
  publisher_display_name: MituGym
  identity_name: com.mitugym.scanner
  msix_version: 1.0.0.0
  logo_path: assets\images\logo.png
  capabilities: internetClient, location
  store: false
```

### Step 3: Create MSIX Package

```powershell
flutter pub run msix:create
```

The `.msix` file will be created in `build\windows\x64\runner\Release\`

### Step 4: Install

Double-click the `.msix` file to install on Windows 10/11.

**Pros:**
- ✅ Easy to create
- ✅ One command setup
- ✅ Microsoft Store compatible
- ✅ Automatic updates support

**Cons:**
- ❌ Requires certificate for distribution
- ❌ Only works on Windows 10+

---

## Option 2: Inno Setup (Traditional .exe Installer - RECOMMENDED)

### Step 1: Download Inno Setup

Download and install from: https://jrsoftware.org/isdl.php

### Step 2: Use the Script

I've created `installer_script.iss` for you. See that file for the complete configuration.

### Step 3: Build the Installer

1. Open Inno Setup Compiler
2. Open the `installer_script.iss` file
3. Click "Build" > "Compile"
4. The installer will be created in the `Output` folder

**Or use command line:**
```powershell
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer_script.iss
```

**Pros:**
- ✅ Works on all Windows versions (7+)
- ✅ Professional installer with wizard
- ✅ Custom install locations
- ✅ Start Menu shortcuts
- ✅ Uninstaller included
- ✅ No certificate required for testing

**Cons:**
- ❌ Requires Inno Setup installation
- ❌ More manual configuration

---

## Option 3: NSIS (Alternative Traditional Installer)

If you prefer NSIS instead of Inno Setup:

1. Download NSIS: https://nsis.sourceforge.io/Download
2. Use `installer_script.nsi` (see that file)
3. Right-click the script and select "Compile NSIS Script"

---

## Recommended Workflow

### For Development/Testing:
Use **MSIX** - quick and easy for internal testing

### For Production/Distribution:
Use **Inno Setup** - professional, works everywhere, no certificate needed

---

## Building Steps

### Complete build process:

```powershell
# 1. Clean previous builds
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Build Windows release
flutter build windows --release

# 4a. For MSIX:
flutter pub run msix:create

# 4b. For Inno Setup:
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer_script.iss
```

---

## File Structure After Build

```
build\windows\x64\runner\Release\
├── mitugym_scanner_flutter.exe  (main executable)
├── flutter_windows.dll
├── data\                         (Flutter assets)
├── *.dll files                   (dependencies)
└── ... (other runtime files)
```

All these files need to be included in the installer.

---

## Troubleshooting

### Issue: "App won't start after installation"
**Solution:** Make sure all DLL files and the `data` folder are included

### Issue: "Windows SmartScreen blocks installation"
**Solution:** 
- For testing: Click "More info" → "Run anyway"
- For production: Sign the installer with a code signing certificate

### Issue: "Missing vcruntime140.dll"
**Solution:** Include Visual C++ Redistributable in the installer (already in Inno script)

---

## Code Signing (Optional but Recommended for Production)

To remove SmartScreen warnings:

1. Purchase a code signing certificate (DigiCert, Sectigo, etc.)
2. Sign your executable:
```powershell
signtool sign /f certificate.pfx /p password /t http://timestamp.digicert.com mitugym_scanner_flutter.exe
```

---

## Questions?

- MSIX Issues: Check Flutter MSIX package docs
- Inno Setup Issues: Check Inno Setup documentation
- Build Issues: Run `flutter doctor -v`

