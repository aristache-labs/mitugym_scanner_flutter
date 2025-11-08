import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager for desktop
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1400, 900),
    minimumSize: Size(1200, 700),
    center: true,
    title: 'MituGym Scanner',
    titleBarStyle: TitleBarStyle.normal,
    backgroundColor: Colors.transparent,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    // Prevent default close behavior to allow tray service to handle it
    await windowManager.setPreventClose(true);
    
    // Set window icon (title bar and taskbar)
    if (Platform.isWindows) {
      await windowManager.setIcon('assets/images/logo.ico');
    } else {
      await windowManager.setIcon('assets/images/logo.png');
    }
  });

  runApp(
    const ProviderScope(
      child: MituGymScannerApp(),
    ),
  );
}

class MituGymScannerApp extends StatelessWidget {
  const MituGymScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MituGym Scanner',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
