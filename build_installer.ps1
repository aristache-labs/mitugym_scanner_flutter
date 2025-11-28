# MituGym Scanner - Automated Installer Build Script
# This script automates the entire build and installer creation process

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('msix', 'inno', 'nsis', 'all')]
    [string]$InstallerType = 'inno',
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipBuild = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Clean = $false
)

# Colors for console output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

Write-Info "========================================="
Write-Info "   MituGym Scanner Installer Builder"
Write-Info "========================================="
Write-Info ""

# Check if Flutter is installed
Write-Info "Checking Flutter installation..."
try {
    $flutterVersion = flutter --version 2>&1 | Select-String "Flutter"
    Write-Success "✓ Flutter is installed: $($flutterVersion -replace 'Flutter ', '')"
} catch {
    Write-Error "✗ Flutter is not installed or not in PATH"
    Write-Error "Please install Flutter from: https://flutter.dev"
    exit 1
}

# Clean previous builds if requested
if ($Clean) {
    Write-Info "`nCleaning previous builds..."
    flutter clean
    Write-Success "✓ Cleaned"
}

# Build the Flutter app
if (-not $SkipBuild) {
    Write-Info "`nBuilding Flutter Windows app in Release mode..."
    Write-Info "This may take several minutes..."
    
    flutter pub get
    $buildResult = flutter build windows --release 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✓ Flutter build completed successfully"
    } else {
        Write-Error "✗ Flutter build failed"
        Write-Error $buildResult
        exit 1
    }
} else {
    Write-Warning "Skipping Flutter build (using existing build)"
}

# Check if build exists
$buildPath = "build\windows\x64\runner\Release\mitugym_scanner_flutter.exe"
if (-not (Test-Path $buildPath)) {
    Write-Error "✗ Build not found at: $buildPath"
    Write-Error "Please run without -SkipBuild parameter"
    exit 1
}

Write-Success "✓ Build found at: $buildPath"

# Get build size
$buildSize = (Get-ChildItem -Path "build\windows\x64\runner\Release" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Info ("Build size: {0:N2} MB" -f $buildSize)

# Create Output directory if it doesn't exist
if (-not (Test-Path "Output")) {
    New-Item -ItemType Directory -Path "Output" | Out-Null
    Write-Info "Created Output directory"
}

Write-Info ""
Write-Info "========================================="
Write-Info "   Creating Installer(s)"
Write-Info "========================================="

# Function to create MSIX
function Build-MSIX {
    Write-Info "`n[MSIX] Creating MSIX package..."
    
    # Check if msix package is in pubspec.yaml
    $pubspecContent = Get-Content "pubspec.yaml" -Raw
    if ($pubspecContent -notmatch "msix:") {
        Write-Warning "MSIX package not found in pubspec.yaml"
        Write-Info "Adding msix package..."
        flutter pub add msix --dev
    }
    
    # Run MSIX create
    $msixResult = flutter pub run msix:create 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✓ MSIX package created successfully"
        
        # Find the MSIX file
        $msixFile = Get-ChildItem -Path "build\windows\x64\runner\Release" -Filter "*.msix" | Select-Object -First 1
        if ($msixFile) {
            Write-Info "MSIX file: $($msixFile.Name)"
            Write-Info ("Size: {0:N2} MB" -f ($msixFile.Length / 1MB))
            
            # Copy to Output folder
            Copy-Item $msixFile.FullName -Destination "Output\" -Force
            Write-Success "✓ Copied to Output folder"
        }
    } else {
        Write-Error "✗ MSIX creation failed"
        Write-Error $msixResult
        return $false
    }
    
    return $true
}

