# Lenovo System Update PDQ Script
# Download and silently install Lenovo System Update (if not already instaleld) and silently check for driver updates

# Variables
$ErrorActionPreference = 'Stop'
$lsuUrl = "https://download.lenovo.com/pccbbs/thinkvantage_en/system_update_5.08.03.59.exe"
$tempDir = "$env:windir\Temp\LenovoLSU"
$installer = "$tempDir\LenovoSystemUpdate.exe"
$lsuExe = "${env:ProgramFiles(x86)}\Lenovo\System Update\Tvsu.exe"
$logFile = "$env:windir\Temp\LenovoLSU\LenovoLSU_Log.txt"
$schedReg = "HKLM:\SOFTWARE\WOW6432Node\Lenovo\System Update\Preferences\UserSettings\Scheduler"
$genReg = "HKLM:\SOFTWARE\WOW6432Node\Lenovo\System Update\Preferences\UserSettings\General"

Write-Output "Starting Lenovo System Update..."

# Prepare Directories
if (-not (Test-Path -Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}

# Install Lenovo System Update if not present
if (-not (Test-Path -Path $lsuExe)) {
    Write-Output "Lenovo System Update not found. Downloading installer..."
    Invoke-WebRequest -Uri $lsuUrl -OutFile $installer

    Write-Output "Installing Lenovo System Update silently..."
    Start-Process -FilePath $installer -ArgumentList "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART" -Wait

    # Verify installation
    if (-not (Test-Path -Path $lsuExe)) {
        Write-Error "Lenovo System Update installation failed."
        exit 1
    }
    else {
        Write-Output "Lenovo System Update installed successfully."
    }
}
else {
    Write-Output "Lenovo System Update is already installed."
}

# Accept EULA
Write-Output "Accepting Lenovo System Update EULA..."
Set-ItemProperty -Path $genReg -Name "EulaAccepted" -Value "true" -Type String
Set-ItemProperty -Path $genReg -Name "DisplayLicenseNotice" -Value "NO" -Type String
Set-ItemProperty -Path $genReg -Name "DisplayLicenseNoticeSU" -Value "NO" -Type String
Set-ItemProperty -Path $genReg -Name "DisplayInformationScreen" -Value "NO" -Type String

# Disable Scheduled Scans
Write-Output "Disabling scheduled scans..."
Set-ItemProperty -Path $schedReg -Name "SchedulerAbility" -Value "NO" -Type String
Set-ItemProperty -Path $schedReg -Name "SchedulerLock" -Value "HIDE" -Type String

# BLock auto-reboot for driver updates
Write-Output "Blocking automatic reboot after updates..." 
Set-ItemProperty -Path $genReg -Name "RebootRequiredAction" -Value "0" -Type String

# Scan for updates and install
Write-Output "Scanning for updates and installing..."
Start-Process -FilePath $lsuExe -ArgumentList "/silent /log $logFile /install /category DRIVERS,FIRMWARE /severity CRITICAL,RECOMMENDED" -Wait -PassThru

# Exit Codes
switch ($proc.ExitCode) {
    0     { Write-Host "Updates installed successfully."; exit 0 }
    1     { Write-Host "Update error."; exit 1 }
    3010  { Write-Host "Updates installed. Reboot required."; exit 3010 }
    default {
        exit $proc.ExitCode
    }
}