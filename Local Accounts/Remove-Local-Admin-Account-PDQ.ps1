$userName = "astiadmin"
$profilePath = "$env:SystemDrive\Users\$userName"

try {
    # Locate the user account
    $user = Get-LocalUser -Name $userName -ErrorAction Stop
    Write-Host "$userName account found..."

    # Delete the account
    Write-Host "Deleting $userName account..."
    Remove-LocalUser -Name $userName
    Write-Host "$userName account deleted!"

    # Remove the user profile directory if it exists
    if (Test-Path -Path $profilePath) {
        Write-Host "Removing $userName profile directory..."
        Remove-Item -Path $profilePath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "$userName profile directory removed!"
    }
    else {
        Write-Host "No profile directory found for $userName"
    }
}
catch {
    Write-Host "$userName account not found...Exiting script!"
    Exit 0
}
