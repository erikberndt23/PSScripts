$logPath = "C:\Logs\ASTi-Powershell-Transcripts"
$archivePath = "$logPath\Archive"
$retentionDays = 30

# Create archive directory if it doesn't exist
if (!(Test-Path -Path $archivePath)) {
    New-Item -ItemType Directory -Path $archivePath
}

# Get current date and time for archive file naming
$timestamp = Get-Date -Format "yyyyMMddHHmmss"

# Archive existing log files
Get-ChildItem -Path $logPath -Filter "*.txt" -Recurse -Force | ForEach-Object {
    $newFileName = "$($_.BaseName)_$timestamp$($_.Extension)"
    Move-Item -Path $_.FullName -Destination (Join-Path -Path $archivePath -ChildPath $newFileName)
}

# Delete old log files in the archive
$cutoffDate = (Get-Date).AddDays(-$retentionDays)
Get-ChildItem -Path $archivePath -Filter "*.txt" | Where-Object {$_.LastWriteTime -lt $cutoffDate} | Remove-Item