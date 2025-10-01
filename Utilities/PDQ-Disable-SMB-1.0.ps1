# Disable SMB 1.0

Write-Output "Disabling SMB 1.0..."

# Disable SMB1 client driver (LanmanWorkstation dependency)

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name SMB1 -Value 0 -Force -ErrorAction SilentlyContinue

# Disable SMB1 server

Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -ErrorAction SilentlyContinue

# Disable SMB1 optional feature

Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart -ErrorAction SilentlyContinue

Write-Output "SMB 1.0 has been disabled. A reboot may be required to fully apply changes."
