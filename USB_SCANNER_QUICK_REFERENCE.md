# USB Scanner Quick Reference Card

## 🎯 Start Testing in 3 Commands

```batch
REM 1. Start daemon (Terminal 1)
tools\start_usb_daemon.bat

REM 2. Run your app (Terminal 2)
flutter run -d windows

REM 3. Send test scan (Terminal 3)
tools\test_usb_scan.bat MEMBER12345
```

## 📋 Essential Commands

| Task | Command |
|------|---------|
| Start daemon | `tools\start_usb_daemon.bat` |
| Send test scan | `tools\test_usb_scan.bat <CODE>` |
| Multiple scans | `.\tools\usb_scanner_test.ps1 multi` |
| Stop daemon | Press `Ctrl+C` in daemon window |
| Check daemon running | `netstat -ano \| findstr :9876` |

## 🔌 Integration Code

### Initialize USB Scanner
```dart
await ref.read(usbScannerControllerProvider.notifier).initialize(
  mode: UsbScannerMode.mock, // or .real
);
await ref.read(usbScannerControllerProvider.notifier).startScanner();
```

### Stop Scanner
```dart
await ref.read(usbScannerControllerProvider.notifier).stopScanner();
```

### Check Status
```dart
final usbScanner = ref.watch(usbScannerControllerProvider);
print(usbScanner.connectionStatus);
print(usbScanner.isActive);
```

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Port in use | `netstat -ano \| findstr :9876` then kill process |
| Can't connect | Check daemon is running |
| No scans received | Verify `startScanner()` was called |
| Duplicates | Increase `debounceDuration` |

## 📁 Key Files

- **Daemon:** `lib/services/usb_scanner_daemon.dart`
- **Service:** `lib/services/usb_scanner_service.dart`
- **Provider:** `lib/providers/usb_scanner_provider.dart`
- **Config:** `lib/config/app_config.dart`

## 📚 Documentation

- **Quick Start:** `docs/USB_SCANNER_QUICKSTART.md`
- **Full Guide:** `docs/USB_SCANNER_GUIDE.md`
- **Examples:** `examples/usb_scanner_integration_example.dart`
- **Summary:** `USB_SCANNER_IMPLEMENTATION_SUMMARY.md`

## ⚙️ Configuration

```dart
AppConfig(
  useUsbScanner: true,
  usbScannerMode: 'mock', // or 'real'
  usbScannerHost: 'localhost',
  usbScannerPort: 9876,
  debounceDuration: 5,
)
```

## 🔧 When You Get Hardware

1. Update `_startUsbPolling()` in daemon
2. Start daemon with `--real` flag
3. Set `usbScannerMode: 'real'`
4. Scan with physical device

## 💡 Pro Tips

- Keep daemon running in separate terminal
- Use PowerShell script for advanced testing
- Test with mock mode before hardware arrives
- Increase debounce if getting duplicates
- Check logs if scans not working

---

**Everything you need on one page! 📄**
