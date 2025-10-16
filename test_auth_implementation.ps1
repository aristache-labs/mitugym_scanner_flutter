# =====================================================
# Testing Script for Login Authentication System
# Run this in PowerShell
# =====================================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Login Authentication Testing Script" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Configuration
$API_URL = "https://mitugym-app-webpanel.vercel.app"
$TEST_EMAIL = Read-Host "Enter test email"
$TEST_PASSWORD = Read-Host "Enter test password" -AsSecureString
$TEST_PASSWORD_PLAIN = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($TEST_PASSWORD))

# =====================================================
# Step 1: Test Login API
# =====================================================
Write-Host "`n[Step 1] Testing Login API..." -ForegroundColor Yellow

$loginBody = @{
    email = $TEST_EMAIL
    password = $TEST_PASSWORD_PLAIN
    device_name = "PowerShell Test"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$API_URL/api/auth/login" `
        -Method Post `
        -ContentType "application/json" `
        -Body $loginBody
    
    if ($loginResponse.success) {
        Write-Host "✅ Login successful!" -ForegroundColor Green
        Write-Host "   API Key: $($loginResponse.api_key.Substring(0,20))..." -ForegroundColor Gray
        Write-Host "   User: $($loginResponse.user_name)" -ForegroundColor Gray
        Write-Host "   Location: $($loginResponse.location_name)" -ForegroundColor Gray
        
        $API_KEY = $loginResponse.api_key
    } else {
        Write-Host "❌ Login failed: $($loginResponse.error)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Login API Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    exit 1
}

# =====================================================
# Step 2: Test Validation API
# =====================================================
Write-Host "`n[Step 2] Testing Session Validation..." -ForegroundColor Yellow

$validateBody = @{
    api_key = $API_KEY
} | ConvertTo-Json

try {
    $validateResponse = Invoke-RestMethod -Uri "$API_URL/api/auth/validate" `
        -Method Post `
        -ContentType "application/json" `
        -Body $validateBody
    
    if ($validateResponse.valid) {
        Write-Host "✅ Session validation successful!" -ForegroundColor Green
        Write-Host "   User: $($validateResponse.user_name)" -ForegroundColor Gray
        Write-Host "   Location: $($validateResponse.location_name)" -ForegroundColor Gray
    } else {
        Write-Host "❌ Session invalid: $($validateResponse.error)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Validation API Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# =====================================================
# Step 3: Test with Invalid API Key
# =====================================================
Write-Host "`n[Step 3] Testing with invalid API key..." -ForegroundColor Yellow

$invalidBody = @{
    api_key = "invalid-key-12345"
} | ConvertTo-Json

try {
    $invalidResponse = Invoke-RestMethod -Uri "$API_URL/api/auth/validate" `
        -Method Post `
        -ContentType "application/json" `
        -Body $invalidBody
    
    if (-not $invalidResponse.valid) {
        Write-Host "✅ Invalid key correctly rejected!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Invalid key was accepted (unexpected)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✅ Invalid key correctly rejected with error" -ForegroundColor Green
}

# =====================================================
# Step 4: Test Existing Checkin API with new API Key
# =====================================================
Write-Host "`n[Step 4] Testing checkin API with authenticated key..." -ForegroundColor Yellow

# Note: Replace with a valid QR code from your system
$TEST_QR_CODE = Read-Host "Enter a test QR code (or press Enter to skip)"

if ($TEST_QR_CODE) {
    $checkinBody = @{
        qr_code = $TEST_QR_CODE
        api_key = $API_KEY
        action = "auto"
    } | ConvertTo-Json

    try {
        $checkinResponse = Invoke-RestMethod -Uri "$API_URL/api/checkin" `
            -Method Post `
            -ContentType "application/json" `
            -Body $checkinBody
        
        Write-Host "✅ Checkin API works with auth key!" -ForegroundColor Green
        Write-Host "   Response: $($checkinResponse | ConvertTo-Json -Compress)" -ForegroundColor Gray
    } catch {
        Write-Host "⚠️  Checkin API Error: $($_.Exception.Message)" -ForegroundColor Yellow
    }
} else {
    Write-Host "⏭️  Skipped checkin API test" -ForegroundColor Gray
}

# =====================================================
# Summary
# =====================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Testing Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nAPI Key for Flutter testing:" -ForegroundColor Yellow
Write-Host $API_KEY -ForegroundColor White

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Run Flutter app: flutter run -d windows" -ForegroundColor White
Write-Host "2. Check database migrations in app logs" -ForegroundColor White
Write-Host "3. Implement Login Screen UI" -ForegroundColor White

Write-Host "`n" 

