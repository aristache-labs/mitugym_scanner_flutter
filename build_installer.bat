@echo off
REM MituGym Scanner - Simple Installer Builder
REM Double-click this file to build your installer

echo =========================================
echo    MituGym Scanner Installer Builder
echo =========================================
echo.

REM Check if PowerShell is available
where powershell >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PowerShell not found!
    echo Please install PowerShell or run the build manually.
    pause
    exit /b 1
)

echo Choose installer type:
echo.
echo 1. Inno Setup (Traditional .exe installer) - RECOMMENDED
echo 2. MSIX (Modern Windows package)
echo 3. Build all types
echo.

set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" (
    echo.
    echo Building Inno Setup installer...
    powershell -ExecutionPolicy Bypass -File build_installer.ps1 -InstallerType inno
) else if "%choice%"=="2" (
    echo.
    echo Building MSIX package...
    powershell -ExecutionPolicy Bypass -File build_installer.ps1 -InstallerType msix
) else if "%choice%"=="3" (
    echo.
    echo Building all installer types...
    powershell -ExecutionPolicy Bypass -File build_installer.ps1 -InstallerType all
) else (
    echo.
    echo Invalid choice! Please run again and select 1, 2, or 3.
    pause
    exit /b 1
)

echo.
echo =========================================
echo.

if %ERRORLEVEL% EQU 0 (
    echo SUCCESS! Installer created in the Output folder.
    echo.
    echo Opening Output folder...
    start "" "%CD%\Output"
) else (
    echo.
    echo ERROR: Build failed. Check the messages above for details.
)

echo.
pause

