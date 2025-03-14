# Define registry paths where uninstall information is stored
$UninstallKeys = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

# Search for uninstall strings in the registry and uninstall Adobe Acrobat Reader silently
$app = Get-ChildItem -Path $UninstallKeys | Get-ItemProperty | Where-Object {$_.DisplayName -like "*Adobe Acrobat Reader*" }

foreach ($key in $UninstallKeys) {
    Get-ItemProperty -Path $Key -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.DisplayName -eq $app.DisplayName -and $_.UninstallString) {
            $SilentUninstallString = if ($_.QuietUninstallString) { $_.QuietUninstallString } else { $_.UninstallString + " /qn /norestart" }
            Write-Output "Found: $($_.DisplayName)"
            Write-Output "Uninstalling: $($_.DisplayName)"
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c $SilentUninstallString" -NoNewWindow -Wait
            Write-Output "$($_.DisplayName) has been uninstalled silently."
        }
    }
}
