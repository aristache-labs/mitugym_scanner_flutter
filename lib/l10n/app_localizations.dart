import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ro.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ro'),
  ];

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navQRScanner.
  ///
  /// In en, this message translates to:
  /// **'QR Scanner'**
  String get navQRScanner;

  /// No description provided for @navCheckIns.
  ///
  /// In en, this message translates to:
  /// **'Check-ins'**
  String get navCheckIns;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get navMembers;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Overview of total scans, check-ins, check-outs and gym activity'**
  String get dashboardSubtitle;

  /// No description provided for @todayActivity.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Activity'**
  String get todayActivity;

  /// No description provided for @todayActivityWithCount.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Activity ({count} entries)'**
  String todayActivityWithCount(int count);

  /// No description provided for @totalScans.
  ///
  /// In en, this message translates to:
  /// **'Total Scans'**
  String get totalScans;

  /// No description provided for @allScansToday.
  ///
  /// In en, this message translates to:
  /// **'All scans today'**
  String get allScansToday;

  /// No description provided for @checkIns.
  ///
  /// In en, this message translates to:
  /// **'Check-ins'**
  String get checkIns;

  /// No description provided for @successfulEntries.
  ///
  /// In en, this message translates to:
  /// **'Successful entries'**
  String get successfulEntries;

  /// No description provided for @checkOuts.
  ///
  /// In en, this message translates to:
  /// **'Check-outs'**
  String get checkOuts;

  /// No description provided for @successfulExits.
  ///
  /// In en, this message translates to:
  /// **'Successful exits'**
  String get successfulExits;

  /// No description provided for @denied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get denied;

  /// No description provided for @failedScans.
  ///
  /// In en, this message translates to:
  /// **'Failed scans'**
  String get failedScans;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Check-ins'**
  String get statsTitle;

  /// No description provided for @statsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time activity tracking and member statistics'**
  String get statsSubtitle;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @recentActivityWithCount.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity ({count} entries)'**
  String recentActivityWithCount(int count);

  /// No description provided for @todayStats.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Stats'**
  String get todayStats;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @checkedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked In'**
  String get checkedIn;

  /// No description provided for @checkedOut.
  ///
  /// In en, this message translates to:
  /// **'Checked Out'**
  String get checkedOut;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'PLAN'**
  String get plan;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'EXPIRES'**
  String get expires;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get status;

  /// No description provided for @activeSession.
  ///
  /// In en, this message translates to:
  /// **'Active Session'**
  String get activeSession;

  /// No description provided for @stillInGym.
  ///
  /// In en, this message translates to:
  /// **'Still in GYM'**
  String get stillInGym;

  /// No description provided for @planExpired.
  ///
  /// In en, this message translates to:
  /// **'Plan Expired'**
  String get planExpired;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get accessDenied;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete record of all member check-ins and check-outs'**
  String get historySubtitle;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search history...'**
  String get searchPlaceholder;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @loadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more...'**
  String get loadingMore;

  /// No description provided for @noMoreHistory.
  ///
  /// In en, this message translates to:
  /// **'No more history'**
  String get noMoreHistory;

  /// No description provided for @scans.
  ///
  /// In en, this message translates to:
  /// **'scans'**
  String get scans;

  /// No description provided for @scansCount.
  ///
  /// In en, this message translates to:
  /// **'{count} scans'**
  String scansCount(int count);

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get searchTitle;

  /// No description provided for @searchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search and manage gym members'**
  String get searchSubtitle;

  /// No description provided for @searchMembers.
  ///
  /// In en, this message translates to:
  /// **'Search members...'**
  String get searchMembers;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name...'**
  String get searchByName;

  /// No description provided for @noMembersFound.
  ///
  /// In en, this message translates to:
  /// **'No Members Found'**
  String get noMembersFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search query'**
  String get tryDifferentSearch;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure application preferences and system settings'**
  String get settingsSubtitle;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @scanner.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get scanner;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @apiConfiguration.
  ///
  /// In en, this message translates to:
  /// **'API Configuration'**
  String get apiConfiguration;

  /// No description provided for @apiUrl.
  ///
  /// In en, this message translates to:
  /// **'API URL'**
  String get apiUrl;

  /// No description provided for @apiUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Backend server URL'**
  String get apiUrlHint;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @apiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Authentication key'**
  String get apiKeyHint;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get testConnection;

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'Testing...'**
  String get testing;

  /// No description provided for @connectionSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Connection Successful'**
  String get connectionSuccessful;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get connectionFailed;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @romanian.
  ///
  /// In en, this message translates to:
  /// **'Romanian'**
  String get romanian;

  /// No description provided for @cameraSettings.
  ///
  /// In en, this message translates to:
  /// **'Camera Settings'**
  String get cameraSettings;

  /// No description provided for @cameraDevice.
  ///
  /// In en, this message translates to:
  /// **'Camera Device'**
  String get cameraDevice;

  /// No description provided for @selectCamera.
  ///
  /// In en, this message translates to:
  /// **'Select Camera'**
  String get selectCamera;

  /// No description provided for @frameRate.
  ///
  /// In en, this message translates to:
  /// **'Frame Rate'**
  String get frameRate;

  /// No description provided for @fps.
  ///
  /// In en, this message translates to:
  /// **'FPS'**
  String get fps;

  /// No description provided for @scanDebounce.
  ///
  /// In en, this message translates to:
  /// **'Scan Debounce'**
  String get scanDebounce;

  /// No description provided for @milliseconds.
  ///
  /// In en, this message translates to:
  /// **'milliseconds'**
  String get milliseconds;

  /// No description provided for @scannerBehavior.
  ///
  /// In en, this message translates to:
  /// **'Scanner Behavior'**
  String get scannerBehavior;

  /// No description provided for @autoStartScanning.
  ///
  /// In en, this message translates to:
  /// **'Auto-start Scanning'**
  String get autoStartScanning;

  /// No description provided for @autoStartDesc.
  ///
  /// In en, this message translates to:
  /// **'Begin scanning automatically when opening scanner screen'**
  String get autoStartDesc;

  /// No description provided for @cameraVisible.
  ///
  /// In en, this message translates to:
  /// **'Camera visible'**
  String get cameraVisible;

  /// No description provided for @cameraVisibleDesc.
  ///
  /// In en, this message translates to:
  /// **'Show camera preview while scanning'**
  String get cameraVisibleDesc;

  /// No description provided for @audioSettings.
  ///
  /// In en, this message translates to:
  /// **'Audio Settings'**
  String get audioSettings;

  /// No description provided for @enableAudio.
  ///
  /// In en, this message translates to:
  /// **'Enable audio feedback'**
  String get enableAudio;

  /// No description provided for @audioDesc.
  ///
  /// In en, this message translates to:
  /// **'Play sounds on successful/failed scans'**
  String get audioDesc;

  /// No description provided for @soundVolume.
  ///
  /// In en, this message translates to:
  /// **'Sound Volume'**
  String get soundVolume;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @historyRetention.
  ///
  /// In en, this message translates to:
  /// **'History Retention'**
  String get historyRetention;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @exportSettings.
  ///
  /// In en, this message translates to:
  /// **'Export Settings'**
  String get exportSettings;

  /// No description provided for @exportPath.
  ///
  /// In en, this message translates to:
  /// **'Export Path'**
  String get exportPath;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @logSettings.
  ///
  /// In en, this message translates to:
  /// **'Log Settings'**
  String get logSettings;

  /// No description provided for @logRetention.
  ///
  /// In en, this message translates to:
  /// **'Log Retention'**
  String get logRetention;

  /// No description provided for @verboseLogging.
  ///
  /// In en, this message translates to:
  /// **'Verbose Logging'**
  String get verboseLogging;

  /// No description provided for @verboseLoggingDesc.
  ///
  /// In en, this message translates to:
  /// **'Include detailed debug information'**
  String get verboseLoggingDesc;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get clearData;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @clearHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove all local check-in history'**
  String get clearHistoryDesc;

  /// No description provided for @clearLogs.
  ///
  /// In en, this message translates to:
  /// **'Clear Logs'**
  String get clearLogs;

  /// No description provided for @clearLogsDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove all application logs'**
  String get clearLogsDesc;

  /// No description provided for @applicationInfo.
  ///
  /// In en, this message translates to:
  /// **'Application Information'**
  String get applicationInfo;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @buildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get buildNumber;

  /// No description provided for @launchBehavior.
  ///
  /// In en, this message translates to:
  /// **'Launch Behavior'**
  String get launchBehavior;

  /// No description provided for @startWithWindows.
  ///
  /// In en, this message translates to:
  /// **'Start with Windows'**
  String get startWithWindows;

  /// No description provided for @startWithWindowsDesc.
  ///
  /// In en, this message translates to:
  /// **'Launch application when Windows starts'**
  String get startWithWindowsDesc;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get saveSuccess;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save settings'**
  String get saveFailed;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'SUCCESS'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access MituGym Scanner'**
  String get loginSubtitle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get invalidCredentials;

  /// No description provided for @scannerTitle.
  ///
  /// In en, this message translates to:
  /// **'QR Scanner'**
  String get scannerTitle;

  /// No description provided for @scannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan member QR codes for check-in/check-out'**
  String get scannerSubtitle;

  /// No description provided for @scanningActive.
  ///
  /// In en, this message translates to:
  /// **'Scanning Active'**
  String get scanningActive;

  /// No description provided for @scanningPaused.
  ///
  /// In en, this message translates to:
  /// **'Scanning Paused'**
  String get scanningPaused;

  /// No description provided for @startScanning.
  ///
  /// In en, this message translates to:
  /// **'Start Scanning'**
  String get startScanning;

  /// No description provided for @stopScanning.
  ///
  /// In en, this message translates to:
  /// **'Stop Scanning'**
  String get stopScanning;

  /// No description provided for @scanSuccess.
  ///
  /// In en, this message translates to:
  /// **'Scan Successful'**
  String get scanSuccess;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scan Failed'**
  String get scanFailed;

  /// No description provided for @invalidQRCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR Code'**
  String get invalidQRCode;

  /// No description provided for @processingQRCode.
  ///
  /// In en, this message translates to:
  /// **'Processing QR Code...'**
  String get processingQRCode;

  /// No description provided for @memberDetails.
  ///
  /// In en, this message translates to:
  /// **'Member Details'**
  String get memberDetails;

  /// No description provided for @memberInfo.
  ///
  /// In en, this message translates to:
  /// **'Member Information'**
  String get memberInfo;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @county.
  ///
  /// In en, this message translates to:
  /// **'County'**
  String get county;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @membershipInfo.
  ///
  /// In en, this message translates to:
  /// **'Membership Information'**
  String get membershipInfo;

  /// No description provided for @membershipStatus.
  ///
  /// In en, this message translates to:
  /// **'Membership Status'**
  String get membershipStatus;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlan;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'Days Remaining'**
  String get daysRemaining;

  /// No description provided for @daysRemainingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days remaining'**
  String daysRemainingCount(int count);

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get offline;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @offlineModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Working offline - data will sync when connection is restored'**
  String get offlineModeDesc;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'Sync Pending'**
  String get syncPending;

  /// No description provided for @syncPendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} actions pending sync'**
  String syncPendingCount(int count);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get customRange;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From {date}...'**
  String from(String date);

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @exportHistory.
  ///
  /// In en, this message translates to:
  /// **'Export History'**
  String get exportHistory;

  /// No description provided for @exportMembers.
  ///
  /// In en, this message translates to:
  /// **'Export Members'**
  String get exportMembers;

  /// No description provided for @exportFormat.
  ///
  /// In en, this message translates to:
  /// **'Export Format'**
  String get exportFormat;

  /// No description provided for @csvFormat.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get csvFormat;

  /// No description provided for @pdfFormat.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfFormat;

  /// No description provided for @excelFormat.
  ///
  /// In en, this message translates to:
  /// **'Excel'**
  String get excelFormat;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export successful'**
  String get exportSuccess;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @exportLocation.
  ///
  /// In en, this message translates to:
  /// **'Exported to: {path}'**
  String exportLocation(String path);

  /// No description provided for @setExportPath.
  ///
  /// In en, this message translates to:
  /// **'Set Export Path'**
  String get setExportPath;

  /// No description provided for @selectFolderPath.
  ///
  /// In en, this message translates to:
  /// **'Select or enter the folder path where export files should be saved:'**
  String get selectFolderPath;

  /// No description provided for @enterPath.
  ///
  /// In en, this message translates to:
  /// **'Enter path manually'**
  String get enterPath;

  /// No description provided for @selectFolder.
  ///
  /// In en, this message translates to:
  /// **'Select Folder'**
  String get selectFolder;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'WELCOME BACK'**
  String get welcomeBack;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @apiUrlNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'API URL not configured'**
  String get apiUrlNotConfigured;

  /// No description provided for @cameraPreview.
  ///
  /// In en, this message translates to:
  /// **'Camera Preview'**
  String get cameraPreview;

  /// No description provided for @readyToScan.
  ///
  /// In en, this message translates to:
  /// **'Ready to scan'**
  String get readyToScan;

  /// No description provided for @accessGranted.
  ///
  /// In en, this message translates to:
  /// **'Access Granted'**
  String get accessGranted;

  /// No description provided for @waitingForScan.
  ///
  /// In en, this message translates to:
  /// **'Waiting for scan...'**
  String get waitingForScan;

  /// No description provided for @scanQRPrompt.
  ///
  /// In en, this message translates to:
  /// **'Scan a QR code to view member details'**
  String get scanQRPrompt;

  /// No description provided for @scanningStopped.
  ///
  /// In en, this message translates to:
  /// **'Scanning stopped'**
  String get scanningStopped;

  /// No description provided for @readyToScanEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Ready to scan...'**
  String get readyToScanEllipsis;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @initializingCamera.
  ///
  /// In en, this message translates to:
  /// **'Initializing camera...'**
  String get initializingCamera;

  /// No description provided for @cameraStarting.
  ///
  /// In en, this message translates to:
  /// **'Camera starting...'**
  String get cameraStarting;

  /// No description provided for @pressStartToBegin.
  ///
  /// In en, this message translates to:
  /// **'Press START to begin'**
  String get pressStartToBegin;

  /// No description provided for @scanSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Scan Successful'**
  String get scanSuccessful;

  /// No description provided for @scanFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Failed'**
  String get scanFailedTitle;

  /// No description provided for @checkInSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Check-in successful'**
  String get checkInSuccessful;

  /// No description provided for @checkOutSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Check-out successful'**
  String get checkOutSuccessful;

  /// No description provided for @cooldownActive.
  ///
  /// In en, this message translates to:
  /// **'Cooldown Active'**
  String get cooldownActive;

  /// No description provided for @pleaseWaitBeforeNextScan.
  ///
  /// In en, this message translates to:
  /// **'Please wait before next scan'**
  String get pleaseWaitBeforeNextScan;

  /// No description provided for @peakHours.
  ///
  /// In en, this message translates to:
  /// **'Peak Hours'**
  String get peakHours;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @liveGymOccupancy.
  ///
  /// In en, this message translates to:
  /// **'Live gym occupancy throughout the day'**
  String get liveGymOccupancy;

  /// No description provided for @liveOccupancy.
  ///
  /// In en, this message translates to:
  /// **'Live occupancy'**
  String get liveOccupancy;

  /// No description provided for @futureHours.
  ///
  /// In en, this message translates to:
  /// **'Future hours'**
  String get futureHours;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'people'**
  String get people;

  /// No description provided for @person.
  ///
  /// In en, this message translates to:
  /// **'person'**
  String get person;

  /// No description provided for @todaysTraffic.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Traffic'**
  String get todaysTraffic;

  /// No description provided for @peak.
  ///
  /// In en, this message translates to:
  /// **'Peak: '**
  String get peak;

  /// No description provided for @updatesEveryHour.
  ///
  /// In en, this message translates to:
  /// **'Updates every hour'**
  String get updatesEveryHour;

  /// No description provided for @successRate.
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get successRate;

  /// No description provided for @csvDescription.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated values'**
  String get csvDescription;

  /// No description provided for @pdfDescription.
  ///
  /// In en, this message translates to:
  /// **'Portable document format'**
  String get pdfDescription;

  /// No description provided for @txtDescription.
  ///
  /// In en, this message translates to:
  /// **'Plain text file'**
  String get txtDescription;

  /// No description provided for @exportedTo.
  ///
  /// In en, this message translates to:
  /// **'Exported {format} to: {path}'**
  String exportedTo(String format, String path);

  /// No description provided for @showingOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Showing {filtered} of {total}'**
  String showingOfTotal(int filtered, int total);

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick Date'**
  String get pickDate;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
  String get selectStartDate;

  /// No description provided for @applyFilter.
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get applyFilter;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'Search error: {error}'**
  String searchError(String error);

  /// No description provided for @noMembersToExport.
  ///
  /// In en, this message translates to:
  /// **'No members to export'**
  String get noMembersToExport;

  /// No description provided for @searchByNameMembers.
  ///
  /// In en, this message translates to:
  /// **'Search by name...'**
  String get searchByNameMembers;

  /// No description provided for @noMembersYet.
  ///
  /// In en, this message translates to:
  /// **'No Members Yet'**
  String get noMembersYet;

  /// No description provided for @scanMemberQRToBuild.
  ///
  /// In en, this message translates to:
  /// **'Scan member QR codes to build your database'**
  String get scanMemberQRToBuild;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get tryAdjustingFilters;

  /// No description provided for @memberFound.
  ///
  /// In en, this message translates to:
  /// **'{count} member found'**
  String memberFound(int count);

  /// No description provided for @membersFound.
  ///
  /// In en, this message translates to:
  /// **'{count} members found'**
  String membersFound(int count);

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @settingsSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSavedSuccessfully;

  /// No description provided for @apiConnection.
  ///
  /// In en, this message translates to:
  /// **'API Connection'**
  String get apiConnection;

  /// No description provided for @manageApiConnection.
  ///
  /// In en, this message translates to:
  /// **'Manage your API connection'**
  String get manageApiConnection;

  /// No description provided for @enterApiKey.
  ///
  /// In en, this message translates to:
  /// **'Enter your API key'**
  String get enterApiKey;

  /// No description provided for @applicationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Application Preferences'**
  String get applicationPreferences;

  /// No description provided for @startupBehaviorSettings.
  ///
  /// In en, this message translates to:
  /// **'Startup and behavior settings'**
  String get startupBehaviorSettings;

  /// No description provided for @selectPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get selectPreferredLanguage;

  /// No description provided for @launchAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Launch automatically when Windows starts'**
  String get launchAutomatically;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @deviceCaptureSettings.
  ///
  /// In en, this message translates to:
  /// **'Device and capture settings'**
  String get deviceCaptureSettings;

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @qrCodeScanningBehavior.
  ///
  /// In en, this message translates to:
  /// **'QR code scanning behavior'**
  String get qrCodeScanningBehavior;

  /// No description provided for @scanCooldown.
  ///
  /// In en, this message translates to:
  /// **'Scan Cooldown'**
  String get scanCooldown;

  /// No description provided for @displayPreferences.
  ///
  /// In en, this message translates to:
  /// **'Display Preferences'**
  String get displayPreferences;

  /// No description provided for @cameraUISettings.
  ///
  /// In en, this message translates to:
  /// **'Camera and UI settings'**
  String get cameraUISettings;

  /// No description provided for @showCameraByDefault.
  ///
  /// In en, this message translates to:
  /// **'Show Camera by Default'**
  String get showCameraByDefault;

  /// No description provided for @displayCameraPreview.
  ///
  /// In en, this message translates to:
  /// **'Display camera preview on scanner screen'**
  String get displayCameraPreview;

  /// No description provided for @beginScanningOnLaunch.
  ///
  /// In en, this message translates to:
  /// **'Begin scanning when app launches'**
  String get beginScanningOnLaunch;

  /// No description provided for @soundSettings.
  ///
  /// In en, this message translates to:
  /// **'Sound Settings'**
  String get soundSettings;

  /// No description provided for @audioFeedbackConfig.
  ///
  /// In en, this message translates to:
  /// **'Audio feedback configuration'**
  String get audioFeedbackConfig;

  /// No description provided for @enableAudioFeedback.
  ///
  /// In en, this message translates to:
  /// **'Enable Audio Feedback'**
  String get enableAudioFeedback;

  /// No description provided for @playSoundWhenScanning.
  ///
  /// In en, this message translates to:
  /// **'Play sound when scanning QR codes'**
  String get playSoundWhenScanning;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @moreAudioSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'More audio settings\ncoming soon'**
  String get moreAudioSettingsComingSoon;

  /// No description provided for @logDataRetentionSettings.
  ///
  /// In en, this message translates to:
  /// **'Log and data retention settings'**
  String get logDataRetentionSettings;

  /// No description provided for @configureExportLocation.
  ///
  /// In en, this message translates to:
  /// **'Configure export file location'**
  String get configureExportLocation;

  /// No description provided for @usingDefaultLocation.
  ///
  /// In en, this message translates to:
  /// **'Using default location'**
  String get usingDefaultLocation;

  /// No description provided for @leaveEmptyForDefault.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use default location'**
  String get leaveEmptyForDefault;

  /// No description provided for @logging.
  ///
  /// In en, this message translates to:
  /// **'Logging'**
  String get logging;

  /// No description provided for @appLoggingConfig.
  ///
  /// In en, this message translates to:
  /// **'Application logging configuration'**
  String get appLoggingConfig;

  /// No description provided for @saveDebugLogs.
  ///
  /// In en, this message translates to:
  /// **'Save debug, warning, and trace logs to files'**
  String get saveDebugLogs;

  /// No description provided for @helpfulForTroubleshooting.
  ///
  /// In en, this message translates to:
  /// **'Helpful for troubleshooting issues'**
  String get helpfulForTroubleshooting;

  /// No description provided for @historyManagement.
  ///
  /// In en, this message translates to:
  /// **'History Management'**
  String get historyManagement;

  /// No description provided for @scanHistorySyncSettings.
  ///
  /// In en, this message translates to:
  /// **'Scan history and sync settings'**
  String get scanHistorySyncSettings;

  /// No description provided for @totalRecords.
  ///
  /// In en, this message translates to:
  /// **'Total Records: {count}'**
  String totalRecords(int count);

  /// No description provided for @lastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last Synced: {date}'**
  String lastSynced(String date);

  /// No description provided for @cleanupOldHistory.
  ///
  /// In en, this message translates to:
  /// **'Cleanup Old History'**
  String get cleanupOldHistory;

  /// No description provided for @cleanup.
  ///
  /// In en, this message translates to:
  /// **'Cleanup'**
  String get cleanup;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @syncAllDataFromServer.
  ///
  /// In en, this message translates to:
  /// **'Sync All Data from Server'**
  String get syncAllDataFromServer;

  /// No description provided for @syncingFromServer.
  ///
  /// In en, this message translates to:
  /// **'Syncing from server...'**
  String get syncingFromServer;

  /// No description provided for @syncError.
  ///
  /// In en, this message translates to:
  /// **'Sync error: {error}'**
  String syncError(String error);

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String syncFailed(String error);

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDeletion;

  /// No description provided for @cleanupWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all history records older than {days} days. This action cannot be undone.'**
  String cleanupWarningMessage(int days);

  /// No description provided for @apiTestResults.
  ///
  /// In en, this message translates to:
  /// **'API Test Results'**
  String get apiTestResults;

  /// No description provided for @endpointStatus.
  ///
  /// In en, this message translates to:
  /// **'ENDPOINT STATUS'**
  String get endpointStatus;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'Records: {count}'**
  String records(int count);

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'HEALTHY'**
  String get healthy;

  /// No description provided for @degraded.
  ///
  /// In en, this message translates to:
  /// **'DEGRADED'**
  String get degraded;

  /// No description provided for @gymSchedule.
  ///
  /// In en, this message translates to:
  /// **'GYM SCHEDULE'**
  String get gymSchedule;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get history;

  /// No description provided for @checkin.
  ///
  /// In en, this message translates to:
  /// **'CHECKIN'**
  String get checkin;

  /// No description provided for @reachable.
  ///
  /// In en, this message translates to:
  /// **'REACHABLE'**
  String get reachable;

  /// No description provided for @endpointIsOperational.
  ///
  /// In en, this message translates to:
  /// **'Endpoint is operational'**
  String get endpointIsOperational;

  /// No description provided for @testingApiEndpoints.
  ///
  /// In en, this message translates to:
  /// **'Testing API endpoints...'**
  String get testingApiEndpoints;

  /// No description provided for @failedToFetchGymSchedule.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch gym schedule - returned null'**
  String get failedToFetchGymSchedule;

  /// No description provided for @failedToFetchHistory.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch history'**
  String get failedToFetchHistory;

  /// No description provided for @endpointNotFound.
  ///
  /// In en, this message translates to:
  /// **'Endpoint not found (404) - check API URL'**
  String get endpointNotFound;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error ({code})'**
  String serverError(int code);

  /// No description provided for @endpointResponded.
  ///
  /// In en, this message translates to:
  /// **'Endpoint responded ({code})'**
  String endpointResponded(int code);

  /// No description provided for @endpointReachableButKeyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Endpoint reachable but API key may be invalid'**
  String get endpointReachableButKeyInvalid;

  /// No description provided for @stateEndpointUri.
  ///
  /// In en, this message translates to:
  /// **'State Endpoint-URI'**
  String get stateEndpointUri;

  /// No description provided for @dioExceptionBadResponse.
  ///
  /// In en, this message translates to:
  /// **'Bad response: Status code {code}'**
  String dioExceptionBadResponse(int code);

  /// No description provided for @dioException404.
  ///
  /// In en, this message translates to:
  /// **'Endpoint not found (404) - The requested resource does not exist'**
  String get dioException404;

  /// No description provided for @dioExceptionConnectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timeout - Server took too long to respond'**
  String get dioExceptionConnectionTimeout;

  /// No description provided for @dioExceptionReceiveTimeout.
  ///
  /// In en, this message translates to:
  /// **'Receive timeout - Data transfer took too long'**
  String get dioExceptionReceiveTimeout;

  /// No description provided for @dioExceptionConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error - Unable to connect to server'**
  String get dioExceptionConnectionError;

  /// No description provided for @dioExceptionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Network error occurred'**
  String get dioExceptionUnknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
