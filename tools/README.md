# USB Scanner Testing Tools

This directory contains utilities for testing the USB scanner system without physical hardware.

## 📁 Files

### Windows Batch Scripts

- **`start_usb_daemon.bat`** - Start the USB scanner daemon in mock mode
- **`test_usb_scan.bat`** - Send a single test scan to the daemon

### PowerShell Script

- **`usb_scanner_test.ps1`** - Advanced testing utility with multiple features

### Dart Test Client

- **`usb_scanner_test_client.dart`** - Cross-platform test client for sending simulated scans

## 🚀 Quick Start

### 1. Start the Daemon

**Windows (Batch):**
```batch
start_usb_daemon.bat
```

**Windows (PowerShell):**
```powershell
.\usb_scanner_test.ps1 daemon
```

**Cross-platform (Dart):**
```batch
dart run lib/services/usb_scanner_daemon.dart
```

### 2. Send Test Scans

**Windows (Batch):**
```batch
test_usb_scan.bat MEMBER12345
```

**Windows (PowerShell):**
```powershell
# Single scan
.\usb_scanner_test.ps1 scan MEMBER12345

# Multiple scans with delays
.\usb_scanner_test.ps1 multi

# Stress test (10 scans)
.\usb_scanner_test.ps1 stress 10
```

**Cross-platform (Dart):**
```batch
dart run tools/usb_scanner_test_client.dart MEMBER12345
```

## 💡 Usage Examples

### Basic Testing Workflow

```batch
REM Terminal 1: Start daemon
start_usb_daemon.bat

REM Terminal 2: Run your app
flutter run -d windows

REM Terminal 3: Send test scans
test_usb_scan.bat MEMBER001
timeout /t 6 > nul
test_usb_scan.bat MEMBER002
```

### PowerShell Advanced Testing

```powershell
# Start daemon in background
Start-Process powershell -ArgumentList "-NoExit", "-Command", ".\usb_scanner_test.ps1 daemon"

# Wait for daemon to start
Start-Sleep -Seconds 2

# Send test scans
.\usb_scanner_test.ps1 scan TEST001
Start-Sleep -Seconds 6
.\usb_scanner_test.ps1 scan TEST002
Start-Sleep -Seconds 6
.\usb_scanner_test.ps1 scan TEST003

# Or use multi-scan
.\usb_scanner_test.ps1 multi
```

### Stress Testing

```powershell
# Send 20 scans rapidly (tests debouncing)
.\usb_scanner_test.ps1 stress 20
```

## 🔧 Troubleshooting

### Daemon Won't Start

**Error:** Port already in use

**Check:**
```batch
netstat -ano | findstr :9876
```

**Solution:**
```batch
REM Kill the process using the port, or use a different port
dart run lib/services/usb_scanner_daemon.dart --port 9999
```

### Test Client Can't Connect

**Error:** Connection refused

**Checklist:**
1. ✅ Is daemon running?
2. ✅ Using correct port? (default: 9877 for mock input)
3. ✅ Firewall blocking?

### Scans Not Received in App

**Troubleshooting Steps:**
1. Test with the test client first
2. Check if app is connected to daemon
3. Verify app has started scanning
4. Check app logs for errors

## 📝 Command Reference

### Daemon Commands

```batch
REM Start in mock mode (default)
dart run lib/services/usb_scanner_daemon.dart

REM Start in real USB mode
dart run lib/services/usb_scanner_daemon.dart --real

REM Use custom ports
dart run lib/services/usb_scanner_daemon.dart --port 8888 --mock-port 8889

REM Show help
dart run lib/services/usb_scanner_daemon.dart --help
```

### Test Client Commands

```batch
REM Basic usage
dart run tools/usb_scanner_test_client.dart <QR_CODE>

REM With options
dart run tools/usb_scanner_test_client.dart MEMBER123 --host localhost --port 9877

REM Show help
dart run tools/usb_scanner_test_client.dart --help
```

### PowerShell Commands

```powershell
# Get help
.\usb_scanner_test.ps1 help

# Start daemon
.\usb_scanner_test.ps1 daemon

# Send single scan
.\usb_scanner_test.ps1 scan <QR_CODE>

# Multiple scans
.\usb_scanner_test.ps1 multi

# Stress test
.\usb_scanner_test.ps1 stress <COUNT>
```

## 🎯 Testing Scenarios

### Scenario 1: Single Member Check-in

```batch
test_usb_scan.bat MEMBER12345
```

### Scenario 2: Multiple Member Check-ins

```powershell
$members = @("MEMBER001", "MEMBER002", "MEMBER003", "MEMBER004")
foreach ($member in $members) {
    .\usb_scanner_test.ps1 scan $member
    Write-Host "Waiting for debounce..."
    Start-Sleep -Seconds 6
}
```

### Scenario 3: Invalid QR Code

```batch
test_usb_scan.bat INVALID_CODE_12345
```

### Scenario 4: Rapid Scanning (Testing Debounce)

```powershell
# Should only process first scan, rest are debounced
.\usb_scanner_test.ps1 scan MEMBER001
.\usb_scanner_test.ps1 scan MEMBER001
.\usb_scanner_test.ps1 scan MEMBER001
```

### Scenario 5: Different Member Types

```batch
test_usb_scan.bat PREMIUM_MEMBER_001
timeout /t 6 > nul
test_usb_scan.bat BASIC_MEMBER_002
timeout /t 6 > nul
test_usb_scan.bat GUEST_PASS_003
```

## 🔗 Related Documentation

- [USB Scanner Quick Start](../docs/USB_SCANNER_QUICKSTART.md)
- [Complete USB Scanner Guide](../docs/USB_SCANNER_GUIDE.md)
- [Integration Examples](../examples/usb_scanner_integration_example.dart)

## 💻 System Requirements

- Windows 10/11 (for batch/PowerShell scripts)
- Dart SDK 3.0+ / Flutter 3.10+
- Network access to localhost
- Ports 9876 and 9877 available

## 🤝 Contributing

When adding new test utilities:
1. Follow the existing naming convention
2. Add documentation to this README
3. Include error handling
4. Provide usage examples

---

**Happy Testing! 🚀**
