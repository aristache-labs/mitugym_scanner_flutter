# USB Scanner Integration Guide

This guide explains how to use the USB scanner system in your gym management application. The system is designed to work with external USB barcode/QR scanners and includes a complete testing framework so you can develop and test without the physical hardware.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Testing Without Hardware](#testing-without-hardware)
- [Integration with Physical Scanner](#integration-with-physical-scanner)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

The USB scanner system consists of:

1. **USB Scanner Service** - Core service that communicates with the daemon
2. **USB Scanner Daemon** - Background service that listens for USB scanner input
3. **Mock USB Scanner** - Testing service that simulates USB input without hardware
4. **Test Utilities** - Tools to simulate scans during development

### Key Features

- ✅ Works with USB HID barcode/QR scanners
- ✅ Background daemon architecture for reliable scanning
- ✅ Complete mock mode for testing without hardware
- ✅ Automatic reconnection and error recovery
- ✅ Debouncing to prevent duplicate scans
- ✅ Easy integration with existing camera-based scanning

---

## 🏗️ Architecture

```
┌─────────────────────┐
│   Flutter App       │
│  (Main Process)     │
└──────────┬──────────┘
           │ TCP Socket (Port 9876)
           │
┌──────────▼──────────┐
│  USB Scanner Daemon │
│  (Background)       │
└──────────┬──────────┘
           │
    ┌──────┴──────┐
    │             │
    ▼             ▼
┌─────────┐  ┌─────────────┐
│  Real   │  │    Mock     │
│  USB    │  │   Input     │
│ Scanner │  │ (Port 9877) │
└─────────┘  └─────────────┘
```

### Communication Protocol

The daemon and Flutter app communicate via TCP socket using simple text commands:

**Client → Daemon:**
- `HELLO` - Initial handshake
- `START_SCAN` - Enable scanning
- `STOP_SCAN` - Disable scanning
- `PING` - Keep-alive heartbeat
- `BYE` - Disconnect

**Daemon → Client:**
- `SCAN:<code>` - Scanned QR/barcode data
- `PONG` - Heartbeat response
- `OK:<message>` - Command acknowledged
- `ERROR:<message>` - Error occurred

---

## 🚀 Getting Started

### Step 1: Start the Daemon

The daemon must be running before your Flutter app can use the USB scanner.

**Option A: Using Batch Script (Easiest)**
```batch
cd /d C:\path\to\your\project
tools\start_usb_daemon.bat
```

**Option B: Using PowerShell**
```powershell
cd C:\path\to\your\project
.\tools\usb_scanner_test.ps1 daemon
```

**Option C: Using Dart Directly**
```batch
dart run lib/services/usb_scanner_daemon.dart
```

You should see:
```
═══════════════════════════════════════════════════════════
USB Scanner Daemon Started
═══════════════════════════════════════════════════════════
Mode: MOCK (Testing)
Listening on: localhost:9876
Mock input on: localhost:9877
...
[HH:MM:SS] Daemon ready and waiting for connections...
```

### Step 2: Configure Your App

Update your app settings to enable USB scanner mode:

```dart
// In your settings screen or config
final config = ref.read(configProvider);
await ref.read(configProvider.notifier).updateConfig(
  config.copyWith(
    useUsbScanner: true,
    usbScannerMode: 'mock', // Use 'real' when you have the hardware
  ),
);
```

### Step 3: Initialize USB Scanner

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/usb_scanner_provider.dart';

// In your scanner screen or widget
class ScannerScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usbScanner = ref.watch(usbScannerControllerProvider);
    
    return Column(
      children: [
        Text('Status: ${usbScanner.connectionStatus}'),
        
        ElevatedButton(
          onPressed: () async {
            // Initialize and start scanning
            await ref.read(usbScannerControllerProvider.notifier).initialize(
              mode: UsbScannerMode.mock, // or UsbScannerMode.real
            );
            await ref.read(usbScannerControllerProvider.notifier).connect();
            await ref.read(usbScannerControllerProvider.notifier).startScanner();
          },
          child: Text('Start USB Scanner'),
        ),
        
        ElevatedButton(
          onPressed: () async {
            await ref.read(usbScannerControllerProvider.notifier).stopScanner();
          },
          child: Text('Stop Scanner'),
        ),
      ],
    );
  }
}
```

---

## 🧪 Testing Without Hardware

### Method 1: Using the Test Client (Recommended)

**Batch Script:**
```batch
tools\test_usb_scan.bat MEMBER12345
```

**PowerShell:**
```powershell
# Single scan
.\tools\usb_scanner_test.ps1 scan MEMBER12345

