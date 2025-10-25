# USB Scanner Quick Start

Get your USB scanner system up and running in 5 minutes!

## 🚀 Quick Setup (No Hardware Required)

### Step 1: Start the Daemon (1 minute)

Open a terminal and run:

```batch
cd /d C:\path\to\your\project
tools\start_usb_daemon.bat
```

You should see:
```
═══════════════════════════════════════════════════════════
USB Scanner Daemon Started
═══════════════════════════════════════════════════════════
Mode: MOCK (Testing)
Listening on: localhost:9876
```

✅ Keep this terminal open!

### Step 2: Run Your Flutter App (1 minute)

In a **new terminal**:

```batch
flutter run -d windows
```

### Step 3: Enable USB Scanner Mode (30 seconds)

In your app's settings:
- Enable "Use USB Scanner"
- Set mode to "Mock"
- Save settings

Or in code:
```dart
// Add this to your scanner initialization
await ref.read(usbScannerControllerProvider.notifier).initialize(
  mode: UsbScannerMode.mock,
);
await ref.read(usbScannerControllerProvider.notifier).startScanner();
```

### Step 4: Test It! (1 minute)

In a **third terminal**, send a test scan:

```batch
tools\test_usb_scan.bat MEMBER12345
```

You should see the scan processed in your app! 🎉

---

## 🎯 Testing Tips

### Send Multiple Scans

```batch
REM Scan member 1
tools\test_usb_scan.bat MEMBER001

REM Wait for debounce (6 seconds)
timeout /t 6 /nobreak > nul

REM Scan member 2
tools\test_usb_scan.bat MEMBER002
```

### Using PowerShell (More Features)

```powershell
# Single scan
.\tools\usb_scanner_test.ps1 scan TESTCODE123

# Multiple scans with automatic delays
.\tools\usb_scanner_test.ps1 multi

# Stress test (10 rapid scans)
.\tools\usb_scanner_test.ps1 stress 10
```

---

## 🔌 When You Get the Physical Scanner

### Step 1: Update Daemon Code

Open `lib/services/usb_scanner_daemon.dart` and find the `_startUsbPolling()` method around line 140. Follow the TODO comments to implement USB HID reading.

### Step 2: Start Daemon in Real Mode

```batch
dart run lib/services/usb_scanner_daemon.dart --real
```

### Step 3: Update App Settings

Change mode from "mock" to "real":
```dart
config.copyWith(usbScannerMode: 'real')
```

### Step 4: Test with Real Scanner

Just scan a QR code with your USB scanner!

---

## 📋 Common Commands Cheat Sheet

| Action | Command |
|--------|---------|
| Start daemon | `tools\start_usb_daemon.bat` |
| Test scan | `tools\test_usb_scan.bat <CODE>` |
| Stop daemon | Press `Ctrl+C` in daemon terminal |
| Check if daemon is running | `netstat -ano \| findstr :9876` |

---

## ❓ Something Not Working?

### Daemon won't start
- **Port in use?** Try: `netstat -ano | findstr :9876`
- **Solution:** Kill the process or use different port

### Can't connect to daemon
- ✅ Is daemon running? Check the terminal
- ✅ Is firewall blocking? Allow port 9876
- ✅ Correct port? Default is 9876

### Scans not received
- ✅ Did you call `startScanner()`?
- ✅ Is `isConnected = true`?
- ✅ Does test client work? Try: `tools\test_usb_scan.bat TEST`

---

## 📖 Full Documentation

For complete details, see [USB_SCANNER_GUIDE.md](./USB_SCANNER_GUIDE.md)

---

## 🎉 You're All Set!

Your USB scanner system is now ready. You can:
- ✅ Develop without physical hardware
- ✅ Test with simulated scans
- ✅ Easily integrate real scanner later
- ✅ Switch between camera and USB scanning

**Happy scanning! 🔥**
