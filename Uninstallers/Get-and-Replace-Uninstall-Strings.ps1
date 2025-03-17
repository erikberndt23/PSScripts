# Good script for when product uninstall strings specify "Msiexec /I" instead of "/Uninstall"
# Replaces "/i" with "/x" and appends "/qn /norestart" for MSI uninstalls
# Enter software to be uninstalled silently on line 12

# Locate uninstall strings
$registry = @(
    'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

# Exact name of software to be uninstalled
$software = "7-Zip 24.09 (x64 edition)"

# Uninstall software
foreach ($view in $registry) {
    $uninstallMatches = Get-ItemProperty $view |
                        Where-Object { $_.DisplayName -like "$software" -and $_.UninstallString }

    if ($uninstallMatches) {
        foreach ($match in $uninstallMatches) {
            if ($match.UninstallString -match "msiexec.exe") {
                $MSICommand = $match.UninstallString.ToLower().Replace("msiexec.exe", "").Replace("/i{", "/x{").Trim()
                $MSICommand = $MSICommand + " /qn /norestart"

                Write-Host "Uninstalling $($match.DisplayName) using MSI..."
                $processInfo = Start-Process -FilePath "msiexec.exe" -ArgumentList $MSICommand -PassThru -Wait
            } else {
                $uninstallString = $match.UninstallString
                Write-Host "Uninstalling $($match.DisplayName)..."
                $processInfo = Start-Process -ArgumentList "$uninstallString" -PassThru -Wait
            }

            if ($processInfo.ExitCode -eq 0) {
                Write-Host "Uninstall complete."
            } else {
                Write-Host "Uninstall failed with exit code $($processInfo.ExitCode)."
            }
        }
    }
}