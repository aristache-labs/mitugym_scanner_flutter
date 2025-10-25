# PowerShell Script for USB Scanner Testing
# More powerful alternative to batch scripts

param(
    [Parameter(Mandatory=$false)]
    [string]$Command = "help",
    
    [Parameter(Mandatory=$false)]
    [string]$QrCode = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Host = "localhost",
    
    [Parameter(Mandatory=$false)]
    [int]$Port = 9877
)

function Show-Help {
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "USB Scanner Test Utility (PowerShell)" -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "COMMANDS:" -ForegroundColor Yellow
    Write-Host "  scan <QR_CODE>    - Simulate a single scan"
    Write-Host "  multi             - Simulate multiple scans in sequence"
    Write-Host "  stress <COUNT>    - Stress test with multiple rapid scans"
    Write-Host "  daemon            - Start the daemon"
    Write-Host "  help              - Show this help"
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\usb_scanner_test.ps1 scan MEMBER12345"
    Write-Host "  .\usb_scanner_test.ps1 multi"
    Write-Host "  .\usb_scanner_test.ps1 stress 10"
    Write-Host "  .\usb_scanner_test.ps1 daemon"
    Write-Host ""
}

function Start-Daemon {
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "Starting USB Scanner Daemon" -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
    Write-Host ""
    
    dart run lib/services/usb_scanner_daemon.dart
}

function Send-Scan {
    param([string]$Code)
    
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "Simulating USB Scan" -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "QR Code: $Code" -ForegroundColor White
    Write-Host ""
    
    dart run tools/usb_scanner_test_client.dart $Code --host $Host --port $Port
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "[SUCCESS] Scan sent successfully" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "[ERROR] Failed to send scan" -ForegroundColor Red
    }
}

function Start-MultiScan {
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "Multiple Scan Simulation" -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    $codes = @("MEMBER001", "MEMBER002", "MEMBER003")
    
    foreach ($code in $codes) {
        Write-Host "Scanning: $code" -ForegroundColor Yellow
        Send-Scan $code
        Write-Host ""
        Write-Host "Waiting 6 seconds (debounce period)..." -ForegroundColor Gray
        Start-Sleep -Seconds 6
        Write-Host ""
    }
    
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "All scans completed!" -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor Cyan
}

function Start-StressTest {
    param([int]$Count)
    
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "Stress Test - $Count scans" -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "WARNING: This will send scans rapidly!" -ForegroundColor Yellow
    Write-Host "Most will be debounced by the service." -ForegroundColor Yellow
    Write-Host ""
    
    for ($i = 1; $i -le $Count; $i++) {
        $code = "STRESS{0:D4}" -f $i
        Write-Host "[$i/$Count] Sending: $code" -ForegroundColor Yellow
        
        try {
            $client = New-Object System.Net.Sockets.TcpClient($Host, $Port)
            $stream = $client.GetStream()
            $writer = New-Object System.IO.StreamWriter($stream)
            $writer.WriteLine("SCAN:$code")
            $writer.Flush()
            $client.Close()
            Write-Host "  [OK]" -ForegroundColor Green
        } catch {
            Write-Host "  [FAILED] $_" -ForegroundColor Red
        }
        
        Start-Sleep -Milliseconds 100
    }
    
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "Stress test completed!" -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor Cyan
}

# Main execution
switch ($Command.ToLower()) {
    "scan" {
        if ($QrCode -eq "") {
            Write-Host "ERROR: QR code is required" -ForegroundColor Red
            Write-Host "Usage: .\usb_scanner_test.ps1 scan <QR_CODE>" -ForegroundColor Yellow
            exit 1
        }
        Send-Scan $QrCode
    }
    "multi" {
        Start-MultiScan
    }
    "stress" {
        $count = if ($QrCode -ne "") { [int]$QrCode } else { 10 }
        Start-StressTest $count
    }
    "daemon" {
        Start-Daemon
    }
    "help" {
        Show-Help
    }
    default {
        Show-Help
    }
}
