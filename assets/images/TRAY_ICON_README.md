# System Tray Icon

## Current Setup
The app currently uses `logo.png` for the system tray icon. This works, but for better Windows integration, you should create a proper `.ico` file.

## Recommendations

### Windows (.ico file)
- Create a `logo.ico` file with multiple sizes: 16x16, 24x24, 32x32, 48x48, 256x256
- Place it in `assets/images/logo.ico`
- Update the code in `tray_service.dart` to use `.ico` on Windows

### macOS (.png file)
- Current `.png` works fine
- Recommended size: 22x22 pixels @ 2x (44x44 actual pixels)
- Use Template Image style (monochrome with alpha channel)

### Linux (.png file)
- Current `.png` works fine  
- Recommended size: 22x22 pixels or 24x24 pixels

## Creating a Windows .ico File

You can use online tools like:
- https://convertio.co/png-ico/
- https://www.icoconverter.com/
- Or use GIMP/Photoshop to export as .ico with multiple sizes

## Updating the Code

After creating `logo.ico`, update `lib/services/tray_service.dart`:

```dart
await trayManager.setIcon(
  Platform.isWindows
      ? 'assets/images/logo.ico'
      : 'assets/images/logo.png',
);
```

