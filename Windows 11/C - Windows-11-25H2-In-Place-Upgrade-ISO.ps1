$dir = "C:\temp\win11"
New-Item -ItemType Directory -Path $dir -Force | Out-Null

# Paths

$logFile   = Join-Path $dir "Upgrade.log"
$isoFile   = "$dir\Win11_25H2_English_x64.iso"
$logFolder = "$dir\Win11Logs"

# Download Latest Windows 11 ISO

$webClient = New-Object System.Net.WebClient
$url = 'https://isos.asti-usa.com/ITDept/Windows%2011/Win11_25H2_English_x64.iso'
Write-Output "[$(Get-Date)] Downloading ISO from $url" | Out-File $logFile -Append
$webClient.DownloadFile($url, $isoFile)

# Clean up old upgrade leftovers

Write-Output "[$(Get-Date)] Cleaning up previous upgrade folders" | Out-File $logFile -Append
Remove-Item "C:\$WINDOWS.~BT" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\$WINDOWS.~WS" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\$WinREAgent" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $logFolder -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $logFolder -Force | Out-Null

# Suspend BitLocker

Write-Output "[$(Get-Date)] Suspending BitLocker" | Out-File $logFile -Append
$bitlockerVolumes = Get-BitLockerVolume | Where-Object { $_.VolumeStatus -eq "FullyEncrypted" -and $_.LockStatus -eq "Unlocked" }
foreach ($vol in $bitlockerVolumes) {
    Suspend-BitLocker -MountPoint $vol.MountPoint -RebootCount 2
    Write-Output "[$(Get-Date)] BitLocker suspended on $($vol.MountPoint)" | Out-File $logFile -Append
}

# Mount ISO

$mountResult = Mount-DiskImage -ImagePath $isoFile -PassThru
$driveLetter = ($mountResult | Get-Volume | Where-Object FileSystemLabel -ne $null).DriveLetter + ":"
$setupPath   = Join-Path $driveLetter "setup.exe"

Write-Output "[$(Get-Date)] Starting Windows 11 upgrade from $setupPath" | Out-File $logFile -Append

# Run setup.exe silently

$arguments = "/Auto Upgrade /Quiet /NoReboot /Eula Accept /DynamicUpdate Disable /Compat IgnoreWarning /CopyLogs $logFolder"
$process = Start-Process -FilePath $setupPath -ArgumentList $arguments -Wait -PassThru
$exitCode = $process.ExitCode

Write-Output "[$(Get-Date)] Setup exited with code $exitCode" | Out-File $logFile -Append

# Exit code handling

switch ($exitCode) {
    0           { Write-Output "[$(Get-Date)] Success: Upgrade completed successfully." | Tee-Object -FilePath $logFile -Append }
    3010        { Write-Output "[$(Get-Date)] Success: Upgrade completed, reboot required." | Tee-Object -FilePath $logFile -Append }
    1           { Write-Output "[$(Get-Date)] Error: Incorrect function." | Tee-Object -FilePath $logFile -Append }
    5           { Write-Output "[$(Get-Date)] Error: Access denied (permissions issue)." | Tee-Object -FilePath $logFile -Append }
    87          { Write-Output "[$(Get-Date)] Error: Invalid parameter passed to setup.exe." | Tee-Object -FilePath $logFile -Append }
    1603        { Write-Output "[$(Get-Date)] Error: Fatal error during installation." | Tee-Object -FilePath $logFile -Append }
    1639        { Write-Output "[$(Get-Date)] Error: Invalid command-line argument." | Tee-Object -FilePath $logFile -Append }
    2147781575  { Write-Output "[$(Get-Date)] Error: Setup failed – generic failure." | Tee-Object -FilePath $logFile -Append }
    Default     { Write-Output "[$(Get-Date)] Unknown exit code: $exitCode" | Tee-Object -FilePath $logFile -Append }
}

# Dismount ISO

Dismount-DiskImage -ImagePath $isoFile

# Resume BitLocker

foreach ($vol in $bitlockerVolumes) {
    Resume-BitLocker -MountPoint $vol.MountPoint
    Write-Output "[$(Get-Date)] BitLocker resumed on $($vol.MountPoint)" | Out-File $logFile -Append
}

exit $exitCode
# Note: A reboot may be required to complete the upgrade process.