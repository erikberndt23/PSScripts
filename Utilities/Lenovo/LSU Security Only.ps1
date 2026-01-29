# Check for Lenovo Driver and Firmware Updates

# Variables
$regPath = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)
$lsuPath = Get-ChildItem -path $reg | Get-ItemProperty | Where-Object { $_.DisplayName -like "Lenovo System Update*" }
$all = "A" # All applicable updates
$critical = "C" # Critical updates only (security and urgent fixes)
$driversOnly = "D" # Drivers only
$bios = "F" # Firmware/BIOS only
$security = "S" # Security updates only

if (!$lsuPath) {
    Write-Output "$($lsuPath.DisplayName) is not installed. Exiting script"
    Exit 1
}
else {
Write-Host "Proceeding with update check..."
}

# Apply critical updates silently

Write-Host "Running Lenovo System Update scan + install..."

$proc = Start-Process -FilePath $lsuExe -ArgumentList "/CM -search $security -action INSTALL -noicon -norestart" -Wait -PassThru

# Exit Codes

switch ($proc.ExitCode) {
    0     { Write-Host "Updates installed successfully."; exit 0 }
    1     { Write-Host "Update error."; exit 1 }
    3010  { Write-Host "Updates installed. Reboot required."; exit 3010 }
    default {
        Write-Host "LSU completed with exit code $($proc.ExitCode)"
        exit $proc.ExitCode
    }
}