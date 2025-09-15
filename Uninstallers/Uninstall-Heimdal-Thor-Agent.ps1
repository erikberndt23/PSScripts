# Application to be uninstalled

$softwareName = "Heimdal Thor Agent"
$uninstallPassword = "*************"

# Get the MSI GUID for application to be uninstalled

$msi = (Get-Package -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "$softwareName" }).FastPackageReference

$arguments = @(
    "/x", "$msi",
    "/qn",
    "/norestart",
    "uninstallPassword=$uninstallPassword"
)

# Uninstall the package silently if application is installed

if ($msi) {
    Write-Output "$softwareName is installed. Uninstalling now..."
    Start-Process -FilePath msiexec.exe -ArgumentList $arguments -PassThru -Wait -NoNewWindow
    Write-Output "$softwareName successfully uninstalled!"

# Post uninstall check

$stillInstalled = Get-Package -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$softwareName*" }

if ($stillInstalled) {
    Write-Output "$softwareName is still installed..."
}

} else {
    Write-Output "$softwareName not found...Exiting script!"
}