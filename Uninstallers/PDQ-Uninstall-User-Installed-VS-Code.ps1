# Run this script with user privileges to uninstall user-installed Visual Studio Code
# Get the current user's profile path
$UserProfile = [Environment]::GetFolderPath('LocalApplicationData')

# Path to user-installed VS Code
$VSCodePath = Join-Path $UserProfile "Programs\Microsoft VS Code"

# Check if VS Code exists
if (Test-Path $VSCodePath) {
    Write-Host "Uninstalling Visual Studio Code from user profile..."

    # Try to run the uninstaller if it exists
    $Uninstaller = Join-Path $VSCodePath "unins000.exe"
    if (Test-Path $Uninstaller) {
        Start-Process -FilePath $Uninstaller -ArgumentList "/SILENT" -Wait
        Write-Host "Visual Studio Code uninstalled successfully."
    }
    else {
        # If no uninstaller, just remove the folder
        Remove-Item -Path $VSCodePath -Recurse -Force
        Write-Host "Visual Studio Code folder removed."
    }
}
else {
    Write-Host "No user-installed Visual Studio Code found."
}