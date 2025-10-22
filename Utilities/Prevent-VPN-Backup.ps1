# Prevent-Veeam Agent from running backups when Fortinet VPN is connected
# This script checks for an active Fortinet VPN connection and disables the Veeam Agent service if connected.

$log = "C:\ProgramData\PreventVeeamVPNBackup.log"
$service = "VeeamEndpointBackupSvc"

# Log function
function Write-Log($msg) {
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $msg" | Out-File -FilePath $log -Append
}
# Check for active Fortinet VPN connection
function VPNConnected {
    $vpn = Get-NetAdapter | Where-Object {
        $_.InterfaceDescription -match "Fortinet" -and $_.Status -eq "Up"
    }
    return $vpn -ne $null
}

# Get Veeam Agent service
function Get-VeeamService 
{
    Get-Service -Name $service -ErrorAction SilentlyContinue
}

# Get the Veeam Agent service

$svc = Get-VeeamService

if (-not $svc) 
{
    Write-Log "Veeam Agent service not found - nothing to manage."
    exit 0
}

# Manage Veeam Agent service based on VPN connection status

if (VPNConnected) {
    Write-Log "VPN connected - stopping and disabling Veeam service."
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    Set-Service -Name $service -StartupType Disabled
} 
else 
{
    Write-Log "VPN not detected - ensuring Veeam service is enabled and running."
    Set-Service -Name $service -StartupType Automatic
    Start-Service -Name $service -ErrorAction SilentlyContinue
}
