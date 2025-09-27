# Get the MSI GUID for OpenVPN
$msi = (Get-Package | Where-Object { $_.Name -like "OpenVPN 2.*" }).FastPackageReference

# Uninstall the package using if the package was found
if ($msi) {
    Start-Process msiexec.exe -Wait -ArgumentList "/x $msi /qn /norestart"
    Write-Host "OpenVPN successfully uninstalled!"

} else {
    Write-Host "OpenVPN not found..."
}