# Software to be uninstalled
$software = "qBackup"

# Registry paths to search for installed software
$registryPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

# Track if software was located
$found = $false

# Query registry for uninstall strings and execute them silently
foreach ($regPath in $registryPaths) {
    Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue | ForEach-Object {
        $displayName = $_.GetValue("DisplayName")
        if ($displayName -like "*$software*") {
            $found = $true
            $uninstallString = $_.GetValue("UninstallString")

            if ($uninstallString) {
                Write-Host "Found: $displayName"
                Write-Host "Uninstall String: $uninstallString"

                # Add generic silent flags depending on installer format
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

# Exit script if software not found
if (-not $found) {
    Write-Host "No matching software found for pattern: $software. Exiting script."
    exit 0
}

# Post-uninstall check
Start-Sleep -Seconds 5

$stillPresent = $false
foreach ($regPath in $registryPaths) {
    Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.GetValue("DisplayName") -like "*$software*") {
            $stillPresent = $true
        }
    }
}

if ($stillPresent) {
    Write-Host "WARNING: $software is still installed."
} else {
    Write-Host "$software successfully uninstalled."
}
