# Get the MSI uninstall string for Trellix Endpoint Security
$msi = (Get-Package | Where-Object { $_.Name -like "*Trellix Endpoint Security*" }).FastPackageReference

# Uninstall the package using if the package was found
if ($msi) {
    Start-Process msiexec.exe -Wait -ArgumentList "/x $msi /qn /norestart"

    # Check if the Xagt process is still running
    if (-not (Get-Process "Xagt" -ErrorAction SilentlyContinue)) {
        Write-Host "Trellix Endpoint Security Uninstalled!"
    } else {
        Write-Host "Trellix service is still running."
    }
} else {
    Write-Host "Trellix Endpoint Security package not running or not found."
}