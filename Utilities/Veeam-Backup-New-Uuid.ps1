# Generate a new GUID
# Run on affected client machines to generate a new UUID for the Veeam Agent for Microsoft Windows service.
$newGuid = [guid]::NewGuid()
Write-Host "{$newGuid}"

# Enable UUID failover
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Veeam' -Name EnableSystemUuidFailover -Value 1

# Set the new UUID registry key name
New-ItemProperty -Path 'HKLM:\SOFTWARE\Veeam' -Name SystemUuid -PropertyType String -Value "{$newGuid}" -Force

# Restart the Veeam backup agent service
Restart-Service -Name VeeamEndpointBackupSvc