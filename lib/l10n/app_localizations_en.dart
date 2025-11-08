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
  String get plan => 'Plan';

  @override
  String get expires => 'Expires';

  @override
  String get status => 'Status';

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
  String get searchByName => 'Search by name, phone, or email';

  @override
  String get noMembersFound => 'No members found';

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
  String get autoStartScanning => 'Auto-start scanning';

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
  String get verboseLogging => 'Verbose logging';

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
  String get success => 'Success';

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
  String get loginSubtitle => 'Sign in to access MituGym Scanner';

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
  String get offline => 'Offline';

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
  String get from => 'From';

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
  String get exportFailed => 'Export failed';

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
  String get apiUrlNotConfigured => 'API URL not configured';

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
}
