@echo off
REM Test USB Scanner (Windows Batch Script)
REM Simulates a USB scanner scan

if "%~1"=="" (
    echo ================================================================
    echo USB Scanner Test Client
    echo ================================================================
    echo.
    echo Usage: test_usb_scan.bat ^<QR_CODE^>
    echo.
    echo Example: test_usb_scan.bat MEMBER12345
    echo.
    pause
    exit /b 1
)

echo ================================================================
echo Simulating USB scan...
echo ================================================================
echo QR Code: %~1
echo.

dart run tools/usb_scanner_test_client.dart %~1

echo.
pause
