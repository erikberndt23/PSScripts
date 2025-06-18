# ================================
# FortiClient VPN Registry Import
# ================================

# Variables
$regFileUrl = "https://isos.asti-usa.com/ITDept/Forticlient%20VPN/forticlient-IPSec-vpn-tunnel.reg"  # Update to your actual URL
$tempRegPath = "$env:TEMP\forticlient-IPSec-vpn-tunnel.reg"

# Check if FortiClient is installed
$fcInstalled = Get-ChildItem "HKLM:\SOFTWARE\Fortinet\FortiClient" -ErrorAction SilentlyContinue
if (-not $fcInstalled) {
    Write-Host "FortiClient is not installed. Aborting."
    Exit 1
}

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

# Optional: Cleanup
if (Test-Path $tempRegPath) {
    Remove-Item $tempRegPath -Force
}