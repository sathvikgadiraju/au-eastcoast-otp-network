param(
    [int]$MaxMemoryGb = 10
)

$OtpDir   = "otp"
$GraphDir = "graphs\default"
$LogFile  = "$OtpDir\build.log"

$Jar = Get-ChildItem "$OtpDir\otp-*-shaded.jar" -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $Jar) {
    Write-Host "ERROR: OTP JAR not found" -ForegroundColor Red
    exit 1
}

$JavaArgs = @(
    "-Xmx${MaxMemoryGb}G",
    "--add-opens=java.base/java.io=ALL-UNNAMED",
    "--add-opens=java.base/java.lang.reflect=ALL-UNNAMED",
    "--add-opens=java.base/java.util=ALL-UNNAMED",
    "-jar",
    $Jar.FullName
)

Write-Host "=== OTP GRAPH BUILD ===" -ForegroundColor Cyan
Write-Host "Memory: ${MaxMemoryGb} GB"
Write-Host "Dir: $GraphDir"
Write-Host ""

# Remove any leftover intermediate files that confuse OTP into partial builds
$staleFiles = @("$OtpDir\$GraphDir\streetGraph.obj", "$OtpDir\$GraphDir\graph.obj")
foreach ($f in $staleFiles) {
    if (Test-Path $f) {
        Write-Host "Removing stale file: $f" -ForegroundColor Yellow
        Remove-Item $f -Force
    }
}

# Verify GTFS feeds are present
Write-Host "`nGTFS feeds found in $OtpDir\$GraphDir\:" -ForegroundColor Cyan
Get-ChildItem "$OtpDir\$GraphDir\*.zip" | ForEach-Object {
    Write-Host "  $($_.Name)  ($([math]::Round($_.Length/1MB, 1)) MB)"
}
Write-Host ""

Push-Location $OtpDir

try {

    Write-Host "Running full OTP build (OSM + all GTFS)..." -ForegroundColor Yellow

    & java @JavaArgs --build --save $GraphDir 2>&1 |
        Tee-Object -FilePath "..\$LogFile"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED - check $LogFile" -ForegroundColor Red
        exit 1
    }

    $graphFile = "$GraphDir\graph.obj"
    if (Test-Path $graphFile) {
        $size = [math]::Round((Get-Item $graphFile).Length / 1MB)
        Write-Host "`n=== BUILD COMPLETE: graph.obj is $size MB ===" -ForegroundColor Green
        Write-Host "Start server with: .\run_otp.ps1"
    } else {
        Write-Host "`nWARNING: graph.obj not found after build." -ForegroundColor Yellow
    }

}
finally {
    Pop-Location
}