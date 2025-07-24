# Get the BIOS UUID
$biosUUID = (Get-WmiObject -Class Win32_ComputerSystemProduct).UUID

# Define the registry path and value name
$regPath = "HKLM:\SOFTWARE\Veeam\Veeam Backup and Replication"
$valueName = "bios_uuid"

# Create the key if it doesn't exist
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Set the BIOS UUID in the registry
Set-ItemProperty -Path $regPath -Name $valueName -Value $biosUUID -Force

# Confirm the value was set
$setValue = Get-ItemProperty -Path $regPath -Name $valueName
Write-Output "Veeam registry bios_uuid set to: $($setValue.$valueName)"
