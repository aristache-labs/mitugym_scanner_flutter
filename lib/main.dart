import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'l10n/app_localizations.dart';
import 'config/theme.dart';
import 'constants/app_constants.dart';
import 'screens/splash_screen.dart';
import 'providers/language_provider.dart';

// Global navigator key for accessing navigator context from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for all locales
  await initializeDateFormatting();
  
  // Load saved locale before starting the app
  final initialLocale = await LanguageNotifier.getSavedLocale();

  // Initialize launch at startup
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  launchAtStartup.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
  );

  // Initialize window manager for desktop
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1400, 900),
    minimumSize: Size(1200, 700),
    center: true,
    title: AppConstants.appName,
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
    ProviderScope(
      overrides: [
        languageProvider.overrideWith(() => LanguageNotifierWithInitial(initialLocale)),
      ],
      child: const MituGymScannerApp(),
    ),
  );
}

class MituGymScannerApp extends ConsumerWidget {
  const MituGymScannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: AppConstants.appName,
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      
      // Localization configuration
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LanguageNotifier.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        // If the device locale is not supported, return English as fallback
        return LanguageNotifier.englishLocale;
      },
      
      home: const SplashScreen(),
    );
  }
}
