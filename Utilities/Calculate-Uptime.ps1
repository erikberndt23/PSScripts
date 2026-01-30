# Calculate system uptime and write to registry for PDQ Connect to use
# Get uptimes and writes it to registry

# Variables
$osObject = Get-CimInstance Win32_OperatingSystem
$uptime = (Get-Date) - $osObject.LastBootUpTime
$regPath = "HKLM:\SOFTWARE\PDQ\PDQConnect"
$regName = "SystemUptime"

# Write uptime to registry
if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
Set-ItemProperty -Path $regPath -Name $regName -Value ([math]::Round($uptime.TotalDays,2))
Write-Output "SystemUptime: $([math]::Round($uptime.TotalDays,2)) days"
