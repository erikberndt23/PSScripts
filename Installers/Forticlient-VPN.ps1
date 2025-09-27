# Define registry paths to check for installed Forticlient VPN
$reg = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

# Check if Forticlient VPN is already installed before proceeding
$agentRegPath = Get-ChildItem -Path $reg | Get-ItemProperty | Where-Object { $_.DisplayName -eq "Forticlient VPN" }

if ($agentRegPath) {
    Write-Output "$($agentRegPath.DisplayName) is already installed. Exiting script."
    Exit 0
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

# Install Forticlient VPN silently
$arguments = @(
    "`"$exePath`"",
    "/quiet",
    "/norestart"
)
Write-Output "Installing Forticlient VPN..."
Start-Process -FilePath $exePath -ArgumentList $arguments -Wait -NoNewWindow

# Re-check installation after install
$agentRegPost = Get-ChildItem -Path $reg | Get-ItemProperty | Where-Object { $_.DisplayName -eq "Forticlient VPN" }

if ($agentRegPost) {
    Write-Output "$($agentRegPost.DisplayName) installed successfully!"
} else {
    Write-Host "Forticlient VPN was not installed successfully."
}

# Cleanup
if (Test-Path $msiPath) {
    Remove-Item $exePath -Force
}