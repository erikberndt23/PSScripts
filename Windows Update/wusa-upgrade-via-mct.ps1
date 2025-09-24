# Define the URL for the latest Windows 11 Media Creation Tool
$MCTUrl = "https://go.microsoft.com/fwlink/?linkid=2156295"  # Always check for latest URL

# Define the path to download the MCT
$DownloadPath = "$env:TEMP\MediaCreationTool.exe"

# Download the Media Creation Tool
Invoke-WebRequest -Uri $MCTUrl -OutFile $DownloadPath

# Optional: Verify file exists
if (-Not (Test-Path $DownloadPath)) {
    Write-Error "Media Creation Tool download failed."
    exit 1
}

# Run the Media Creation Tool silently for an in-place upgrade
Start-Process -FilePath $DownloadPath -ArgumentList "/auto upgrade /quiet /noreboot" -Wait

# Optionally, reboot automatically after upgrade completes
Write-Host "Upgrade process started. Please reboot the system to complete installation."
