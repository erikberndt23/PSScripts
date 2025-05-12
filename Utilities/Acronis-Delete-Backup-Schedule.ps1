$app = Get-Package -Name "Acronis True Image*" -AllVersions
$downloadUrl = "https://acronis.file.force.com/sfc/dist/version/download/?oid=00D300000000Zcb&ids=0681T00000OfiwU&d=%2Fa%2F1T000001CLaM%2F8B5s7QKcRagXdnK43bnex.L8MheUeRJg0aj0OOZC8sE&asPdf=false"
$downloadLocation = $env:temp
$schedTool = "$downloadLocation\schedmgr.exe"
$schedManager = "C:\Program Files (x86)\Acronis\BackupAndRecovery\schedmgr.exe"
$schedArgs = @(
    "task zap"
)
# Check if Acronis True Image is installed
$app = Get-Package -Name "Acronis True Image*" -AllVersions -ErrorAction SilentlyContinue

if ($app) {
    Write-Host "Acronis True Image is installed - removing scheduled backup jobs!"
    
    # Check if schedmgr.exe already exists
    if (Test-Path -Path $schedManager) {
        Write-Host "Scheduling tool exists. Removing backup jobs..."
        Start-Process -FilePath $schedManager -ArgumentList $schedArgs -Wait
    }
    else {
        Write-Host "Scheduling tool not found. Downloading..."
        Invoke-WebRequest -Uri $downloadUrl -OutFile $schedTool
        Write-Host "Purging Acronis Backup Schedule"
        if (Test-Path -Path $schedTool) {
            Start-Process -FilePath $schedTool -ArgumentList $schedArgs -Wait
        }
        else {
            Write-Error "Failed to download schedmgr.exe"
            Exit 1
        }
    }
}
else {
    Write-Host "Acronis True Image is not installed - exiting script!"
    Exit 0
}
