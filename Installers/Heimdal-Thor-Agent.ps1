# Define registry paths to check for installed Heimdal Thor agent
$reg = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

# Check if Heimdal Thor Agent is already installed before proceeding
$agentRegPath = Get-ChildItem -Path $reg | Get-ItemProperty | Where-Object { $_.DisplayName -Like "*Heimdal Thor Agent*" }

if ($agentRegPath) {
    Write-Output "$($agentRegPath.DisplayName) is already installed. Exiting script."
    Exit 1
    }
else {
    Write-Host "Heimdal Thor agent not installed at all. Proceeding with installation..."
    }

# Checking for .NET Framework 4.8 dependency and installing if not found
# Registry path and key for .NET Framework 4.8
$netFrameworkRegPath = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
$releaseKey = (Get-ItemProperty -Path $netFrameworkRegPath -Name Release -ErrorAction SilentlyContinue).Release

# .NET Framework 4.8 release key value. Checks if version is greater than or equal to 4.8 and installs v4.8 if lower version is installed. 
$net48ReleaseKey = "528040"

if ($releaseKey -ge $net48ReleaseKey) {
    Write-Output ".NET Framework 4.8 is already installed."
} else {
    Write-Output ".NET Framework 4.8 is not installed. Downloading and installing..."
    
# Define the .NET Framework 4.8 download URL and installer path
    $dotNetInstallerUrl = "https://go.microsoft.com/fwlink/?linkid=2088631"
    $installerPath = "$env:TEMP\ndp48-x86-x64-allos-enu.exe"
    
# Download the .NET Framework 4.8 installer
    Write-Output "Downloading .NET Framework 4.8..."
    Invoke-WebRequest -Uri $dotNetInstallerUrl -OutFile $installerPath
    
# Install .NET Framework 4.8 silently
    Write-Output "Installing .NET Framework 4.8..."
    Start-Process -FilePath $installerPath -ArgumentList "/quiet /norestart /AcceptEULA" -Wait
    
    Write-Output "Installation complete. Continuing ."
}

# Heimdal agent installer URL
$installerURL = "https://heimdalprodstorage.blob.core.windows.net/setup/HeimdalLatestVersion.msi"

# Heimdal agent installer location
$msiPath = "$env:temp\HeimdalLatestAgent.msi"

# Download Heimdal agent to temp folder
Invoke-WebRequest -Uri $installerURL -OutFile $msiPath

if (!(Test-Path $msiPath)) {
        throw "Failed to download Heimdal agent installer"
  }

# Heimdal agent install parameters
$arguments = @(
    "/i" , "`"$msiPath`""
    "/qn"
    "/norestart"
    'heimdalkey="7C4E589E-431A-C94B-BFEB-EA4A448A7A9E"'
)

# Install Heimdal Thor agent silently
Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow

# Check if Heimdal Thor agent installed successfully
if ($agentRegPath) {
    Write-Output "$($agentRegPath.DisplayName) installed successfully!"
    }
else {
    Write-Host "Heimdal agent not installed successfully!"
    }

# Cleanup installation files
    if (Test-Path $msiPath) {
        Remove-Item $msiPath -Force
    }