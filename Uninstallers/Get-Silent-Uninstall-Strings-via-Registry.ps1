# Program to be uninstalled
$App = Get-ChildItem -Path $uninstallStrings | Get-ItemProperty | Where-Object {$_.DisplayName -like "*Adobe Acrobat Reader*" }
$Adobe = $App.displayName

# Search for uninstall strings in the registry
$uninstallStrings = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*")

foreach ($Key in $uninstallStrings) {
    Get-ItemProperty -Path $Key -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.DisplayName -eq "$Adobe" -and $_.UninstallString) {
            [PSCustomObject]@{
                Name = $_.DisplayName
                UninstallString = $_.UninstallString
                SilentUninstallString = if ($_.QuietUninstallString) { $_.QuietUninstallString } else { $_.UninstallString + " /qn /norestart" }
            }
        }
    }
}