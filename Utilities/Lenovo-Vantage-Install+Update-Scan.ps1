$ErrorActionPreference = 'Stop'

# Download URL (may need to update as needed)

$vantageUrl  = "https://download.lenovo.com/pccbbs/thinkvantage_en/metroapps/Vantage/LenovoCommercialVantage_20.2508.42.0.20250908074547.zip"

# Folder Paths

$tempDir     = "$env:WINDIR\Temp\Lenovo"
$vantageZip  = "$tempDir\VantageInstaller.zip"
$svcRoot     = "$env:ProgramFiles\Lenovo\SUHelper"
$logDir      = "C:\ProgramData\Lenovo\Vantage\Logs"

# Service paths

$svc = Get-Service -Name "LenovoVantageService" -ErrorAction SilentlyContinue
$suHelper = Get-ChildItem -Path $svcRoot -Filter "SUHelper.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
$vantageExe = Get-ChildItem -Path $tempDir -Filter "*Vantage*Installer*.exe" -Recurse | Select-Object -First 1
$suHelper = Get-ChildItem -Path $svcRoot -Filter "SUHelper.exe" -Recurse | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# Prep folders

foreach ($path in @($tempDir)) {
    if (!(Test-Path $path)) {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
    }
}

foreach ($path in @($logDir)) {
    if (!(Test-Path $path)) {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
    }
}

# Download installer function

function Download-IfMissing {
    param (
        [string]$Url,
        [string]$Destination
    )

    if (!(Test-Path $Destination)) {
        Write-Host "Downloading $Url ..."
        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing
    }
}

# Cleanup any previous installs

Write-Host "Cleaning up any previous Vantage installations..."

# Stop & remove service

if ($svc) {
    Write-Host "Stopping existing LenovoVantageService..."
    Stop-Service -Name "LenovoVantageService" -Force -ErrorAction SilentlyContinue

    Write-Host "Deleting existing LenovoVantageService..."
    sc.exe delete "LenovoVantageService" | Out-Null
}

# Remove old folders
foreach ($oldPath in @($svcRoot, "C:\ProgramData\Lenovo\Vantage")) {
    if (Test-Path $oldPath) {
        Write-Host "Removing folder $oldPath"
        Remove-Item -Path $oldPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Install Vantage Service + System Update Helper. Check if SUHelper.exe exists after cleanup

if (!$suHelper) {
    Write-Host "Installing Lenovo Vantage Service + SU Helper..."

    # Download ZIP if missing
    Download-IfMissing -Url $vantageUrl -Destination $vantageZip

    # Extract installer

    Write-Host "Extracting Lenovo Commercial Vantage ZIP..."
    Expand-Archive -Path $vantageZip -DestinationPath $tempDir -Force

    # Locate installer EXE dynamically

    if (!$vantageExe) {
        Write-Error "Vantage installer executable not found after extraction."
        exit 1
    }

    # Silent install Service + System Update Helper

    Start-Process -FilePath $vantageExe.FullName -ArgumentList "Install -Vantage" -Wait -NoNewWindow
}

# Locate System Update Helper

if (!$suHelper) {
    Write-Error "SUHelper.exe not found. Update scan aborted."
    exit 1
}

# Run Silent Scan + Install

Write-Host "Running Lenovo update scan..."
Start-Process -FilePath $suHelper.FullName -ArgumentList "scan" -Wait -NoNewWindow

Write-Host "Installing Lenovo updates..."
Start-Process -FilePath $suHelper.FullName -ArgumentList "install" -Wait -NoNewWindow

Write-Host "Lenovo Commercial Vantage update process complete."
exit 0