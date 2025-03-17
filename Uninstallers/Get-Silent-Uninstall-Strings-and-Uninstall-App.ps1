# Define registry paths where uninstall information is stored
$UninstallKeys = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

# Search for app uninstall entries
$apps = Get-ChildItem -Path $UninstallKeys | Get-ItemProperty | Where-Object { $_.DisplayName -like "*PuTTY*" }

# Process each found application
foreach ($app in $apps) {
    if ($app.UninstallString) {
        $SilentUninstallString = if ($app.QuietUninstallString) { $app.QuietUninstallString } else { $app.UninstallString + " /qn /norestart" }      
        Write-Output "Found: $($app.DisplayName)"
        Write-Output "Uninstalling: $($app.DisplayName)"
    
        # Execute the uninstall command silently
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c $SilentUninstallString" -NoNewWindow -Wait

        # Check if app is still listed in registry
        $remainingApps = Get-ChildItem -Path $UninstallKeys | Get-ItemProperty | Where-Object { $_.DisplayName -like "$app.DisplayName" }

# Check if app actually uninstalled
        if ($remainingApps) {
        Write-Output "$app.DisplayName is still installed."
}   else {
    Write-Output "$($app.DisplayName) has been uninstalled silently."
}
}
}