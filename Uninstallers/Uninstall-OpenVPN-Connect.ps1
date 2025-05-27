# Get the MSI GUID for OpenVPN Connect
$msi = (Get-Package | Where-Object { $_.Name -like "OpenVPN Connect" }).FastPackageReference

# Uninstall the package using if the package was found
if ($msi) {
    Start-Process msiexec.exe -Wait -ArgumentList "/x $msi /qn /norestart"
    Write-Host "OpenVPN Connect successfully uninstalled!"

} else {
    Write-Host "OpenVPN Connect not found..."
}