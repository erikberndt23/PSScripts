param (
    [Parameter(Mandatory = $true)]
    [string]$KBID
)

Write-Output "Checking for installed update KB..."

# Normalize KB (remove KB prefix if present)
$kbNum = $KBID -replace "KB",""

# Check if the update is installed
$installed = Get-HotFix | Where-Object { $_.HotFixID -eq "KB$kbNum" }

if ($installed) {
    Write-Output "Found update KB$kbNum, uninstalling..."
    Start-Process -Wait -FilePath "wusa.exe" -PassThru "/uninstall /kb:$kbNum"

    # Wait for uninstall to finish
    do {
        Start-Sleep -Seconds 5
        $wusaRunning = Get-Process -Name "wusa" -ErrorAction Stop
    } while ($wusaRunning)

    Write-Output "Uninstall of KB$kbNum completed."
    exit 0
}
else {
    Write-Output "Update KB$kbNum not installed, nothing to do."
    exit 0
}