# Multiple scans with debounce delay
.\tools\usb_scanner_test.ps1 multi

# Stress test (sends 10 scans rapidly)
.\tools\usb_scanner_test.ps1 stress 10
```

**Dart:**
```batch
dart run tools/usb_scanner_test_client.dart MEMBER12345
```

### Method 2: Using PowerShell Directly

```powershell
$client = New-Object System.Net.Sockets.TcpClient("localhost", 9877)
$stream = $client.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)
$writer.WriteLine("SCAN:MEMBER12345")
$writer.Flush()
$client.Close()
```

### Method 3: Using Mock Service in App

If using `MockUsbScannerService` mode:

```dart
// In your UI (e.g., debug panel or test button)
ref.read(usbScannerControllerProvider.notifier).simulateScan('MEMBER12345');
```

### Testing Workflow

1. **Start the daemon** - Keep it running in a separate terminal
2. **Start your Flutter app** - Configure it for USB scanner mode
3. **Send test scans** - Use any of the methods above
4. **Verify behavior** - Check that scans are processed correctly

**Example Testing Session:**
```batch
REM Terminal 1: Start daemon
tools\start_usb_daemon.bat

REM Terminal 2: Run your Flutter app
flutter run -d windows

REM Terminal 3: Send test scans
tools\test_usb_scan.bat MEMBER001
timeout /t 6 /nobreak > nul
tools\test_usb_scan.bat MEMBER002
timeout /t 6 /nobreak > nul
tools\test_usb_scan.bat MEMBER003
```

---

## 🔌 Integration with Physical Scanner

### When You Get the Hardware

Once you receive your USB scanner, follow these steps:

#### 1. Identify Scanner Type

USB scanners typically work in one of two modes:

**HID Keyboard Mode (Most Common)**
- Scanner appears as a keyboard device
- Types the barcode/QR data + Enter key
- No drivers needed (plug and play)

**Serial/COM Port Mode**
- Scanner creates a virtual COM port
- Sends data via serial communication
- May require drivers

#### 2. Update the Daemon Code

Open `lib/services/usb_scanner_daemon.dart` and find the `_startUsbPolling()` method. This is where you'll implement the hardware integration:

```dart
Future<void> _startUsbPolling() async {
  // For HID Keyboard Mode:
  // The scanner will send keyboard events to the OS
  // You can use raw keyboard input capture or stdin
  
  // Example for capturing stdin (if scanner sends to console):
  stdin.lineMode = false;
  stdin.listen((data) {
    final scanData = String.fromCharCodes(data).trim();
    if (scanData.isNotEmpty) {
      _broadcastToClients('SCAN:$scanData');
    }
  });
  
  // For Serial/COM Port Mode:
  // Use the 'flutter_libserialport' package
  // 
  // 1. Add to pubspec.yaml:
  //    flutter_libserialport: ^0.3.0
  // 
  // 2. Implement serial reading:
  /*
  final port = SerialPort('COM3'); // Your scanner's COM port
  if (!port.openReadWrite()) {
    print('Failed to open port');
    return;
  }
  
  final reader = SerialPortReader(port);
  reader.stream.listen((data) {
    final scanData = String.fromCharCodes(data).trim();
    if (scanData.isNotEmpty && scanData.endsWith('\n')) {
      _broadcastToClients('SCAN:${scanData.trim()}');
    }
  });
  */
}
```

#### 3. Test with Real Hardware

1. Connect your USB scanner
2. Start the daemon in **real mode**:
   ```batch
   dart run lib/services/usb_scanner_daemon.dart --real
   ```
3. Configure your app for real mode:
   ```dart
   config.copyWith(usbScannerMode: 'real')
   ```
4. Start your app and test scanning

#### 4. Common Scanner Configuration

Most USB scanners can be configured via special barcodes (check your scanner's manual):

- **Suffix**: Set to `\r\n` (CR+LF) or `\n` (LF)
- **Prefix**: Usually none needed
- **Mode**: USB HID Keyboard (most compatible)
- **Beep**: Enable for feedback
- **LED**: Enable for visual confirmation

---

## ⚙️ Configuration

### App Configuration

```dart
AppConfig(
  // Enable USB scanner
  useUsbScanner: true,
  
  // Scanner mode: 'mock' or 'real'
  usbScannerMode: 'mock',
  
  // Daemon connection
  usbScannerHost: 'localhost',
  usbScannerPort: 9876,
  
  // Scan debounce (seconds)
  debounceDuration: 5,
)
```

### Daemon Configuration

```batch
REM Run in mock mode (default)
dart run lib/services/usb_scanner_daemon.dart

