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
  String get plan => 'ABONAMENT';

  @override
  String get expires => 'EXPIRĂ';

  @override
  String get status => 'STARE';

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
  String get pending => 'În așteptare';

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
  String get searchByName => 'Caută după nume...';

  @override
  String get noMembersFound => 'Niciun Membru Găsit';

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
  String get scanner => 'Scaner';

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
  String get frameRate => 'Rata de cadre';

  @override
  String get fps => 'FPS';

  @override
  String get scanDebounce => 'Debounce scanare';

  @override
  String get milliseconds => 'milisecunde';

  @override
  String get scannerBehavior => 'Comportament scanner';

  @override
  String get autoStartScanning => 'Pornește scanarea automat';

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
  String get dataManagement => 'Gestionare Date';

  @override
  String get historyRetention => 'Păstrare istoric';

  @override
  String get days => 'zile';

  @override
  String get exportSettings => 'Setări Export';

  @override
  String get exportPath => 'Cale export';

  @override
  String get browse => 'Răsfoiește';

  @override
  String get logSettings => 'Setări log-uri';

  @override
  String get logRetention => 'Păstrare jurnale';

  @override
  String get verboseLogging => 'Jurnalizare detaliată';

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
  String get clear => 'Șterge';

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
  String get success => 'SUCCES';

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
  String get scannerSubtitle => 'Scanează coduri QR pentru check-in/check-out';

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
  String get offline => 'OFFLINE';

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
  String get thisMonth => 'Luna Asta';

  @override
  String get lastMonth => 'Luna Trecută';

  @override
  String get customRange => 'Interval personalizat';

  @override
  String get selectDateRange => 'Selectează Interval';

  @override
  String from(String date) {
    return 'De la $date...';
  }

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
  String exportFailed(String error) {
    return 'Export eșuat: $error';
  }

  @override
  String exportLocation(String path) {
    return 'Exportat în: $path';
  }

  @override
  String get setExportPath => 'Setează calea de export';

  @override
  String get selectFolderPath =>
      'Selectează sau introdu calea folderului unde vor fi salvate fișierele de export:';

  @override
  String get enterPath => 'Introdu calea manual';

  @override
  String get selectFolder => 'Selectează folder';

  @override
  String get welcomeBack => 'BINE AI REVENIT';

  @override
  String get logout => 'Deconectare';

  @override
  String get logoutTitle => 'Deconectare';

  @override
  String get logoutConfirmMessage =>
      'Sigur doriți să vă deconectați? Va trebui să vă autentificați din nou pentru a utiliza aplicația.';

  @override
  String get logoutDisabledTitle => 'Deconectare Dezactivată';

  @override
  String get logoutDisabledMessage =>
      'Nu puteți să vă deconectați când sunteți offline. Vă rugăm să vă conectați la internet înainte de a vă deconecta.\n\nAceasta vă împiedică să fiți blocat din aplicație, deoarece autentificarea necesită o conexiune la internet.';

  @override
  String get apiUrlNotConfigured => 'URL-ul API nu este configurat';

  @override
  String get staffPortal => 'Portal Personal';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'PAROLĂ';

  @override
  String get pleaseEnterEmail => 'Vă rugăm să introduceți email-ul';

  @override
  String get pleaseEnterValidEmail => 'Vă rugăm să introduceți un email valid';

  @override
  String get pleaseEnterPassword => 'Vă rugăm să introduceți parola';

  @override
  String get passwordMinLength =>
      'Parola trebuie să aibă cel puțin 6 caractere';

  @override
  String get rememberMe => 'Ține-mă minte';

  @override
  String get signIn => 'Autentificare';

  @override
  String get needAccessContact => 'Aveți nevoie de acces? Contactați';

  @override
  String get offlineLoginAvailable =>
      'Sunteți offline. Autentificare offline disponibilă pentru utilizatori anteriori.';

  @override
  String get offlineFirstLoginRequired =>
      'Sunteți offline. Vă rugăm să vă conectați la internet pentru prima autentificare.';

  @override
  String get firstLoginOnlineRequired =>
      'Trebuie să fiți online pentru prima autentificare. După ce v-ați autentificat cu succes, puteți să vă autentificați offline.';

  @override
  String offlineLoginFailed(String error) {
    return 'Autentificare offline eșuată: $error';
  }

  @override
  String loginFailedError(String error) {
    return 'Autentificare eșuată: $error';
  }

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

  @override
  String get peakHours => 'Ore de vârf';

  @override
  String get morning => 'Dimineața';

  @override
  String get afternoon => 'După-amiază';

  @override
  String get evening => 'Seara';

  @override
  String get noDataYet => 'Nicio dată încă';

  @override
  String get liveGymOccupancy =>
      'Ocuparea sălii în timp real pe parcursul zilei';

  @override
  String get liveOccupancy => 'Ocupare în timp real';

  @override
  String get futureHours => 'Ore viitoare';

  @override
  String get people => 'persoane';

  @override
  String get person => 'persoană';

  @override
  String get todaysTraffic => 'Traficul de azi';

  @override
  String get peak => 'Vârf: ';

  @override
  String get updatesEveryHour => 'Actualizare la fiecare oră';

  @override
  String get successRate => 'Rata de succes';

  @override
  String get csvDescription => 'Valori separate prin virgulă';

  @override
  String get pdfDescription => 'Format document portabil';

  @override
  String get txtDescription => 'Fișier text simplu';

  @override
  String exportedTo(String format, String path) {
    return 'Exportat $format la: $path';
  }

  @override
  String showingOfTotal(int filtered, int total) {
    return 'Se afișează $filtered din $total';
  }

  @override
  String get all => 'Toate';

  @override
  String get pickDate => 'Alege Data';

  @override
  String get dateRange => 'Interval Date';

  @override
  String get selectStartDate => 'Selectează data de început';

  @override
  String get applyFilter => 'Aplică Filtru';

  @override
  String get last7Days => 'Ultimele 7 Zile';

  @override
  String get last30Days => 'Ultimele 30 Zile';

  @override
  String searchError(String error) {
    return 'Eroare căutare: $error';
  }

  @override
  String get noMembersToExport => 'Niciun membru de exportat';

  @override
  String get searchByNameMembers => 'Caută după nume...';

  @override
  String get noMembersYet => 'Niciun Membru Încă';

  @override
  String get scanMemberQRToBuild =>
      'Scanează coduri QR pentru a construi baza de date';

  @override
  String get tryAdjustingFilters =>
      'Încearcă să ajustezi căutarea sau filtrele';

  @override
  String memberFound(int count) {
    return '$count membru găsit';
  }

  @override
  String membersFound(int count) {
    return '$count membri găsiți';
  }

  @override
  String get display => 'Afișare';

  @override
  String get audio => 'Audio';

  @override
  String get advanced => 'Avansat';

  @override
  String get saveSettings => 'Salvează Setări';

  @override
  String get settingsSavedSuccessfully => 'Setări salvate cu succes';

  @override
  String get apiConnection => 'Conexiune API';

  @override
  String get manageApiConnection => 'Gestionează conexiunea API';

  @override
  String get enterApiKey => 'Introdu cheia API';

  @override
  String get applicationPreferences => 'Preferințe Aplicație';

  @override
  String get startupBehaviorSettings => 'Setări pornire și comportament';

  @override
  String get selectPreferredLanguage => 'Selectează limba preferată';

  @override
  String get launchAutomatically => 'Lansează automat când pornește Windows';

  @override
  String get camera => 'Cameră';

  @override
  String get deviceCaptureSettings => 'Setări dispozitiv și captură';

  @override
  String get device => 'Dispozitiv';

  @override
  String get qrCodeScanningBehavior => 'Comportament scanare cod QR';

  @override
  String get scanCooldown => 'Pauză scanare';

  @override
  String get displayPreferences => 'Preferințe Afișare';

  @override
  String get cameraUISettings => 'Setări cameră și interfață';

  @override
  String get showCameraByDefault => 'Afișează camera implicit';

  @override
  String get displayCameraPreview =>
      'Afișează previzualizarea camerei pe ecranul de scanare';

  @override
  String get beginScanningOnLaunch =>
      'Începe scanarea când se lansează aplicația';

  @override
  String get soundSettings => 'Setări Sunet';

  @override
  String get audioFeedbackConfig => 'Configurare feedback audio';

  @override
  String get enableAudioFeedback => 'Activează feedback audio';

  @override
  String get playSoundWhenScanning => 'Redă sunet la scanarea codurilor QR';

  @override
  String get volume => 'Volum';

  @override
  String get moreAudioSettingsComingSoon => 'Mai multe setări audio\nîn curând';

  @override
  String get logDataRetentionSettings => 'Setări păstrare jurnale și date';

  @override
  String get configureExportLocation =>
      'Configurează locația fișierelor de export';

  @override
  String get usingDefaultLocation => 'Se folosește locația implicită';

  @override
  String get leaveEmptyForDefault =>
      'Lasă gol pentru a folosi locația implicită';

  @override
  String get logging => 'Jurnalizare';

  @override
  String get appLoggingConfig => 'Configurare jurnalizare aplicație';

  @override
  String get saveDebugLogs =>
      'Salvează jurnale de depanare, avertizări și trasare';

  @override
  String get helpfulForTroubleshooting => 'Util pentru depanare';

  @override
  String get historyManagement => 'Gestionare Istoric';

  @override
  String get scanHistorySyncSettings =>
      'Setări istoric scanare și sincronizare';

  @override
  String totalRecords(int count) {
    return 'Total Înregistrări: $count';
  }

  @override
  String lastSynced(String date) {
    return 'Ultima Sincronizare: $date';
  }

  @override
  String get cleanupOldHistory => 'Curăță Istoric Vechi';

  @override
  String get cleanup => 'Curăță';

  @override
  String get syncing => 'Se sincronizează...';

  @override
  String get syncAllDataFromServer => 'Sincronizează Toate Datele de pe Server';

  @override
  String get syncingFromServer => 'Se sincronizează datele de pe server...';

  @override
  String syncError(String error) {
    return 'Eroare sincronizare: $error';
  }

  @override
  String syncFailed(String error) {
    return 'Sincronizare eșuată: $error';
  }

  @override
  String get confirmDeletion => 'Confirmă ștergerea';

  @override
  String cleanupWarningMessage(int days) {
    return 'Această acțiune va șterge definitiv toate înregistrările din istoric mai vechi de $days zile. Această operațiune nu poate fi anulată.';
  }

  @override
  String get apiTestResults => 'Rezultate Test API';

  @override
  String get endpointStatus => 'STARE ENDPOINT-URI';

  @override
  String records(int count) {
    return 'Înregistrări: $count';
  }

  @override
  String get healthy => 'SĂNĂTOS';

  @override
  String get degraded => 'DEGRADAT';

  @override
  String get gymSchedule => 'PROGRAM SALĂ';

  @override
  String get history => 'ISTORIC';

  @override
  String get checkin => 'INTRARE';

  @override
  String get reachable => 'ACCESIBIL';

  @override
  String get endpointIsOperational => 'Endpoint-ul este operațional';

  @override
  String get testingApiEndpoints => 'Se testează endpoint-urile API...';

  @override
  String get failedToFetchGymSchedule =>
      'Eșec la obținerea programului sălii - a returnat null';

  @override
  String get failedToFetchHistory => 'Eșec la obținerea istoricului';

  @override
  String get endpointNotFound =>
      'Endpoint nu a fost găsit (404) - verifică URL-ul API';

  @override
  String serverError(int code) {
    return 'Eroare server ($code)';
  }

  @override
  String endpointResponded(int code) {
    return 'Endpoint-ul a răspuns ($code)';
  }

  @override
  String get endpointReachableButKeyInvalid =>
      'Endpoint accesibil dar cheia API poate fi invalidă';

  @override
  String get stateEndpointUri => 'STARE ENDPOINT-URI';

  @override
  String dioExceptionBadResponse(int code) {
    return 'Răspuns invalid: Cod status $code';
  }

  @override
  String get dioException404 =>
      'Endpoint nu a fost găsit (404) - Resursa solicitată nu există';

  @override
  String get dioExceptionConnectionTimeout =>
      'Timeout conexiune - Serverul a durat prea mult să răspundă';

  @override
  String get dioExceptionReceiveTimeout =>
      'Timeout recepție - Transferul de date a durat prea mult';

  @override
  String get dioExceptionConnectionError =>
      'Eroare conexiune - Nu se poate conecta la server';

  @override
  String get dioExceptionUnknown => 'Eroare de rețea';

  @override
  String get tapToEnlarge => 'Apasă pentru a mări';

  @override
  String get membership => 'ABONAMENT';

  @override
  String get contactAndAddress => 'CONTACT & ADRESĂ';

  @override
  String get planLabel => 'Abonament';

  @override
  String get expiresLabel => 'Expiră';

  @override
  String get birthDateLabel => 'Data nașterii';

  @override
  String get phoneLabel => 'Telefon';

  @override
  String get addressLabel => 'Adresă';

  @override
  String get noContactInformation => 'Fără informații de contact';

  @override
  String get notProvided => 'Necompletat';

  @override
  String get viewFullProfile => 'Vezi Profilul Complet';

  @override
  String couldNotOpenProfile(String url) {
    return 'Nu s-a putut deschide profilul: $url';
  }

  @override
  String errorOpeningProfile(String error) {
    return 'Eroare la deschiderea profilului: $error';
  }

  @override
  String get exportMemberName => 'Nume Membru';

  @override
  String get exportCheckedIn => 'Ora Intrării';

  @override
  String get exportCheckedOut => 'Ora Ieșirii';

  @override
  String get exportDuration => 'Durată';

  @override
  String get exportPlanExpired => 'Abonament Expirat';

  @override
  String get exportAccessDenied => 'Acces Refuzat';

  @override
  String get exportActiveSession => 'Sesiune Activă';

  @override
  String get exportDenied => 'Refuzat';

  @override
  String get exportInProgress => 'În Curs';

  @override
  String get exportActivityReport => 'Raport Activitate';

  @override
  String get exportGenerated => 'Generat';

  @override
  String get exportTime => 'Ora';

  @override
  String get exportTotalActivities => 'Total Activități';

  @override
  String get exportStatistics => 'Statistici';

  @override
  String get exportSuccessful => 'Reușit';

  @override
  String get exportFailedLabel => 'Eșuat';

  @override
  String get exportSuccessRate => 'Rata de Succes';

  @override
  String get exportActivityLog => 'Jurnal Activitate';

  @override
  String get exportPage => 'Pagina';

  @override
  String get exportOf => 'din';

  @override
  String get exportEndOfReport => 'Sfârșit Raport';

  @override
  String get exportMembersList => 'Listă Membri';

  @override
  String get exportTotalMembers => 'Total Membri';

  @override
  String get exportActive => 'Activ';

  @override
  String get exportInactive => 'Inactiv';

  @override
  String get exportMembersDirectory => 'Director Membri';

  @override
  String get exportName => 'Nume';

  @override
  String get exportPlan => 'Abonament';

  @override
  String get exportStatus => 'Stare';

  @override
  String get exportExpires => 'Expiră';

  @override
  String get exportContact => 'Contact';

  @override
  String get exportEmail => 'Email';

  @override
  String get exportMemberId => 'ID Membru';

  @override
  String get exportGender => 'Gen';

  @override
  String get exportDateOfBirth => 'Data Nașterii';

  @override
  String get exportAddress => 'Adresă';

  @override
  String get exportPhone => 'Telefon';
}
