$sourceFile = "\\asti-usa.net\NETLOGON\Heimdal\HeimdalLatestVersion.msi"
$destinationFile = "$env:temp\HeimdalLatestVersion.msi"

# Heimdal Thor Agent install parameters
$arguments = @(
    "/i" , "$destinationFile"
    "/qn"
    "/norestart"
)

# Check if Heimdal Thor Agent is already installed
if ($siteToken) {
        Write-Output "Heimdal is configured for this client, proceeding with app validation"
        if (Test-Path "C:\Program Files (x86)\Heimdal\Heimdal.ThorAgent.exe") {
        Write-Output "Heimdal is currently installed. No further configuration needed."
} 

# Silently install Heimdal Thor Agent if not detected
else {
    Write-Output "Heimdal Thor Agent is not installed. Proceeding with download and installation..."
    (New-Object System.Net.WebClient).DownloadFile($sourceFile,$destinationFile)
    Write-Output "Heimdal Thor Agent downloaded, proceeding with installation..."
    start-process -filepath msiexec.exe -ArgumentList $arguments -Wait -NoNewWindow
}
}
else {
    Write-Output "Heimdal Thor Agent installation failed "
}

# Cleanup
if (Test-Path $destinationFile) {
    Remove-Item $destinationFile -Force
}