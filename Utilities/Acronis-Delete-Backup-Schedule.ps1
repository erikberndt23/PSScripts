$app = Get-Package -Name "*Acronis True Image*"
$downloadUrl = https://acronis.file.force.com/sfc/dist/version/download/?oid=00D300000000Zcb&ids=0681T00000OfiwU&d=%2Fa%2F1T000001CLaM%2F8B5s7QKcRagXdnK43bnex.L8MheUeRJg0aj0OOZC8sE&asPdf=false
$downloadLocation = $env:temp
$schedTool = "$downloadLocation\schedmgr.exe"
$schedArgs = @(
    "task zap"
)

# Check if Acronis True Image is Installed
if ($app.Name -contains "Acronis True Image") {
    Write-Host "Acronis True Image is installed - removing backup schedule!"

# Download Acronis Schedule Manager
Invoke-WebRequest -Uri $downloadUrl -outFile $downloadLocation\schedmgr.exe

# Run Schedule Manager and disable all backup jobs
Start-Process -FilePath $schedTool -ArgumentList $schedArgs
}
Else {
    Write-Host "Acronis True Image is not installed - exiting script!"
    Exit 1
}