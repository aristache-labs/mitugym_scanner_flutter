; MituGym Scanner - Inno Setup Installer Script
; This script creates a professional Windows installer for your Flutter app

#define MyAppName "MituGym Scanner"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "MituGym"
#define MyAppURL "https://mitugym-app-webpanel.vercel.app"
#define MyAppExeName "mitugym_scanner_flutter.exe"
#define MyAppId "{{8B5F2E1A-9C3D-4F7B-A2E6-1D4C8F9A3B5E}"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
AppId={#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
; Installer output
OutputDir=Output
OutputBaseFilename=MituGymScanner_Setup_{#MyAppVersion}
; App icon - using logo.ico for the installer
SetupIconFile=assets\images\logo.ico
; Compression
Compression=lzma2/ultra64
SolidCompression=yes
; Windows version requirements
MinVersion=10.0.17763
; Architecture
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
; Privileges
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
; Wizard style
WizardStyle=modern
; Uninstall
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}
; License (optional - uncomment if you have a license file)
; LicenseFile=LICENSE.txt

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode

[Files]
; Main executable
Source: "build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

; Flutter DLL
Source: "build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion

; Data folder (Flutter assets)
Source: "build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; All other DLL files and dependencies
Source: "build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion

; ICU data file
Source: "build\windows\x64\runner\Release\icudtl.dat"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist

; Copy logo.ico to the app folder for use as app icon
Source: "assets\images\logo.ico"; DestDir: "{app}"; Flags: ignoreversion

; Visual C++ Redistributable (will be installed automatically)
Source: "VC_redist.x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall

; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
; Start Menu shortcuts - using logo.ico
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\logo.ico"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

; Desktop shortcut (if task is selected) - using logo.ico
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\logo.ico"; Tasks: desktopicon

; Quick Launch shortcut (if task is selected) - using logo.ico
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\logo.ico"; Tasks: quicklaunchicon

[Run]
; Install/Repair Visual C++ Redistributable (always run to ensure correct version)
Filename: "{tmp}\VC_redist.x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "Installing Visual C++ Redistributable..."; Flags: waituntilterminated

; Option to launch the app after installation
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
// Custom code for advanced functionality

// Check if app is already running during installation
function InitializeSetup(): Boolean;
var
  ResultCode: Integer;
begin
  Result := True;
  
  // Check if the app is running
  if CheckForMutexes('{#MyAppId}') then
  begin
    if MsgBox('MituGym Scanner is currently running. Please close it before continuing the installation.' + #13#10 + #13#10 + 
              'Click OK to close the application and continue, or Cancel to exit setup.', 
              mbConfirmation, MB_OKCANCEL) = IDOK then
    begin
      // Try to close the application gracefully
      if Exec('taskkill', '/F /IM {#MyAppExeName}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
      begin
        Sleep(1000); // Wait a bit for the process to close
        Result := True;
      end
      else
      begin
        MsgBox('Could not close the application. Please close it manually and run the installer again.', mbError, MB_OK);
        Result := False;
      end;
    end
    else
    begin
      Result := False;
    end;
  end;
end;

// Note: Visual C++ Redistributable is always installed/repaired during setup
// This ensures the correct version (2015-2022) is present and fixes compatibility issues

// Custom page to show installation progress with details
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Perform any post-installation tasks here
    // For example, register file associations, etc.
  end;
end;

// Uninstallation confirmation
function InitializeUninstall(): Boolean;
begin
  Result := MsgBox('Are you sure you want to completely remove ' + '{#MyAppName}' + ' and all of its components?', 
                   mbConfirmation, MB_YESNO) = IDYES;
end;

// Cleanup on uninstall
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  DocumentsPath: String;
  AppDataPath: String;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    // Ask user if they want to remove all user data and settings
    if MsgBox('Do you want to remove all application data and settings?' + #13#10#13#10 +
              'This will delete:' + #13#10 +
              '- Documents\MituGym Scanner' + #13#10 +
              '- Documents\mitugym_logs' + #13#10 +
              '- Documents\mitugym_offline.db' + #13#10 +
              '- AppData\Roaming\com.mitugym', 
              mbConfirmation, MB_YESNO) = IDYES then
    begin
      DocumentsPath := ExpandConstant('{userdocs}');
      AppDataPath := ExpandConstant('{userappdata}');
      
      // Remove Documents\MituGym Scanner folder
      DelTree(DocumentsPath + '\MituGym Scanner', True, True, True);
      
      // Remove Documents\mitugym_logs folder
      DelTree(DocumentsPath + '\mitugym_logs', True, True, True);
      
      // Remove Documents\mitugym_offline.db file
      DeleteFile(DocumentsPath + '\mitugym_offline.db');
      
      // Remove AppData\Roaming\com.mitugym folder
      DelTree(AppDataPath + '\com.mitugym', True, True, True);
    end;
  end;
end;

[Registry]
; Optional: Register file associations or registry keys
; Example: Associate .mgscan files with your app
; Root: HKCR; Subkey: ".mgscan"; ValueType: string; ValueName: ""; ValueData: "MituGymScanFile"; Flags: uninsdeletevalue
; Root: HKCR; Subkey: "MituGymScanFile"; ValueType: string; ValueName: ""; ValueData: "MituGym Scan File"; Flags: uninsdeletekey
; Root: HKCR; Subkey: "MituGymScanFile\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\logo.ico,0"
; Root: HKCR; Subkey: "MituGymScanFile\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""

[UninstallDelete]
; Clean up any files that were created during runtime
Type: filesandordirs; Name: "{app}\logs"
Type: filesandordirs; Name: "{app}\cache"

