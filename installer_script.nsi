; MituGym Scanner - NSIS Installer Script
; Nullsoft Scriptable Install System (NSIS)
; Download NSIS from: https://nsis.sourceforge.io/Download

!define APP_NAME "MituGym Scanner"
!define APP_VERSION "1.0.0"
!define COMPANY_NAME "MituGym"
!define APP_EXECUTABLE "mitugym_scanner_flutter.exe"
!define APP_GUID "{8B5F2E1A-9C3D-4F7B-A2E6-1D4C8F9A3B5E}"

; Modern UI
!include "MUI2.nsh"
!include "FileFunc.nsh"

; General Settings
Name "${APP_NAME}"
OutFile "Output\MituGymScanner_Setup_${APP_VERSION}.exe"
InstallDir "$PROGRAMFILES64\${APP_NAME}"
InstallDirRegKey HKLM "Software\${COMPANY_NAME}\${APP_NAME}" "InstallDir"
RequestExecutionLevel admin

; Branding
BrandingText "${APP_NAME} v${APP_VERSION}"

; Interface Settings
!define MUI_ABORTWARNING
!define MUI_ICON "windows\runner\resources\app_icon.ico"
!define MUI_UNICON "windows\runner\resources\app_icon.ico"
!define MUI_HEADERIMAGE
!define MUI_WELCOMEFINISHPAGE_BITMAP "windows\runner\resources\app_icon.ico"
!define MUI_FINISHPAGE_RUN "$INSTDIR\${APP_EXECUTABLE}"
!define MUI_FINISHPAGE_RUN_TEXT "Launch ${APP_NAME}"

; Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt" ; Optional - create if you have one
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Languages
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Romanian"

; Version Information
VIProductVersion "${APP_VERSION}.0"
VIAddVersionKey "ProductName" "${APP_NAME}"
VIAddVersionKey "CompanyName" "${COMPANY_NAME}"
VIAddVersionKey "FileVersion" "${APP_VERSION}"
VIAddVersionKey "LegalCopyright" "Copyright (C) 2025 ${COMPANY_NAME}"
VIAddVersionKey "FileDescription" "${APP_NAME} Installer"

; Installer Sections
Section "MainSection" SEC01
  ; Set output path
  SetOutPath "$INSTDIR"
  
  ; Main executable
  File "build\windows\x64\runner\Release\${APP_EXECUTABLE}"
  
  ; Flutter DLL
  File "build\windows\x64\runner\Release\flutter_windows.dll"
  
  ; All DLL files
  File "build\windows\x64\runner\Release\*.dll"
  
  ; ICU data
  File /nonfatal "build\windows\x64\runner\Release\icudtl.dat"
  
  ; Data folder (Flutter assets)
  SetOutPath "$INSTDIR\data"
  File /r "build\windows\x64\runner\Release\data\*.*"
  
  ; Create shortcuts
  SetOutPath "$INSTDIR"
  CreateDirectory "$SMPROGRAMS\${APP_NAME}"
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\${APP_EXECUTABLE}"
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
  CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${APP_EXECUTABLE}"
  
  ; Registry entries
  WriteRegStr HKLM "Software\${COMPANY_NAME}\${APP_NAME}" "InstallDir" "$INSTDIR"
  WriteRegStr HKLM "Software\${COMPANY_NAME}\${APP_NAME}" "Version" "${APP_VERSION}"
  
  ; Uninstaller registry entries
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayName" "${APP_NAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayIcon" "$INSTDIR\${APP_EXECUTABLE}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "Publisher" "${COMPANY_NAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayVersion" "${APP_VERSION}"
  
  ; Get install size
  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "EstimatedSize" "$0"
  
  ; Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

; Uninstaller Section
Section "Uninstall"
  ; Delete files
  Delete "$INSTDIR\${APP_EXECUTABLE}"
  Delete "$INSTDIR\*.dll"
  Delete "$INSTDIR\icudtl.dat"
  Delete "$INSTDIR\Uninstall.exe"
  
  ; Delete data folder
  RMDir /r "$INSTDIR\data"
  
  ; Delete shortcuts
  Delete "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk"
  Delete "$SMPROGRAMS\${APP_NAME}\Uninstall.lnk"
  Delete "$DESKTOP\${APP_NAME}.lnk"
  RMDir "$SMPROGRAMS\${APP_NAME}"
  
  ; Delete registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
  DeleteRegKey HKLM "Software\${COMPANY_NAME}\${APP_NAME}"
  DeleteRegKey /ifempty HKLM "Software\${COMPANY_NAME}"
  
  ; Remove install directory
  RMDir "$INSTDIR"
  
  ; Ask to delete user data
  MessageBox MB_YESNO "Do you want to remove all user data and settings?" IDNO +2
  RMDir /r "$LOCALAPPDATA\${COMPANY_NAME}\${APP_NAME}"
SectionEnd

; Functions

; Check if app is running before install
Function .onInit
  System::Call 'kernel32::CreateMutex(i 0, i 0, t "${APP_GUID}") i .r1 ?e'
  Pop $R0
  
  StrCmp $R0 0 +3
    MessageBox MB_OK|MB_ICONEXCLAMATION "The installer is already running."
    Abort
    
  ; Check if app is running
  FindWindow $0 "" "${APP_NAME}"
  StrCmp $0 0 continueInstall
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
      "${APP_NAME} is currently running. Please close it before continuing the installation." \
      IDOK tryClose
      Abort
  
  tryClose:
    ; Try to close gracefully
    SendMessage $0 ${WM_CLOSE} 0 0
    Sleep 1000
    
    ; Check if still running
    FindWindow $0 "" "${APP_NAME}"
    StrCmp $0 0 continueInstall
      MessageBox MB_OK|MB_ICONEXCLAMATION "Could not close ${APP_NAME}. Please close it manually and run the installer again."
      Abort
  
  continueInstall:
FunctionEnd

; Description text
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC01} "Install ${APP_NAME} application files"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

