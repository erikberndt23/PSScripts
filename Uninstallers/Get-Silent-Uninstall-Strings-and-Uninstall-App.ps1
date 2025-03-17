# Search for app uninstall entries in registry
# Update app name on lines 3 & 35 to uninstall other applications
$apps = Get-ChildItem -Path $UninstallKeys | Get-ItemProperty | Where-Object -Property DisplayName -Like "*PuTTY*"

# Variable to verify if the application is still installed
$software = Get-Package -Name "PuTTY*" -ErrorAction SilentlyContinue

# Define registry paths where uninstall information is stored
$uninstallKeys = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

if ($software.Name) {
Write-Output "$($app.displayName) is installed - continuing"
}

else {
Write-Output "$($app.displayName) is not installed - exiting"
exit 1
}

# Uninstall app silently
foreach ($app in $apps) {
    if ($app.UninstallString) {
        # Determine the silent uninstall command
        $SilentUninstallString = if ($app.QuietUninstallString) { $app.QuietUninstallString } else { "$($app.UninstallString) /qn /norestart" }    
        Write-Output "Found: $($app.DisplayName)"
        Write-Output "Uninstalling: $($app.DisplayName)"

        # Execute the uninstall command silently
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "$SilentUninstallString" -NoNewWindow -Wait
        Start-Sleep -Seconds 15
        # Determine if app is still installed
        $remainingApp = Get-ChildItem -Path $UninstallKeys | Get-ItemProperty | Where-Object { $_.DisplayName -Like "*PuTTY*" }

        if ($remainingApp) {
            Write-Output "$($app.DisplayName) is still installed"
        } else {
            Write-Output "$($app.DisplayName) has been uninstalled"
        }
    }
}