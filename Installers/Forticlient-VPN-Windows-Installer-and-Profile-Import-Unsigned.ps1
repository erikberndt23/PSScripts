# ========= Downloading FortiClient VPN Installer =========

# Check that script is running as administrator

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Host "PowerShell is running as administrator."
} else {
    Write-Host "PowerShell is NOT running as administrator. Exiting script...Please re-run as administrator."
    Start-Sleep 5
    Exit 
}

# Define registry paths to check for installed Forticlient VPN

$reg = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

# Enforce TLS 1.3 for downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls13

# Check if Forticlient VPN is already installed before proceeding
$agentRegPath = Get-ChildItem -Path $reg | Get-ItemProperty | Where-Object { $_.DisplayName -eq "Forticlient VPN" } -ErrorAction SilentlyContinue

if ($agentRegPath) {
    Write-Output "$($agentRegPath.DisplayName) is already installed. Exiting script."
    Exit 1
} else {
    Write-Host "Forticlient VPN not detected. Proceeding with installation..."
}

# Forticlient VPN installer path and destination
$installerLocation = "https://isos.asti-usa.com/ITDept/Forticlient%20VPN/FortiClientVPNSetup_7.4.3.1790_x64.exe"
$exePath = "$env:TEMP\ForticlientVPN.exe"

# Download Forticlient VPN agent
Write-Output "Downloading Forticlient VPN installer..."
try {
    #Invoke-WebRequest -URI $installerLocation -OutFile $msiPath
    (New-Object System.Net.WebClient).DownloadFile($installerLocation,$exePath)
} 
catch {
    throw "Failed to download Forticlient VPN installer: $_"
}

# ========= Downloading FortiClient VPN Agent =========
# Install Forticlient VPN silently
$arguments = @(
    "`"$exePath`"",
    "/quiet",
    "/norestart"
)
Write-Output "Installing Forticlient VPN..."
Start-Process -FilePath $exePath -ArgumentList $arguments -Wait -NoNewWindow

# Re-check installation after install
$agentRegPost = Get-ChildItem -Path $reg | Get-ItemProperty | Where-Object { $_.DisplayName -eq "Forticlient VPN" } -ErrorAction SilentlyContinue

if ($agentRegPost) {
    Write-Output "$($agentRegPost.DisplayName) installed successfully!"
} else {
    Write-Host "Forticlient VPN was not installed successfully."
}

# ========= FortiClient VPN Registry Import =========
# Variables
$regFileUrl = "https://isos.asti-usa.com/ITDept/Forticlient%20VPN/forticlient-IPSec-vpn-tunnel.reg"
$tempRegPath = "$env:TEMP\forticlient-IPSec-vpn-tunnel.reg"

# Download the .reg file
try {
    write-host "Downloading VPN registry config file from: $regFileUrl"
    Invoke-WebRequest -Uri $regFileUrl -OutFile $tempRegPath
    Write-Host "Downloaded registry config to: $tempRegPath"
} catch {
    Write-Host "Error downloading .reg file: $_"
    Exit 1
}

# Import the registry file
try {
    write-host "Importing VPN configuration into registry..."
    Start-Process -FilePath "regedit.exe" -ArgumentList "/s `"$tempRegPath`"" -Wait -NoNewWindow
} catch {
    Exit 1
}

# Cleanup
if (Test-Path $tempRegPath) {
    Remove-Item $tempRegPath -Force
}
if (Test-Path $exePath) {
    Remove-Item $exePath -Force
}