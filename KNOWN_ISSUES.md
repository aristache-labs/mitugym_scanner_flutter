# Known Issues and Warnings

## AudioPlayers Platform Thread Warning

### Warning Message:
```
[ERROR:flutter/shell/common/shell.cc(1120)] The 'xyz.luan/audioplayers/events/...' channel sent a message from native to Flutter on a non-platform thread.
```

### Status: **SAFE TO IGNORE**

This is a known verbose warning from the `audioplayers` package (v6.1.0). It does **NOT** affect:
- ✅ App functionality
- ✅ Audio playback (success/error sounds)
- ✅ App stability
- ✅ Performance

### Explanation:
The audioplayers plugin sends some event messages from background threads instead of the main platform thread. While this generates a warning, it doesn't cause crashes or data loss in this specific use case.

### Monitoring:
- Check for audioplayers updates: `flutter pub outdated`
- The warning may be fixed in future versions of the package
- Current version: `audioplayers: ^6.1.0`

### Workaround (if needed):
If the warning becomes problematic, you can:
1. Downgrade to `audioplayers: ^5.2.1`
2. Or disable audio features in Settings
3. Or wait for the next stable release with the fix

---

## Other Notes

### System Tray on Linux
- Requires `libayatana-appindicator3-dev` or `libappindicator3-dev`
- Install: `sudo apt-get install libayatana-appindicator3-dev`
- GNOME may require the AppIndicator extension

### PDF Export Fonts
- Roboto fonts are bundled in `assets/fonts/`
- Supports Romanian characters (Ă, Ș, Ț, etc.)
- No internet connection required

---

**Last Updated:** November 8, 2025

