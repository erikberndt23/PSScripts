# Get all UEFI Settings
Get-WmiObject -class Lenovo_BiosSetting -namespace root\wmi | ForEach-Object {if ($_.CurrentSetting -ne "") {Write-Host $_.CurrentSetting.replace(","," = ")}}

# Set Secure Boot to Enabled
$bios = Get-WmiObject -class Lenovo_SetBiosSetting -namespace root\wmi
$bios.SetBiosSetting("SecureBoot,Enable")

# Set Bluetooth to Disabled
$bios = Get-WmiObject -class Lenovo_SetBiosSetting -namespace root\wmi
$bios.SetBiosSettings("Bluetooth,Disable")

# Save Settings. Reboot afterwards to take effect
(Get-WmiObject -class Lenovo_SaveBiosSettings -namespace root\wmi).SaveBiosSettings()