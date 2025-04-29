$msi = ((Get-Package | Where-Object { $_.Name -like "*WinlogBeat Agent*" }).fastpackagereference)
start-process msiexec.exe -wait -argumentlist  "/x $msi /qn /norestart"