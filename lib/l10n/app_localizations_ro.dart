// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get navDashboard => 'Tablou de bord';

  @override
  String get navQRScanner => 'Scanner QR';

  @override
  String get navCheckIns => 'Intrări';

  @override
  String get navHistory => 'Istoric';

  @override
  String get navMembers => 'Membri';

  @override
  String get navSettings => 'Setări';

  @override
  String get dashboardTitle => 'Tablou de bord';

  @override
  String get dashboardSubtitle =>
      'Privire de ansamblu asupra scanărilor, intrărilor, ieșirilor și activității sălii';

  @override
  String get todayActivity => 'Activitatea de azi';

  @override
  String todayActivityWithCount(int count) {
    return 'Activitatea de azi ($count înregistrări)';
  }

  @override
  String get totalScans => 'Total Scanări';

  @override
  String get allScansToday => 'Toate scanările de azi';

  @override
  String get checkIns => 'Intrări';

  @override
  String get successfulEntries => 'Intrări reușite';

  @override
  String get checkOuts => 'Ieșiri';

  @override
  String get successfulExits => 'Ieșiri reușite';

  @override
  String get denied => 'Refuzate';

  @override
  String get failedScans => 'Scanări eșuate';

  @override
  String get statsTitle => 'Intrări';

  @override
  String get statsSubtitle =>
      'Urmărire în timp real a activității și statistici membri';

  @override
  String get recentActivity => 'Activitate recentă';

  @override
  String recentActivityWithCount(int count) {
    return 'Activitate recentă ($count înregistrări)';
  }

  @override
  String get todayStats => 'Statistici de azi';

  @override
  String get recent => 'Recent';

  @override
  String get member => 'Membru';

  @override
  String get checkedIn => 'Check-in';

  @override
  String get checkedOut => 'Check-out';

  @override
  String get duration => 'Durată';

  @override
  String get plan => 'Abonament';

  @override
  String get expires => 'Expiră';

  @override
  String get status => 'Status';

  @override
  String get activeSession => 'Sesiune activă';

  @override
  String get stillInGym => 'Încă în sală';

  @override
  String get planExpired => 'Abonament expirat';

  @override
  String get accessDenied => 'Acces refuzat';

  @override
  String get active => 'Activ';

  @override
  String get inactive => 'Inactiv';

  @override
  String get expired => 'Expirat';

  @override
  String get historyTitle => 'Istoric';

  @override
  String get historySubtitle =>
      'Înregistrare completă a tuturor intrărilor și ieșirilor membrilor';

  @override
  String get searchPlaceholder => 'Caută în istoric...';

  @override
  String get loadMore => 'Încarcă mai mult';

  @override
  String get loadingMore => 'Se încarcă...';

  @override
  String get noMoreHistory => 'Nu mai există istoric';

  @override
  String get scans => 'scanări';

  @override
  String scansCount(int count) {
    return '$count scanări';
  }

  @override
  String get searchTitle => 'Membri';

  @override
  String get searchSubtitle => 'Caută și gestionează membrii sălii';

  @override
  String get searchMembers => 'Caută membri...';

  @override
  String get searchByName => 'Caută după nume, telefon sau email';

  @override
  String get noMembersFound => 'Nu s-au găsit membri';

  @override
  String get tryDifferentSearch => 'Încearcă o altă interogare de căutare';

  @override
  String get settingsTitle => 'Setări';

  @override
  String get settingsSubtitle =>
      'Configurează preferințele aplicației și setările sistemului';

  @override
  String get general => 'General';

  @override
  String get scanner => 'Scanner';

  @override
  String get data => 'Date';

  @override
  String get about => 'Despre';

  @override
  String get apiConfiguration => 'Configurare API';

  @override
  String get apiUrl => 'URL API';

  @override
  String get apiUrlHint => 'URL server backend';

  @override
  String get apiKey => 'Cheie API';

  @override
  String get apiKeyHint => 'Cheie de autentificare';

  @override
  String get testConnection => 'Testează conexiunea';

  @override
  String get testing => 'Se testează...';

  @override
  String get connectionSuccessful => 'Conexiune reușită';

  @override
  String get connectionFailed => 'Conexiune eșuată';

  @override
  String get language => 'Limbă';

  @override
  String get selectLanguage => 'Selectează limba';

  @override
  String get english => 'Engleză';

  @override
  String get romanian => 'Română';

  @override
  String get cameraSettings => 'Setări cameră';

  @override
  String get cameraDevice => 'Dispozitiv cameră';

  @override
  String get selectCamera => 'Selectează camera';

  @override
  String get frameRate => 'Rată cadre';

  @override
  String get fps => 'FPS';

  @override
  String get scanDebounce => 'Debounce scanare';

  @override
  String get milliseconds => 'milisecunde';

  @override
  String get scannerBehavior => 'Comportament scanner';

  @override
  String get autoStartScanning => 'Pornire automată scanare';

  @override
  String get autoStartDesc =>
      'Începe scanarea automat la deschiderea ecranului scanner';

  @override
  String get cameraVisible => 'Cameră vizibilă';

  @override
  String get cameraVisibleDesc =>
      'Afișează previzualizarea camerei în timpul scanării';

  @override
  String get audioSettings => 'Setări audio';

  @override
  String get enableAudio => 'Activează feedback audio';

  @override
  String get audioDesc => 'Redă sunete la scanări reușite/eșuate';

  @override
  String get soundVolume => 'Volum sunet';

  @override
  String get dataManagement => 'Gestionare date';

  @override
  String get historyRetention => 'Păstrare istoric';

  @override
  String get days => 'zile';

  @override
  String get exportSettings => 'Setări export';

  @override
  String get exportPath => 'Cale export';

  @override
  String get browse => 'Răsfoiește';

  @override
  String get logSettings => 'Setări log-uri';

  @override
  String get logRetention => 'Păstrare log-uri';

  @override
  String get verboseLogging => 'Log-uri detaliate';

  @override
  String get verboseLoggingDesc => 'Include informații detaliate de debug';

  @override
  String get clearData => 'Șterge date';

  @override
  String get clearHistory => 'Șterge istoric';

  @override
  String get clearHistoryDesc => 'Elimină tot istoricul local de intrări';

  @override
  String get clearLogs => 'Șterge log-uri';

  @override
  String get clearLogsDesc => 'Elimină toate log-urile aplicației';

  @override
  String get applicationInfo => 'Informații aplicație';

  @override
  String get version => 'Versiune';

  @override
  String get buildNumber => 'Număr build';

  @override
  String get launchBehavior => 'Comportament lansare';

  @override
  String get startWithWindows => 'Pornește cu Windows';

  @override
  String get startWithWindowsDesc => 'Lansează aplicația la pornirea Windows';

  @override
  String get save => 'Salvează';

  @override
  String get cancel => 'Anulează';

  @override
  String get close => 'Închide';

  @override
  String get delete => 'Șterge';

  @override
  String get edit => 'Editează';

  @override
  String get export => 'Exportă';

  @override
  String get import => 'Importă';

  @override
  String get refresh => 'Reîmprospătează';

  @override
  String get search => 'Caută';

  @override
  String get filter => 'Filtrează';

  @override
  String get sort => 'Sortează';

  @override
  String get clear => 'Curăță';

  @override
  String get apply => 'Aplică';

  @override
  String get reset => 'Resetează';

  @override
  String get confirm => 'Confirmă';

  @override
  String get back => 'Înapoi';

  @override
  String get next => 'Următorul';

  @override
  String get finish => 'Finalizează';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Da';

  @override
  String get no => 'Nu';

  @override
  String get saveSuccess => 'Setări salvate cu succes';

  @override
  String get saveFailed => 'Salvarea setărilor a eșuat';

  @override
  String get error => 'Eroare';

  @override
  String get warning => 'Avertisment';

  @override
  String get info => 'Informație';

  @override
  String get success => 'Succes';

  @override
  String get loading => 'Se încarcă...';

  @override
  String get pleaseWait => 'Vă rugăm așteptați...';

  @override
  String get noData => 'Nu există date disponibile';

  @override
  String get noResults => 'Nu s-au găsit rezultate';

  @override
  String get loginTitle => 'Autentificare';

  @override
  String get loginSubtitle => 'Conectează-te pentru a accesa MituGym Scanner';

  @override
  String get username => 'Nume utilizator';

  @override
  String get password => 'Parolă';

  @override
  String get login => 'Autentificare';

  @override
  String get loggingIn => 'Se autentifică...';

  @override
  String get loginFailed => 'Autentificare eșuată';

  @override
  String get invalidCredentials => 'Nume utilizator sau parolă invalidă';

  @override
  String get scannerTitle => 'Scanner QR';

  @override
  String get scannerSubtitle =>
      'Scanează coduri QR membre pentru check-in/check-out';

  @override
  String get scanningActive => 'Scanare activă';

  @override
  String get scanningPaused => 'Scanare întreruptă';

  @override
  String get startScanning => 'Începe scanarea';

  @override
  String get stopScanning => 'Oprește scanarea';

  @override
  String get scanSuccess => 'Scanare reușită';

  @override
  String get scanFailed => 'Scanare eșuată';

  @override
  String get invalidQRCode => 'Cod QR invalid';

  @override
  String get processingQRCode => 'Se procesează cod QR...';

  @override
  String get memberDetails => 'Detalii membru';

  @override
  String get memberInfo => 'Informații membru';

  @override
  String get fullName => 'Nume complet';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Telefon';

  @override
  String get dateOfBirth => 'Data nașterii';

  @override
  String get address => 'Adresă';

  @override
  String get city => 'Oraș';

  @override
  String get county => 'Județ';

  @override
  String get gender => 'Gen';

  @override
  String get membershipInfo => 'Informații abonament';

  @override
  String get membershipStatus => 'Status abonament';

  @override
  String get currentPlan => 'Abonament curent';

  @override
  String get startDate => 'Data început';

  @override
  String get expiryDate => 'Data expirare';

  @override
  String get daysRemaining => 'Zile rămase';

  @override
  String daysRemainingCount(int count) {
    return '$count zile rămase';
  }

  @override
  String get offline => 'Offline';

  @override
  String get online => 'Online';

  @override
  String get offlineMode => 'Mod Offline';

  @override
  String get offlineModeDesc =>
      'Lucrezi offline - datele se vor sincroniza când conexiunea va fi restabilită';

  @override
  String get syncPending => 'Sincronizare în așteptare';

  @override
  String syncPendingCount(int count) {
    return '$count acțiuni în așteptare pentru sincronizare';
  }

  @override
  String get today => 'Astăzi';

  @override
  String get yesterday => 'Ieri';

  @override
  String get thisWeek => 'Această săptămână';

  @override
  String get thisMonth => 'Luna aceasta';

  @override
  String get lastMonth => 'Luna trecută';

  @override
  String get customRange => 'Interval personalizat';

  @override
  String get selectDateRange => 'Selectează interval de date';

  @override
  String get from => 'De la';

  @override
  String get to => 'Până la';

  @override
  String get exportData => 'Exportă date';

  @override
  String get exportHistory => 'Exportă istoric';

  @override
  String get exportMembers => 'Exportă membri';

  @override
  String get exportFormat => 'Format export';

  @override
  String get csvFormat => 'CSV';

  @override
  String get pdfFormat => 'PDF';

  @override
  String get excelFormat => 'Excel';

  @override
  String get exportSuccess => 'Export reușit';

  @override
  String get exportFailed => 'Export eșuat';

  @override
  String exportLocation(String path) {
    return 'Exportat în: $path';
  }

  @override
  String get setExportPath => 'Setează calea de export';

  @override
  String get selectFolderPath =>
      'Selectează sau introdu calea către folderul unde vor fi salvate fișierele exportate:';

  @override
  String get enterPath => 'Introdu calea manual';

  @override
  String get selectFolder => 'Selectează folder';

  @override
  String get welcomeBack => 'BINE AI REVENIT';

  @override
  String get logout => 'Deconectare';

  @override
  String get apiUrlNotConfigured => 'URL-ul API nu este configurat';

  @override
  String get cameraPreview => 'Previzualizare cameră';

  @override
  String get readyToScan => 'Pregătit pentru scanare';

  @override
  String get accessGranted => 'Acces acordat';

  @override
  String get waitingForScan => 'Se așteaptă scanarea...';

  @override
  String get scanQRPrompt =>
      'Scanați un cod QR pentru a vedea detaliile membrului';

  @override
  String get scanningStopped => 'Scanare oprită';

  @override
  String get readyToScanEllipsis => 'Pregătit pentru scanare...';

  @override
  String get processing => 'Se procesează...';

  @override
  String get initializingCamera => 'Se inițializează camera...';

  @override
  String get cameraStarting => 'Camera pornește...';

  @override
  String get pressStartToBegin => 'Apăsați START pentru a începe';

  @override
  String get scanSuccessful => 'Scanare reușită';

  @override
  String get scanFailedTitle => 'Scanare eșuată';

  @override
  String get checkInSuccessful => 'Check-in reușit';

  @override
  String get checkOutSuccessful => 'Check-out reușit';

  @override
  String get cooldownActive => 'Pauză activă';

  @override
  String get pleaseWaitBeforeNextScan =>
      'Vă rugăm așteptați înainte de următoarea scanare';
}
