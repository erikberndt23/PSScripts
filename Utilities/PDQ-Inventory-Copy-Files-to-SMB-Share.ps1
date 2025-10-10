# Source and destination and other parameters

$Source = "C:\ProgramData\Admin Arsenal\PDQ Inventory\Backups"
$Destination = "\\<YourServerHere>\pdq\config\deploy"
$logFile = "C:\Temp\PDQInventoryBackupLog.txt"
$Username = "<YourUsernameHere>"
$Password = "<YourPasswordHere>"

# Convert password to a secure string and create a PSCredential object

$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)

# Map the temporary network drive

$DriveLetter = "Z:"
New-PSDrive -Name Z -PSProvider FileSystem -Root $Destination -Credential $Credential -Persist | Out-Null

# Verify the drive is accessible

if (Test-Path "$DriveLetter\") {
    Write-Host "Connected to SMB share as $Username"
    
    # Copy files recursively with robocopy
    Robocopy $Source "$driveLetter" /MIR /XO /R:3 /W:5 /Log:$logFile
    Write-Host "Files copied successfully."

    # Remove the temporary drive

    Remove-PSDrive -Name Z
} else {
    Write-Host "Failed to connect to SMB share."
}