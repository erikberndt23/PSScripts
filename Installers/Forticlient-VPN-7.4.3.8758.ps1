# Target Forticlient version
$targetVersion = [version]"7.4.3.8758"

# VPN Configuration registry and destination
$vpnConfigRegPath = "HKLM:\Software\Fortinet\FortiClient\IPSec\Tunnels\ASTi VPN"
$regFileURL = "https://isos.asti-usa.com/ITDept/Forticlient%20VPN/forticlient-IPSec-vpn-tunnel.reg"
$regFilePath = "$env:TEMP\FortiClient-VPN.reg"

# Installer
$installerLocation = "https://isos.asti-usa.com/ITDept/Forticlient%20VPN/FortiClientVPNSetup_7.4.3.8758_x64.exe"
$exePath = "$env:TEMP\ForticlientVPN.exe"

# Uninstall registry paths
$reg = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

# Detect install
$agentRegPath = Get-ChildItem -Path $reg -ErrorAction SilentlyContinue |
    Get-ItemProperty |
    Where-Object { $_.DisplayName -eq "Forticlient VPN" } |
    Select-Object -First 1

if ($agentRegPath) {
    $InstalledVersion = [version]$agentRegPath.DisplayVersion

    if ($InstalledVersion -ge $targetVersion) {
        Write-Output "FortiClient VPN $InstalledVersion detected."
    }
    else {
        Write-Output "Older FortiClient VPN version $InstalledVersion detected. Upgrade required."
    }
}
else {
    Write-Output "FortiClient VPN not detected. Proceeding with installation..."
}

# Install if needed
if (-not $agentRegPath -or $InstalledVersion -lt $targetVersion) {

    Write-Output "Downloading FortiClient VPN installer..."
    (New-Object System.Net.WebClient).DownloadFile($installerLocation,$exePath)

    Write-Output "Installing FortiClient VPN..."
    $proc = Start-Process -FilePath $exePath `
        -ArgumentList "/quiet /norestart" `
        -Wait -NoNewWindow -PassThru

switch ($proc.ExitCode) {
    0 {
        Write-Output "Installer completed successfully."
    }
    3010 {
        Write-Output "Installer completed successfully. Reboot required."
        exit 3010
    }
    default {
        Write-Error "Installer failed with exit code $($proc.ExitCode)"
        exit $proc.ExitCode
    }
}
}

# Re-check install
$agentRegPost = Get-ChildItem -Path $reg -ErrorAction SilentlyContinue |
    Get-ItemProperty |
    Where-Object { $_.DisplayName -eq "Forticlient VPN" } |
    Select-Object -First 1

if (-not $agentRegPost) {
    Write-Error "FortiClient VPN installation failed."
    exit 1
}

# VPN config check
if (Test-Path $vpnConfigRegPath) {
    Write-Output "VPN configuration already present."
    exit 0
}

# Download reg file
Write-Output "Downloading VPN registry config..."
(New-Object System.Net.WebClient).DownloadFile($regFileURL,$regFilePath)

# Import reg
$regProc = Start-Process reg.exe `
    -ArgumentList "import `"$regFilePath`"" `
    -Wait -NoNewWindow -PassThru

if ($regProc.ExitCode -ne 0) {
    Write-Error "Registry import failed with exit code $($regProc.ExitCode)"
    exit 3
}

# Verify
if (Test-Path $vpnConfigRegPath) {
    Write-Output "VPN configuration imported successfully."
    exit 2
}
else {
    Write-Error "VPN registry import failed."
    exit 3
}
