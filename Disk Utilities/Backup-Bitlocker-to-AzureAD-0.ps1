# Backup Bitlocker recovery key to Entra
$BLV = Get-BitLockerVolume -MountPoint "C:"
BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId