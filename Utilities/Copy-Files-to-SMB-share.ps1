# Source and destination 

$Source = "C:\ProgramData\Admin Arsenal\PDQ Deploy\Backups"
$Destination = "\\qnap01-10g\pdq\config\deploy"

# Credentials

$Username = ""
$Password = ""

# Convert password to a secure string

$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

# Create credential object
$Credential = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)

# Map a temporary network drive

$DriveLetter = "Z:"
New-PSDrive -Name Z -PSProvider FileSystem -Root $Destination -Credential $Credential -Persist | Out-Null

# Verify the drive is accessible

if (Test-Path "$DriveLetter\") {
    Write-Host "Connected to SMB share as $Username"
    
    # Copy files recursively
    Copy-Item -Path $Source\* -Destination "$DriveLetter\" -Recurse -Force
    Write-Host "Files copied successfully."
    
    # Remove the temporary drive
    Remove-PSDrive -Name Z
} else {
    Write-Host "Failed to connect to SMB share."
}
