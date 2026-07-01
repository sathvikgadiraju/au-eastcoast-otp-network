.\setup_otp.ps1# setup_otp.ps1
# Downloads OTP 2.6.0 JAR and prepares the graph data directory.
# Run once before building the graph.

param(
    [string]$OtpVersion = "2.6.0"
)

$OtpDir    = "otp"
$JarName   = "otp-$OtpVersion-shaded.jar"
$JarPath   = "$OtpDir\$JarName"
$DownloadUrl = "https://github.com/opentripplanner/OpenTripPlanner/releases/download/v$OtpVersion/$JarName"

Write-Host "=== OTP Setup (v$OtpVersion) ===" -ForegroundColor Cyan

# --- Java check ---
Write-Host "`nChecking Java..." -ForegroundColor Yellow
$javaOut = java -version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERROR: Java not found. Install Java 17+ from https://adoptium.net/" -ForegroundColor Red
    exit 1
}
Write-Host "  $($javaOut[0])" -ForegroundColor Green

# --- Directory structure ---
New-Item -ItemType Directory -Force -Path "$OtpDir\graphs\default" | Out-Null
Write-Host "`nDirectories ready: $OtpDir\graphs\default" -ForegroundColor Green

# --- Download JAR ---
if (Test-Path $JarPath) {
    Write-Host "`nOTP JAR already present: $JarPath" -ForegroundColor Green
} else {
    Write-Host "`nDownloading OTP JAR (~100 MB)..." -ForegroundColor Yellow
    Write-Host "  $DownloadUrl"
    $ProgressPreference = 'SilentlyContinue'
    try {
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $JarPath -UseBasicParsing
        Write-Host "  Saved: $JarPath" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR: $_" -ForegroundColor Red
        Write-Host "  Download manually from:" -ForegroundColor Yellow
        Write-Host "  $DownloadUrl"
        exit 1
    }
}

# --- Prepare data files ---
Write-Host "`nPreparing data files..." -ForegroundColor Yellow
python prepare_otp_data.py
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERROR: Data preparation failed." -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Setup complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Build graph:  .\build_graph.ps1          (10-30 min, needs ~6 GB RAM)"
Write-Host "  2. Start server: .\run_otp.ps1"
Write-Host "  3. Open:         http://localhost:8080"
