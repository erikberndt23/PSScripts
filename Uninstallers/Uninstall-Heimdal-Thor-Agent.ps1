# Application to be uninstalled

$softwareName = "Heimdal Thor Agent"
$uninstallPassword = "*************"
$arguments = @(
    "/x", "$msi",
    "/qn",
    "/norestart",
    "uninstallPassword=$uninstallPassword"
)

# Get the MSI GUID for application to be uninstalled

$msi = (Get-Package -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "$softwareName" }).FastPackageReference

# Uninstall the package silently if application is installed

if ($msi) {
    Write-Host "$softwareName is installed. Uninstalling now..."
    Start-Process -FilePath msiexec.exe -ArgumentList $arguments -Wait -NoNewWindow
    Write-Host "$softwareName successfully uninstalled!"

# Post uninstall check

$stillInstalled = Get-Package -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$softwareName*" }

if ($stillInstalled) {
    Write-Host "$softwareName is still installed..."
}

} else {
    Write-Host "$softwareName not found...Exiting script!"
}