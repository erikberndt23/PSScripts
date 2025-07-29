# software to be uninstalled

$software = "*<APP_NAME>*"

# registry path to search for installed software

$registryPaths = @(
'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)
# Query registry for uninstall strings for software to be uninstalled and uninstall it via CMD with generic/default silent strings

foreach ($regPath in $registryPaths) {
    Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue | ForEach-Object {
        $displayName = $_.GetValue("DisplayName") 
        if ($displayName -like $software) {
            $uninstallString = $_.GetValue("UninstallString")

            if ($uninstallString) {
                Write-Host "Found: $displayName"
                Write-Host "Uninstall String: $uninstallString"

                # Normalize quotes (if needed)
                if ($uninstallString -match '^"') {
                    $uninstallString = "$uninstallString /SP- /verysilent"
                } elseif ($uninstallString -like "*msiexec*") {
                    $uninstallString += " /quiet /norestart"
                } else {
                    $uninstallString = "`"$uninstallString`" /quiet /norestart"
                }

                # Execute the uninstall command
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallString" -NoNewWindow -Wait
            }
        }
    }
}
