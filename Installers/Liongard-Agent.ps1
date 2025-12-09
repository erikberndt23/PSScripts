# Enable TLS 1.2 for secure downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Liongard agent installer location
$msiPath = "$env:temp\LiongardAgent-lts.msi"

# Liongard agent installer URL
$installerURL = "https://agents.static.liongard.com/LiongardAgent-lts.msi"

# Liongard agent install parameters
$url="<liongard_instance_url>"
$key="<secret_key>"
$secret="<access_secret>"
$liongardenvironment="<liongard_environment_name>"

# Download Liongard agent to temp folder
Invoke-WebRequest -Uri $installerURL -OutFile $msiPath

if (!(Test-Path $msiPath)) {
        throw "Failed to download Liongard agent installer"
  }

# Liongard agent install parameters
$arguments = @(
    "/i" , "$msiPath"
    "/qn"
    "/norestart"
    "/L*V $env:temp\liongard-agent-install.log"
    "LIONGARDURL=$url"
    "LIONGARDACCESSKEY=$key"
    "LIONGARDACCESSSECRET=$secret"
    "LIONGARDENVIRONMENT=$liongardenvironment"
    "LIONGARDAGENTNAME=$env:computername"
)

# Install Liongard agent silently
#Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow
Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow

# Check if Liongard installed successfully
$reg = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$agentRegPath = Get-ChildItem -Path $reg | Get-ItemProperty | Where-Object { $_.DisplayName -Like "*Liongard Agent*" }

if ($agentRegPath) {
    Write-Output "$($agentRegPath.DisplayName) installed successfully!"
    }
else {
    Write-Host "Liongard agent not installed successfully!"
    Exit 1
    }

# Cleanup installation files
    if (Test-Path $msiPath) {
        Remove-Item $msiPath -Force
    }