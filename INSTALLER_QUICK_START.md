# Quick Start - Create Windows Installer

## 🚀 Fastest Method (Automated Script)

### Option 1: Using PowerShell Script (RECOMMENDED)

```powershell
# For Inno Setup installer (recommended)
.\build_installer.ps1 -InstallerType inno

# For MSIX package
.\build_installer.ps1 -InstallerType msix

# For all types
.\build_installer.ps1 -InstallerType all
```

**That's it!** The script will:
- ✅ Build your Flutter app
- ✅ Create the installer
- ✅ Put everything in the `Output` folder

---

## 🎯 Manual Methods

### Method 1: MSIX (Easiest)

```powershell
# 1. Add MSIX to your project
flutter pub add msix --dev

# 2. Build release
flutter build windows --release

# 3. Create MSIX
flutter pub run msix:create
```

**Output:** `build\windows\x64\runner\Release\*.msix`

### Method 2: Inno Setup (Professional)

1. **Download Inno Setup:** https://jrsoftware.org/isdl.php
2. **Build app:**
   ```powershell
   flutter build windows --release
   ```
3. **Open Inno Setup Compiler**
4. **Open:** `installer_script.iss`
5. **Click:** Build → Compile

**Output:** `Output\MituGymScanner_Setup_1.0.0.exe`

---

## 📋 Requirements

### For MSIX:
- ✅ Windows 10/11
- ✅ Flutter SDK

### For Inno Setup:
- ✅ Inno Setup 6 ([Download](https://jrsoftware.org/isdl.php))
- ✅ Flutter SDK

### For NSIS:
- ✅ NSIS ([Download](https://nsis.sourceforge.io/Download))
- ✅ Flutter SDK

---

## 🎨 Customization

### Change App Name/Version

Edit these files:
- **Inno Setup:** `installer_script.iss` (lines 5-9)
- **NSIS:** `installer_script.nsi` (lines 4-7)
- **MSIX:** Add config to `pubspec.yaml`

### Change Icon

Replace: `windows\runner\resources\app_icon.ico`

---

## 📁 Output Locations

| Method | Output Location |
|--------|----------------|
| MSIX | `build\windows\x64\runner\Release\*.msix` |
| Inno Setup | `Output\MituGymScanner_Setup_*.exe` |
| NSIS | `Output\MituGymScanner_Setup_*.exe` |

---

## 🐛 Common Issues

### "Flutter not found"
```powershell
# Add Flutter to PATH or use full path
C:\path\to\flutter\bin\flutter build windows --release
```

### "Inno Setup not found"
Download from: https://jrsoftware.org/isdl.php

### "Build failed"
```powershell
# Clean and rebuild
flutter clean
flutter pub get
flutter build windows --release
```

### "SmartScreen blocks installer"
**Normal behavior!** Users can click "More info" → "Run anyway"

For production: Get a code signing certificate

---

## 📊 Comparison

| Feature | MSIX | Inno Setup | NSIS |
|---------|------|------------|------|
| **Ease of Use** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Setup Time** | 5 min | 10 min | 15 min |
| **Professional Look** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Customization** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Windows 7 Support** | ❌ | ✅ | ✅ |
| **Store Compatible** | ✅ | ❌ | ❌ |
| **Code Signing Needed** | Yes* | Optional | Optional |

*Required for public distribution

---

## 🎯 Recommendation

### For Quick Testing:
**Use MSIX** - One command, quick results

### For Production/Distribution:
**Use Inno Setup** - Professional, reliable, works everywhere

### For Maximum Control:
**Use NSIS** - Highly customizable, advanced features

---

## 📞 Need Help?

1. Check `INSTALLER_GUIDE.md` for detailed instructions
2. Review error messages in console
3. Run `flutter doctor -v` for Flutter issues

---

## 🚀 Quick Commands Cheat Sheet

```powershell
# Clean build
flutter clean && flutter pub get && flutter build windows --release

# MSIX
flutter pub add msix --dev && flutter pub run msix:create

# Inno Setup (if installed)
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer_script.iss

# NSIS (if installed)
"C:\Program Files (x86)\NSIS\makensis.exe" installer_script.nsi

# Automated (recommended)
.\build_installer.ps1 -InstallerType inno
```

---

**Ready to build?** Run the PowerShell script and you're done! 🎉