REM Run in real USB mode
dart run lib/services/usb_scanner_daemon.dart --real

REM Custom ports
dart run lib/services/usb_scanner_daemon.dart --port 8888 --mock-port 8889
```

### Environment Variables

You can also use environment variables:

```batch
set USB_SCANNER_PORT=9876
set USB_SCANNER_MOCK_PORT=9877
dart run lib/services/usb_scanner_daemon.dart
```

---

## 🔧 Troubleshooting

### Daemon Won't Start

**Problem:** Port already in use
```
ERROR: Failed to start daemon: SocketException: Address already in use
```

**Solution:**
1. Check if another instance is running:
   ```powershell
   netstat -ano | findstr :9876
   ```
2. Kill the process or use a different port:
   ```batch
   dart run lib/services/usb_scanner_daemon.dart --port 9999
   ```

### App Can't Connect to Daemon

**Problem:** Connection refused or timeout

**Solutions:**
1. **Ensure daemon is running** - Check the daemon terminal
2. **Check firewall** - Allow connections on port 9876
3. **Verify port** - Make sure app and daemon use same port
4. **Check host** - Use `localhost` or `127.0.0.1`

### Scans Not Being Received

**Problem:** Daemon runs but app doesn't receive scans

**Checklist:**
- [ ] Daemon is in correct mode (mock/real)
- [ ] Scanner is started in app (`startScanner()` called)
- [ ] Connection is established (`isConnected = true`)
- [ ] Test client works (proves daemon is functioning)
- [ ] Check app logs for errors

### Duplicate Scans

**Problem:** Same code scanned multiple times quickly

**Solution:**
- Increase debounce duration:
  ```dart
  config.copyWith(debounceDuration: 10) // 10 seconds
  ```

### Physical Scanner Not Working

**Problem:** Real USB scanner doesn't send data to daemon

**Checklist:**
- [ ] Scanner is plugged in and powered
- [ ] Scanner beeps/lights up when scanning
- [ ] Scanner is in correct mode (HID keyboard recommended)
- [ ] Daemon is in real mode (`--real` flag)
- [ ] Scanner configuration is correct (check manual)
- [ ] Test scanner in notepad first (HID mode)

---

## 📝 Example Workflow

### Development Phase (No Hardware)

```batch
REM 1. Start daemon in mock mode
start cmd /k "tools\start_usb_daemon.bat"

REM 2. Start Flutter app
flutter run -d windows

REM 3. In app: Enable USB scanner (mock mode)

REM 4. Send test scans
tools\test_usb_scan.bat MEMBER001
timeout /t 6
tools\test_usb_scan.bat MEMBER002
```

### Production Phase (With Hardware)

```batch
REM 1. Start daemon in real mode
start cmd /k "dart run lib/services/usb_scanner_daemon.dart --real"

REM 2. Start Flutter app
flutter run -d windows --release

REM 3. In app: Enable USB scanner (real mode)

REM 4. Scan with physical device
REM (Scanner will automatically send data to daemon)
```

---

## 🎓 Advanced Usage

### Running Daemon as Windows Service

For production deployment, you can run the daemon as a Windows service:

```batch
REM Build daemon executable
dart compile exe lib/services/usb_scanner_daemon.dart -o usb_scanner_daemon.exe

REM Install as service using NSSM or sc.exe
sc create UsbScannerDaemon binPath= "C:\path\to\usb_scanner_daemon.exe"
sc start UsbScannerDaemon
```

### Custom Protocol

You can extend the protocol by modifying the daemon's `_handleClientData()` method:

```dart
case 'GET_STATUS':
  _sendToClient(client, 'STATUS:active=$_isActive,clients=${_clients.length}');
  break;
```

### Multiple Scanners

To support multiple USB scanners simultaneously:

1. Run multiple daemon instances on different ports
2. Configure each scanner to connect to a different daemon
3. Merge scan streams in your app

---

## 📚 Additional Resources

- **Flutter Documentation**: https://flutter.dev
- **Dart Sockets**: https://api.dart.dev/stable/dart-io/Socket-class.html
- **USB HID Specification**: https://www.usb.org/hid
- **Serial Port Library**: https://pub.dev/packages/flutter_libserialport

---

## 🤝 Support

If you encounter issues not covered in this guide:

1. Check daemon logs for errors
2. Test with the provided test utilities
3. Verify your scanner works in other applications
4. Check the scanner's manual for configuration

---

## 📄 License

This USB scanner system is part of your gym management application.
