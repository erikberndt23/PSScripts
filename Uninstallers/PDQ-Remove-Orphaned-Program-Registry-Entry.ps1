# Run in currenttly logged on users context
# Program name to remove
$ProgramName = "Microsoft Visual Studio Code (User)"

# Current user's uninstall registry key
$UninstallPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"

# Remove orphaned uninstall key
if (Test-Path $UninstallPath) {
    Get-ChildItem $UninstallPath | ForEach-Object {
        $displayName = ($_ | Get-ItemProperty -ErrorAction SilentlyContinue).DisplayName
        if ($displayName -like "*$ProgramName*") {
            Remove-Item $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Removed orphaned uninstall key: $($_.PSPath)"
            Write-Host "`nCleanup complete. Refresh Programs and Features."
        }
    }
} else {
    Write-Host "No uninstall registry path found for current user."
}
# Note: This script only removes the registry entry and does not uninstall the actual application.