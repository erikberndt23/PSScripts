Write-Host "Starting Windows Update cache repair..."

# Define services to stop/start

$services = @(
    "wuauserv",   # Windows Update
    "bits",       # Background Intelligent Transfer Service
    "cryptsvc",   # Cryptographic Services
    "trustedinstaller" # Windows Modules Installer
)

# Stop services

foreach ($service in $services) {
    Write-Host "Stopping service: $service..."
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
}

# Give services time to stop

Start-Sleep -Seconds 5

# Reset SoftwareDistribution folder

$sdPath = "$env:SystemRoot\SoftwareDistribution"

if (Test-Path $sdPath) {
    Write-Host "Renaming SoftwareDistribution to SoftwareDistribution.old..."
    Rename-Item -Path $sdPath -NewName "SoftwareDistribution.old" -ErrorAction SilentlyContinue
}

# Reset Catroot2 folder

$catrootPath = "$env:SystemRoot\System32\catroot2"

if (Test-Path $catrootPath) {
    Write-Host "Renaming Catroot2 to Catroot2.old..."
    Rename-Item -Path $catrootPath -NewName "Catroot2.old" -ErrorAction SilentlyContinue
}

# Restart services

foreach ($service in $services) {
    Write-Host "Starting service: $service..."
    Start-Service -Name $service -ErrorAction SilentlyContinue
}

Write-Host "Windows Update cache repair completed."