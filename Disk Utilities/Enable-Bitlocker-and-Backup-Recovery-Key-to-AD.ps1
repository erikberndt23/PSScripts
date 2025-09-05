# Enable BitLocker on the C: drive and back up the recovery key to Active Directory

$Drive = "C:"

# Make sure BitLocker module is available

Import-Module BitLocker -ErrorAction Stop

# Check if BitLocker is already enabled

$vol = Get-BitLockerVolume -MountPoint $Drive

if ($vol.ProtectionStatus -eq "Off") {
    # Add a recovery password protector (48-digit key)

    $protector = Add-BitLockerKeyProtector -MountPoint $Drive -RecoveryPasswordProtector

    # Enable BitLocker with used-space-only encryption

    Enable-BitLocker -MountPoint $Drive -EncryptionMethod XtsAes256 -UsedSpaceOnly -RecoveryPasswordProtector -Confirm:$false

    # Enable protection

    manage-bde -protectors -enable $Drive

    # Backup the recovery key to Active Directory

   Get-BitLockerVolume | ForEach-Object {
    $mount = $_.MountPoint
    $_.KeyProtector | Where-Object KeyProtectorType -eq 'RecoveryPassword' |
        ForEach-Object { Backup-BitLockerKeyProtector -MountPoint $mount -KeyProtectorId $_.KeyProtectorId }
}

    Write-Host "BitLocker enabled on $Drive with recovery password backed up to AD."
}

else {
    Write-Host "BitLocker is already enabled on $Drive."

    # Ensure recovery password exists

    $recovery = $vol.KeyProtector | Where-Object { $_.KeyProtectorType -eq "RecoveryPassword" }

    if (-not $recovery) {
        $protector = Add-BitLockerKeyProtector -MountPoint $Drive -RecoveryPasswordProtector
        Backup-BitLockerKeyProtector -MountPoint $Drive -KeyProtectorId $protector.KeyProtectorId
        Write-Host "Added and backed up new recovery password to AD."
    }
    else {
        Backup-BitLockerKeyProtector -MountPoint $Drive -KeyProtectorId $recovery.KeyProtectorId
        Write-Host "Existing recovery password backed up to AD."
    }
}