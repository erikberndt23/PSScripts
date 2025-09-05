Get-BitLockerVolume | ForEach-Object {
    $mount = $_.MountPoint
    $_.KeyProtector | Where-Object KeyProtectorType -eq 'RecoveryPassword' |
        ForEach-Object { Backup-BitLockerKeyProtector -MountPoint $mount -KeyProtectorId $_.KeyProtectorId }
}