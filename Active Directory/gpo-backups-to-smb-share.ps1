# Source, destination and log parameters
$Source      = "C:\GPO_Backup"
$Destination = "\\qnap01-10g\gpo-backups"
$logFile     = "C:\Windows\Temp\GPOBackupLog.txt"
$DriveLetter = "Z:"

# Map the temporary network drive using credential stored in Credential Manager
New-PSDrive -Name Z -PSProvider FileSystem -Root $Destination -Persist | Out-Null

if (Test-Path "$DriveLetter\") {
    Write-Host "Connected to SMB share"
    Robocopy $Source $DriveLetter /MIR /XO /R:3 /W:5 /Log:$logFile
    Write-Host "Files copied successfully."
    Remove-PSDrive -Name Z
    Exit 0
} else {
    Write-Host "Failed to connect to SMB share."
    Exit 1
}