# Function to create Inno Setup installer
function Build-InnoSetup {
    Write-Info "`n[Inno Setup] Creating traditional installer..."
    
    # Check if Inno Setup is installed
    $innoPath = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    if (-not (Test-Path $innoPath)) {
        $innoPath = "C:\Program Files\Inno Setup 6\ISCC.exe"
    }
    
    if (-not (Test-Path $innoPath)) {
        Write-Error "✗ Inno Setup not found"
        Write-Error "Please download and install from: https://jrsoftware.org/isdl.php"
        return $false
    }
    
    Write-Success "✓ Inno Setup found"
    
    # Check if script exists
    if (-not (Test-Path "installer_script.iss")) {
        Write-Error "✗ installer_script.iss not found"
        return $false
    }
    
    # Compile the installer
    Write-Info "Compiling installer..."
    & $innoPath "installer_script.iss"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✓ Inno Setup installer created successfully"
        
        # Find the installer file
        $installerFile = Get-ChildItem -Path "Output" -Filter "MituGymScanner_Setup_*.exe" | Select-Object -First 1
        if ($installerFile) {
            Write-Info "Installer: $($installerFile.Name)"
            Write-Info ("Size: {0:N2} MB" -f ($installerFile.Length / 1MB))
        }
        return $true
    } else {
        Write-Error "✗ Inno Setup compilation failed"
        return $false
    }
}

# Function to create NSIS installer
function Build-NSIS {
    Write-Info "`n[NSIS] Creating NSIS installer..."
    
    # Check if NSIS is installed
    $nsisPath = "C:\Program Files (x86)\NSIS\makensis.exe"
    if (-not (Test-Path $nsisPath)) {
        $nsisPath = "C:\Program Files\NSIS\makensis.exe"
    }
    
    if (-not (Test-Path $nsisPath)) {
        Write-Error "✗ NSIS not found"
        Write-Error "Please download and install from: https://nsis.sourceforge.io/Download"
        return $false
    }
    
    Write-Success "✓ NSIS found"
    
    # Check if script exists
    if (-not (Test-Path "installer_script.nsi")) {
        Write-Error "✗ installer_script.nsi not found"
        return $false
    }
    
    # Compile the installer
    Write-Info "Compiling installer..."
    & $nsisPath "installer_script.nsi"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✓ NSIS installer created successfully"
        
        # Find the installer file
        $installerFile = Get-ChildItem -Path "Output" -Filter "MituGymScanner_Setup_*.exe" | Select-Object -First 1
        if ($installerFile) {
            Write-Info "Installer: $($installerFile.Name)"
            Write-Info ("Size: {0:N2} MB" -f ($installerFile.Length / 1MB))
        }
        return $true
    } else {
        Write-Error "✗ NSIS compilation failed"
        return $false
    }
}

# Build based on selected type
$success = $true

switch ($InstallerType) {
    'msix' {
        $success = Build-MSIX
    }
    'inno' {
        $success = Build-InnoSetup
    }
    'nsis' {
        $success = Build-NSIS
    }
    'all' {
        Write-Info "Building all installer types..."
        $msixSuccess = Build-MSIX
        $innoSuccess = Build-InnoSetup
        $nsisSuccess = Build-NSIS
        $success = $msixSuccess -or $innoSuccess -or $nsisSuccess
    }
}

# Final summary
Write-Info ""
Write-Info "========================================="
Write-Info "   Build Summary"
Write-Info "========================================="

if ($success) {
    Write-Success "`n✓ Installer creation completed successfully!"
    Write-Info "`nInstaller(s) location: $(Resolve-Path 'Output')"
    
    # List all files in Output folder
    Write-Info "`nCreated files:"
    Get-ChildItem "Output" | ForEach-Object {
        Write-Info ("  - {0} ({1:N2} MB)" -f $_.Name, ($_.Length / 1MB))
    }
    
    Write-Info "`nNext steps:"
    Write-Info "  1. Test the installer on a clean Windows machine"
    Write-Info "  2. (Optional) Sign the installer with a code signing certificate"
    Write-Info "  3. Distribute to users"
    
} else {
    Write-Error "`n✗ Installer creation failed"
    Write-Info "Check the errors above for details"
    exit 1
}

Write-Info ""
Write-Info "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

