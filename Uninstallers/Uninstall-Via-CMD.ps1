# Software to be uninstalled
$software = "*<APP_NAME>*"

# Registry paths to search for installed software
$registryPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

# Query registry for uninstall strings and execute them silently
foreach ($regPath in $registryPaths) {
    Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue | ForEach-Object {
        $displayName = $_.GetValue("DisplayName")
        if ($displayName -like $software) {
            $uninstallString = $_.GetValue("UninstallString")

            if ($uninstallString) {
                Write-Host "Found: $displayName"
                Write-Host "Uninstall String: $uninstallString"

                # Add generic silent flags
                if ($uninstallString -like "*msiexec*") {
                    $uninstallString += " /quiet /norestart"
                } else {
                    $uninstallString += " /SP- /verysilent"
                }

                # Execute the uninstall command
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallString" -NoNewWindow -Wait
            }
        }
    }
}
