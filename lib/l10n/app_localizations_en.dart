// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navQRScanner => 'QR Scanner';

  @override
  String get navCheckIns => 'Check-ins';

  @override
  String get navHistory => 'History';

  @override
  String get navMembers => 'Members';

  @override
  String get navSettings => 'Settings';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardSubtitle =>
      'Overview of total scans, check-ins, check-outs and gym activity';

  @override
  String get todayActivity => 'Today\'s Activity';

  @override
  String todayActivityWithCount(int count) {
    return 'Today\'s Activity ($count entries)';
  }

  @override
  String get totalScans => 'Total Scans';

  @override
  String get allScansToday => 'All scans today';

  @override
  String get checkIns => 'Check-ins';

  @override
  String get successfulEntries => 'Successful entries';

  @override
  String get checkOuts => 'Check-outs';

  @override
  String get successfulExits => 'Successful exits';

  @override
  String get denied => 'Denied';

  @override
  String get failedScans => 'Failed scans';

  @override
  String get statsTitle => 'Check-ins';

  @override
  String get statsSubtitle =>
      'Real-time activity tracking and member statistics';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String recentActivityWithCount(int count) {
    return 'Recent Activity ($count entries)';
  }

  @override
  String get todayStats => 'Today\'s Stats';

  @override
  String get recent => 'Recent';

  @override
  String get member => 'Member';

  @override
  String get checkedIn => 'Checked In';

  @override
  String get checkedOut => 'Checked Out';

  @override
  String get duration => 'Duration';

  @override
  String get plan => 'PLAN';

  @override
  String get expires => 'EXPIRES';

  @override
  String get status => 'STATUS';

  @override
  String get activeSession => 'Active Session';

  @override
  String get stillInGym => 'Still in GYM';

  @override
  String get planExpired => 'Plan Expired';

  @override
  String get accessDenied => 'Access Denied';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get expired => 'Expired';

  @override
  String get pending => 'Pending';

  @override
  String get historyTitle => 'History';

  @override
  String get historySubtitle =>
      'Complete record of all member check-ins and check-outs';

  @override
  String get searchPlaceholder => 'Search history...';

  @override
  String get loadMore => 'Load More';

  @override
  String get loadingMore => 'Loading more...';

  @override
  String get noMoreHistory => 'No more history';

  @override
  String get scans => 'scans';

  @override
  String scansCount(int count) {
    return '$count scans';
  }

  @override
  String get searchTitle => 'Members';

  @override
  String get searchSubtitle => 'Search and manage gym members';

  @override
  String get searchMembers => 'Search members...';

  @override
  String get searchByName => 'Search by name...';

  @override
  String get noMembersFound => 'No Members Found';

  @override
  String get tryDifferentSearch => 'Try a different search query';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle =>
      'Configure application preferences and system settings';

  @override
  String get general => 'General';

  @override
  String get scanner => 'Scanner';

  @override
  String get data => 'Data';

  @override
  String get about => 'About';

  @override
  String get apiConfiguration => 'API Configuration';

  @override
  String get apiUrl => 'API URL';

  @override
  String get apiUrlHint => 'Backend server URL';

  @override
  String get apiKey => 'API Key';

  @override
  String get apiKeyHint => 'Authentication key';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get testing => 'Testing...';

  @override
  String get connectionSuccessful => 'Connection Successful';

  @override
  String get connectionFailed => 'Connection Failed';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get romanian => 'Romanian';

  @override
  String get cameraSettings => 'Camera Settings';

  @override
  String get cameraDevice => 'Camera Device';

  @override
  String get selectCamera => 'Select Camera';

  @override
  String get frameRate => 'Frame Rate';

  @override
  String get fps => 'FPS';

  @override
  String get scanDebounce => 'Scan Debounce';

  @override
  String get milliseconds => 'milliseconds';

  @override
  String get scannerBehavior => 'Scanner Behavior';

  @override
  String get autoStartScanning => 'Auto-start Scanning';

  @override
  String get autoStartDesc =>
      'Begin scanning automatically when opening scanner screen';

  @override
  String get cameraVisible => 'Camera visible';

  @override
  String get cameraVisibleDesc => 'Show camera preview while scanning';

  @override
  String get audioSettings => 'Audio Settings';

  @override
  String get enableAudio => 'Enable audio feedback';

  @override
  String get audioDesc => 'Play sounds on successful/failed scans';

  @override
  String get soundVolume => 'Sound Volume';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get historyRetention => 'History Retention';

  @override
  String get days => 'days';

  @override
  String get exportSettings => 'Export Settings';

  @override
  String get exportPath => 'Export Path';

  @override
  String get browse => 'Browse';

  @override
  String get logSettings => 'Log Settings';

  @override
  String get logRetention => 'Log Retention';

  @override
  String get verboseLogging => 'Verbose Logging';

  @override
  String get verboseLoggingDesc => 'Include detailed debug information';

  @override
  String get clearData => 'Clear Data';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get clearHistoryDesc => 'Remove all local check-in history';

  @override
  String get clearLogs => 'Clear Logs';

  @override
  String get clearLogsDesc => 'Remove all application logs';

  @override
  String get applicationInfo => 'Application Information';

  @override
  String get version => 'Version';

  @override
  String get buildNumber => 'Build Number';

  @override
  String get launchBehavior => 'Launch Behavior';

  @override
  String get startWithWindows => 'Start with Windows';

  @override
  String get startWithWindowsDesc => 'Launch application when Windows starts';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get export => 'Export';

  @override
  String get import => 'Import';

  @override
  String get refresh => 'Refresh';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get clear => 'Clear';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get saveSuccess => 'Settings saved successfully';

  @override
  String get saveFailed => 'Failed to save settings';

  @override
  String get error => 'Error';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

  @override
  String get success => 'SUCCESS';

  @override
  String get loading => 'Loading...';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get noData => 'No data available';

  @override
  String get noResults => 'No results found';

  @override
  String get loginTitle => 'Login';

  @override
  String loginSubtitle(String appName) {
    return 'Sign in to access $appName';
  }

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get loggingIn => 'Logging in...';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get invalidCredentials => 'Invalid username or password';

  @override
  String get scannerTitle => 'QR Scanner';

  @override
  String get scannerSubtitle => 'Scan member QR codes for check-in/check-out';

  @override
  String get scanningActive => 'Scanning Active';

  @override
  String get scanningPaused => 'Scanning Paused';

  @override
  String get startScanning => 'Start Scanning';

  @override
  String get stopScanning => 'Stop Scanning';

  @override
  String get scanSuccess => 'Scan Successful';

  @override
  String get scanFailed => 'Scan Failed';

  @override
  String get invalidQRCode => 'Invalid QR Code';

  @override
  String get processingQRCode => 'Processing QR Code...';

  @override
  String get memberDetails => 'Member Details';

  @override
  String get memberInfo => 'Member Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get address => 'Address';

  @override
  String get city => 'City';

  @override
  String get county => 'County';

  @override
  String get gender => 'Gender';

  @override
  String get membershipInfo => 'Membership Information';

  @override
  String get membershipStatus => 'Membership Status';

  @override
  String get currentPlan => 'Current Plan';

  @override
  String get startDate => 'Start Date';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get daysRemaining => 'Days Remaining';

  @override
  String daysRemainingCount(int count) {
    return '$count days remaining';
  }

  @override
  String get offline => 'OFFLINE';

  @override
  String get online => 'Online';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get offlineModeDesc =>
      'Working offline - data will sync when connection is restored';

  @override
  String get syncPending => 'Sync Pending';

  @override
  String syncPendingCount(int count) {
    return '$count actions pending sync';
  }

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get customRange => 'Custom Range';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String from(String date) {
    return 'From $date...';
  }

  @override
  String get to => 'To';

  @override
  String get exportData => 'Export Data';

  @override
  String get exportHistory => 'Export History';

  @override
  String get exportMembers => 'Export Members';

  @override
  String get exportFormat => 'Export Format';

  @override
  String get csvFormat => 'CSV';

  @override
  String get pdfFormat => 'PDF';

  @override
  String get excelFormat => 'Excel';

  @override
  String get exportSuccess => 'Export successful';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String exportLocation(String path) {
    return 'Exported to: $path';
  }

  @override
  String get setExportPath => 'Set Export Path';

  @override
  String get selectFolderPath =>
      'Select or enter the folder path where export files should be saved:';

  @override
  String get enterPath => 'Enter path manually';

  @override
  String get selectFolder => 'Select Folder';

  @override
  String get welcomeBack => 'WELCOME BACK';

  @override
  String get logout => 'Logout';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutConfirmMessage =>
      'Are you sure you want to logout? You will need to login again to use the app.';

  @override
  String get logoutDisabledTitle => 'Logout Disabled';

  @override
  String get logoutDisabledMessage =>
      'You cannot logout while offline. Please connect to the internet before logging out.\n\nThis prevents you from being locked out of the app, as login requires an internet connection.';

  @override
  String get apiUrlNotConfigured => 'API URL not configured';

  @override
  String get staffPortal => 'Staff Portal';

  @override
  String get emailLabel => 'EMAIL';

  @override
  String get passwordLabel => 'PASSWORD';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get signIn => 'Sign In';

  @override
  String get needAccessContact => 'Need access? Contact';

  @override
  String get offlineLoginAvailable =>
      'You\'re offline. Offline login available for previous users.';

  @override
  String get offlineFirstLoginRequired =>
      'You\'re offline. Please connect to the internet for your first login.';

  @override
  String get firstLoginOnlineRequired =>
      'You must be online for your first login. Once you\'ve logged in successfully, you can login offline.';

  @override
  String offlineLoginFailed(String error) {
    return 'Offline login failed: $error';
  }

  @override
  String loginFailedError(String error) {
    return 'Login failed: $error';
  }

  @override
  String get cameraPreview => 'Camera Preview';

  @override
  String get readyToScan => 'Ready to scan';

  @override
  String get accessGranted => 'Access Granted';

  @override
  String get waitingForScan => 'Waiting for scan...';

  @override
  String get scanQRPrompt => 'Scan a QR code to view member details';

  @override
  String get scanningStopped => 'Scanning stopped';

  @override
  String get readyToScanEllipsis => 'Ready to scan...';

  @override
  String get processing => 'Processing...';

  @override
  String get initializingCamera => 'Initializing camera...';

  @override
  String get cameraStarting => 'Camera starting...';

  @override
  String get pressStartToBegin => 'Press START to begin';

  @override
  String get scanSuccessful => 'Scan Successful';

  @override
  String get scanFailedTitle => 'Scan Failed';

  @override
  String get checkInSuccessful => 'Check-in successful';

  @override
  String get checkOutSuccessful => 'Check-out successful';

  @override
  String get cooldownActive => 'Cooldown Active';

  @override
  String get pleaseWaitBeforeNextScan => 'Please wait before next scan';

  @override
  String get peakHours => 'Peak Hours';

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get evening => 'Evening';

  @override
  String get noDataYet => 'No data yet';

  @override
  String get liveGymOccupancy => 'Live gym occupancy throughout the day';

  @override
  String get liveOccupancy => 'Live occupancy';

  @override
  String get futureHours => 'Future hours';

  @override
  String get people => 'people';

  @override
  String get person => 'person';

  @override
  String get todaysTraffic => 'Today\'s Traffic';

  @override
  String get peak => 'Peak: ';

  @override
  String get updatesEveryHour => 'Updates every hour';

  @override
  String get successRate => 'Success Rate';

  @override
  String get csvDescription => 'Comma-separated values';

  @override
  String get pdfDescription => 'Portable document format';

  @override
  String get txtDescription => 'Plain text file';

  @override
  String exportedTo(String format, String path) {
    return 'Exported $format to: $path';
  }

  @override
  String showingOfTotal(int filtered, int total) {
    return 'Showing $filtered of $total';
  }

  @override
  String get all => 'All';

  @override
  String get pickDate => 'Pick Date';

  @override
  String get dateRange => 'Date Range';

  @override
  String get selectStartDate => 'Select start date';

  @override
  String get applyFilter => 'Apply Filter';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String searchError(String error) {
    return 'Search error: $error';
  }

  @override
  String get noMembersToExport => 'No members to export';

  @override
  String get searchByNameMembers => 'Search by name...';

  @override
  String get noMembersYet => 'No Members Yet';

  @override
  String get scanMemberQRToBuild =>
      'Scan member QR codes to build your database';

  @override
  String get tryAdjustingFilters => 'Try adjusting your search or filters';

  @override
  String memberFound(int count) {
    return '$count member found';
  }

  @override
  String membersFound(int count) {
    return '$count members found';
  }

  @override
  String get display => 'Display';

  @override
  String get audio => 'Audio';

  @override
  String get advanced => 'Advanced';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get settingsSavedSuccessfully => 'Settings saved successfully';

  @override
  String get apiConnection => 'API Connection';

  @override
  String get manageApiConnection => 'Manage your API connection';

  @override
  String get enterApiKey => 'Enter your API key';

  @override
  String get applicationPreferences => 'Application Preferences';

  @override
  String get startupBehaviorSettings => 'Startup and behavior settings';

  @override
  String get selectPreferredLanguage => 'Select your preferred language';

  @override
  String get launchAutomatically => 'Launch automatically when Windows starts';

  @override
  String get camera => 'Camera';

  @override
  String get deviceCaptureSettings => 'Device and capture settings';

  @override
  String get device => 'Device';

  @override
  String get qrCodeScanningBehavior => 'QR code scanning behavior';

  @override
  String get scanCooldown => 'Scan Cooldown';

  @override
  String get displayPreferences => 'Display Preferences';

  @override
  String get cameraUISettings => 'Camera and UI settings';

  @override
  String get showCameraByDefault => 'Show Camera by Default';

  @override
  String get displayCameraPreview => 'Display camera preview on scanner screen';

  @override
  String get beginScanningOnLaunch => 'Begin scanning when app launches';

  @override
  String get soundSettings => 'Sound Settings';

  @override
  String get audioFeedbackConfig => 'Audio feedback configuration';

  @override
  String get enableAudioFeedback => 'Enable Audio Feedback';

  @override
  String get playSoundWhenScanning => 'Play sound when scanning QR codes';

  @override
  String get volume => 'Volume';

  @override
  String get moreAudioSettingsComingSoon => 'More audio settings\ncoming soon';

  @override
  String get logDataRetentionSettings => 'Log and data retention settings';

  @override
  String get configureExportLocation => 'Configure export file location';

  @override
  String get usingDefaultLocation => 'Using default location';

  @override
  String get leaveEmptyForDefault => 'Leave empty to use default location';

  @override
  String get logging => 'Logging';

  @override
  String get appLoggingConfig => 'Application logging configuration';

  @override
  String get saveDebugLogs => 'Save debug, warning, and trace logs to files';

  @override
  String get helpfulForTroubleshooting => 'Helpful for troubleshooting issues';

  @override
  String get historyManagement => 'History Management';

  @override
  String get scanHistorySyncSettings => 'Scan history and sync settings';

  @override
  String totalRecords(int count) {
    return 'Total Records: $count';
  }

  @override
  String lastSynced(String date) {
    return 'Last Synced: $date';
  }

  @override
  String get cleanupOldHistory => 'Cleanup Old History';

  @override
  String get cleanup => 'Cleanup';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncAllDataFromServer => 'Sync All Data from Server';

  @override
  String get syncingFromServer => 'Syncing from server...';

  @override
  String syncError(String error) {
    return 'Sync error: $error';
  }

  @override
  String syncFailed(String error) {
    return 'Sync failed: $error';
  }

  @override
  String get confirmDeletion => 'Confirm deletion';

  @override
  String cleanupWarningMessage(int days) {
    return 'This will permanently delete all history records older than $days days. This action cannot be undone.';
  }

  @override
  String get apiTestResults => 'API Test Results';

  @override
  String get endpointStatus => 'ENDPOINT STATUS';

  @override
  String records(int count) {
    return 'Records: $count';
  }

  @override
  String get healthy => 'HEALTHY';

  @override
  String get degraded => 'DEGRADED';

  @override
  String get gymSchedule => 'GYM SCHEDULE';

  @override
  String get history => 'HISTORY';

  @override
  String get checkin => 'CHECKIN';

  @override
  String get reachable => 'REACHABLE';

  @override
  String get endpointIsOperational => 'Endpoint is operational';

  @override
  String get testingApiEndpoints => 'Testing API endpoints...';

  @override
  String get failedToFetchGymSchedule =>
      'Failed to fetch gym schedule - returned null';

  @override
  String get failedToFetchHistory => 'Failed to fetch history';

  @override
  String get endpointNotFound => 'Endpoint not found (404) - check API URL';

  @override
  String serverError(int code) {
    return 'Server error ($code)';
  }

  @override
  String endpointResponded(int code) {
    return 'Endpoint responded ($code)';
  }

  @override
  String get endpointReachableButKeyInvalid =>
      'Endpoint reachable but API key may be invalid';

  @override
  String get stateEndpointUri => 'State Endpoint-URI';

  @override
  String dioExceptionBadResponse(int code) {
    return 'Bad response: Status code $code';
  }

  @override
  String get dioException404 =>
      'Endpoint not found (404) - The requested resource does not exist';

  @override
  String get dioExceptionConnectionTimeout =>
      'Connection timeout - Server took too long to respond';

  @override
  String get dioExceptionReceiveTimeout =>
      'Receive timeout - Data transfer took too long';

  @override
  String get dioExceptionConnectionError =>
      'Connection error - Unable to connect to server';

  @override
  String get dioExceptionUnknown => 'Network error occurred';

  @override
  String get tapToEnlarge => 'Tap to enlarge';

  @override
  String get membership => 'MEMBERSHIP';

  @override
  String get contactAndAddress => 'CONTACT & ADDRESS';

  @override
  String get planLabel => 'Plan';

  @override
  String get expiresLabel => 'Expires';

  @override
  String get birthDateLabel => 'Birth Date';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get addressLabel => 'Address';

  @override
  String get noContactInformation => 'No contact information';

  @override
  String get notProvided => 'Not provided';

  @override
  String get viewFullProfile => 'View Full Profile';

  @override
  String couldNotOpenProfile(String url) {
    return 'Could not open profile: $url';
  }

  @override
  String errorOpeningProfile(String error) {
    return 'Error opening profile: $error';
  }

  @override
  String get exportMemberName => 'Member Name';

  @override
  String get exportCheckedIn => 'Checked In';

  @override
  String get exportCheckedOut => 'Checked Out';

  @override
  String get exportDuration => 'Duration';

  @override
  String get exportPlanExpired => 'Plan Expired';

  @override
  String get exportAccessDenied => 'Access Denied';

  @override
  String get exportActiveSession => 'Active Session';

  @override
  String get exportDenied => 'Denied';

  @override
  String get exportInProgress => 'In Progress';

  @override
  String get exportActivityReport => 'Activity Report';

  @override
  String get exportGenerated => 'Generated';

  @override
  String get exportTime => 'Time';

  @override
  String get exportTotalActivities => 'Total Activities';

  @override
  String get exportStatistics => 'Statistics';

  @override
  String get exportSuccessful => 'Successful';

  @override
  String get exportFailedLabel => 'Failed';

  @override
  String get exportSuccessRate => 'Success Rate';

  @override
  String get exportActivityLog => 'Activity Log';

  @override
  String get exportPage => 'Page';

  @override
  String get exportOf => 'of';

  @override
  String get exportEndOfReport => 'End of Report';

  @override
  String get exportMembersList => 'Members List';

  @override
  String get exportTotalMembers => 'Total Members';

  @override
  String get exportActive => 'Active';

  @override
  String get exportInactive => 'Inactive';

  @override
  String get exportMembersDirectory => 'Members Directory';

  @override
  String get exportName => 'Name';

  @override
  String get exportPlan => 'Plan';

  @override
  String get exportStatus => 'Status';

  @override
  String get exportExpires => 'Expires';

  @override
  String get exportContact => 'Contact';

  @override
  String get exportEmail => 'Email';

  @override
  String get exportMemberId => 'Member ID';

  @override
  String get exportGender => 'Gender';

  @override
  String get exportDateOfBirth => 'Date of Birth';

  @override
  String get exportAddress => 'Address';

  @override
  String get exportPhone => 'Phone';

  @override
  String get splashInitializing => 'Initializing scanner...';

  @override
  String get splashLoadingConfig => 'Loading configuration...';

  @override
  String get splashPreparingServices => 'Preparing services...';

  @override
  String get splashCheckingAuth => 'Checking authentication...';

  @override
  String get splashLoadingHistory => 'Loading history from server...';

  @override
  String get splashLoadingSchedule => 'Loading gym schedule...';

  @override
  String get splashLoadingCached => 'Loading cached data...';

  @override
  String get aboutDescription =>
      'High-performance desktop QR scanner for gym member check-ins and check-outs';

  @override
  String get aboutBuiltWith => 'Built with Flutter';

  @override
  String get aboutVersion => 'Version';

  @override
  String aboutCopyright(String year, String companyName) {
    return '© $year $companyName. All rights reserved.';
  }

  @override
  String get sidebarVersion => 'Version';

  @override
  String sidebarCopyright(String year, String companyName) {
    return '© $year $companyName. All rights reserved.';
  }

  @override
  String get aboutLicenses => 'View Licenses';

  @override
  String get aboutClose => 'Close';

  @override
  String get licensesPackages => 'Packages';

  @override
  String get licensesSelectPackage => 'Select a package';

  @override
  String get licensesChoosePackage =>
      'Choose a package from the list to view its licenses';

  @override
  String get licensesLoading => 'Loading...';

  @override
  String get licensesLoadingPackages => 'Loading packages...';

  @override
  String get licensesLicense => 'License';

  @override
  String licensesCount(int count) {
    return '$count licenses';
  }
}
