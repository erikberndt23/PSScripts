$Defender = where.exe /r 'C:\Program Files\Windows Defender' MpCmdRun.exe
$Path = Read-Host "Please enter the exact file or folder path you wish to scan for viruses"
& $Defender -scan -scantype 3 -File $Path