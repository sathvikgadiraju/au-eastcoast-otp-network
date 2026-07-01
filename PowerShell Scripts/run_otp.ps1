# run_otp.ps1
# Loads the pre-built graph and starts the OTP REST/GraphQL server.
# Run build_graph.ps1 first to produce graph.obj.

param(
    [int]$MaxMemoryGb = 4,
    [int]$Port        = 8080
)

$OtpDir    = "otp"
$GraphDir  = "graphs\default"
$Jar       = Get-ChildItem "$OtpDir\otp-*-shaded.jar" -ErrorAction SilentlyContinue | Select-Object -First 1
$GraphFile = "$OtpDir\$GraphDir\graph.obj"

if (-not $Jar) {
    Write-Host "ERROR: OTP JAR not found. Run .\setup_otp.ps1 first." -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $GraphFile)) {
    Write-Host "ERROR: graph.obj not found. Run .\build_graph.ps1 first." -ForegroundColor Red
    exit 1
}

Write-Host "=== Starting OTP Server ===" -ForegroundColor Cyan
Write-Host "  JAR:    $($Jar.Name)"
Write-Host "  Memory: ${MaxMemoryGb} GB"
Write-Host "  Port:   $Port"
Write-Host ""
Write-Host "Endpoints once running:" -ForegroundColor Green
Write-Host "  Web UI:      http://localhost:$Port/"
Write-Host "  REST API:    http://localhost:$Port/otp/routers/default/"
Write-Host "  GraphQL:     http://localhost:$Port/otp/gtfs/v1"
Write-Host "  Transmodel:  http://localhost:$Port/otp/transmodel/v3"
Write-Host ""

Push-Location $OtpDir
try {
    java `
        "-Xmx${MaxMemoryGb}G" `
        "--add-opens=java.base/java.io=ALL-UNNAMED" `
        "--add-opens=java.base/java.lang.reflect=ALL-UNNAMED" `
        "--add-opens=java.base/java.util=ALL-UNNAMED" `
        -jar $Jar.Name `
        --load --serve `
        --port $Port `
        $GraphDir
} finally {
    Pop-Location
}
