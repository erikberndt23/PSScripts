# Define registry paths to check for installed Heimdal Thor agent
$reg = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

# Check if Heimdal Thor Agent is already installed before proceeding
$agentRegPath = Get-ChildItem -Path $reg | Get-ItemProperty | Where-Object { $_.DisplayName -eq "Heimdal Thor Agent" }

if ($agentRegPath) {
    Write-Output "$($agentRegPath.DisplayName) is already installed. Exiting script."
    Exit 0
} else {
    Write-Host "Heimdal Thor agent not detected. Proceeding with installation..."
}

# Checking for .NET Framework 4.8 dependency
$netFrameworkRegPath = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
$releaseKey = (Get-ItemProperty -Path $netFrameworkRegPath -Name Release -ErrorAction SilentlyContinue).Release
$net48ReleaseKey = 528040

if ($releaseKey -ge $net48ReleaseKey) {
    Write-Output ".NET Framework 4.8 is already installed."
} else {
    Write-Output ".NET Framework 4.8 is not installed. Downloading and installing..."
    
    $dotNetInstallerUrl = "https://go.microsoft.com/fwlink/?linkid=2088631"
    $installerPath = "$env:TEMP\ndp48-x86-x64-allos-enu.exe"
    
    Write-Output "Downloading .NET Framework 4.8..."
    Invoke-WebRequest -Uri $dotNetInstallerUrl -OutFile $installerPath
    
    Write-Output "Installing .NET Framework 4.8..."
    Start-Process -FilePath $installerPath -ArgumentList "/quiet /norestart /AcceptEULA" -Wait
    Write-Output ".NET Framework 4.8 installation complete."
}

# Heimdal agent installer path and destination
$installerLocation = "\\asti-usa.net\netlogon\heimdal\HeimdalLatestVersion.msi"
$msiPath = "$env:TEMP\HeimdalLatestVersion.msi"

# Download Heimdal agent
Write-Output "Downloading Heimdal Thor Agent installer..."
try {
    (New-Object System.Net.WebClient).DownloadFile($installerLocation, $msiPath)
} catch {
    throw "Failed to download Heimdal agent installer: $_"
}

# Install Heimdal Thor agent silently
$arguments = @(
    "/i", "`"$msiPath`"",
    "/qn",
    "/norestart"
)
Write-Output "Installing Heimdal Thor Agent..."
Start-Process -FilePath msiexec.exe -ArgumentList $arguments -Wait -NoNewWindow

# Re-check installation after install
$agentRegPost = Get-ChildItem -Path $reg | Get-ItemProperty | Where-Object { $_.DisplayName -eq "Heimdal Thor Agent" }

if ($agentRegPost) {
    Write-Output "$($agentRegPost.DisplayName) installed successfully!"
} else {
    Write-Host "Heimdal Thor Agent was not installed successfully."
}

# Cleanup
if (Test-Path $msiPath) {
    Remove-Item $msiPath -Force
}