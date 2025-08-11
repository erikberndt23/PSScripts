# Application to be uninstalled

$softwareName = "ABAS GUI"

# Get the MSI GUID for application to be uninstalled

$msi = (Get-Package -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$softwareName*" }).FastPackageReference

# Uninstall the package silently if application is installed

if ($msi) {
    Write-Host "$softwareName is installed. Uninstalling now..."
    Start-Process msiexec.exe -Wait -PassThru -ArgumentList "/x $msi /qn /norestart"
    Write-Host "$softwareName successfully uninstalled!"

# Post uninstall check

$stillInstalled = Get-Package -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$softwareName*" }

if ($stillInstalled) {
    Write-Host "$softwareName is still installed..."
}

} else {
    Write-Host "$softwareName not found...Exiting script!"
}