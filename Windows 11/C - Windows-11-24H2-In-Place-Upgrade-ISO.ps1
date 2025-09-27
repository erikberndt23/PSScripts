$dir = "C:\temp\win11"
New-Item -ItemType Directory -Path $dir -Force | Out-Null

# Download Latest Windows 11 ISO
$webClient = New-Object System.Net.WebClient
$url = 'https://isos.asti-usa.com/ITDept/Windows%2011/Win11_24H2_English_x64.iso'
$file = "$dir\Win11_24H2_English_x64.iso"
$webClient.DownloadFile($url, $file)

# Suspend BitLocker
$logFile = Join-Path $dir "Upgrade.log"
Write-Output "Suspending BitLocker at $(Get-Date)" | Out-File $logFile -Append

$bitlockerVolumes = Get-BitLockerVolume | Where-Object { $_.VolumeStatus -eq "FullyEncrypted" -and $_.LockStatus -eq "Unlocked" }
foreach ($vol in $bitlockerVolumes) {
    Suspend-BitLocker -MountPoint $vol.MountPoint -RebootCount 1
    Write-Output "BitLocker suspended on $($vol.MountPoint)" | Out-File $logFile -Append
}

# Mount ISO
$mountResult = Mount-DiskImage -ImagePath $file -PassThru
$driveLetter = ($mountResult | Get-Volume | Where-Object FileSystemLabel -ne $null).DriveLetter + ":"
$setupPath = Join-Path $driveLetter "setup.exe"

Write-Output "Starting Windows 11 upgrade at $(Get-Date)" | Out-File $logFile -Append

# Run setup.exe silently
$process = Start-Process -FilePath $setupPath -ArgumentList "/Autoupgrade /Quiet /ShowOobe none /NoReboot" -Wait -PassThru
$exitCode = $process.ExitCode
Write-Output "Setup exited with code $exitCode at $(Get-Date)" | Out-File $logFile -Append

# Common exit codes reference
switch ($exitCode) {
    0           { Write-Output "Success: Upgrade completed successfully." | Tee-Object -FilePath $logFile -Append }
    3010        { Write-Output "Success: Upgrade completed, reboot required." | Tee-Object -FilePath $logFile -Append }
    1           { Write-Output "Error: Incorrect function." | Tee-Object -FilePath $logFile -Append }
    5           { Write-Output "Error: Access denied (permissions issue)." | Tee-Object -FilePath $logFile -Append }
    87          { Write-Output "Error: Invalid parameter passed to setup.exe." | Tee-Object -FilePath $logFile -Append }
    1603        { Write-Output "Error: Fatal error during installation." | Tee-Object -FilePath $logFile -Append }
    1639        { Write-Output "Error: Invalid command-line argument." | Tee-Object -FilePath $logFile -Append }
    2147781575  { Write-Output "Error: Setup failed � generic failure." | Tee-Object -FilePath $logFile -Append }
    Default     { Write-Output "Unknown exit code: $exitCode" | Tee-Object -FilePath $logFile -Append }
}

# Dismount ISO
Dismount-DiskImage -ImagePath $file

# Resume BitLocker
foreach ($vol in $bitlockerVolumes) {
    Resume-BitLocker -MountPoint $vol.MountPoint
    Write-Output "BitLocker resumed on $($vol.MountPoint) at $(Get-Date)" | Out-File $logFile -Append
}

exit $exitCode
