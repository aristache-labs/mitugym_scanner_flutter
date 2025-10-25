@echo off
REM Start USB Scanner Daemon (Windows Batch Script)
REM This script starts the USB scanner daemon in mock mode

echo ================================================================
echo USB Scanner Daemon Starter
echo ================================================================
echo.

REM Check if Dart is installed
where dart >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Dart is not installed or not in PATH
    echo Please install Flutter/Dart first
    echo.
    pause
    exit /b 1
)

echo Starting USB Scanner Daemon in MOCK mode...
echo.
echo Press Ctrl+C to stop the daemon
echo ================================================================
echo.

REM Start the daemon
dart run lib/services/usb_scanner_daemon.dart

pause
