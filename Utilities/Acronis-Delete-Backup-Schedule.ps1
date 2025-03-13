$app = Get-Package -Name "*Acronis True Image*"
$schedTool = "C:\Users\erikb\Documents\Tools\schedmgr.exe"
$schedArgs = @(
    "task zap"
)

# Check if Acronis True Image is Installed
if ($app.Name -contains "Acronis True Image") {
    Write-Host "Acronis True Image is installed - removing backup schedule!"
    Start-Process -FilePath $schedTool -ArgumentList $schedArgs
}
Else {
    Write-Host "Acronis True Image is not installed - exiting script!"
    Exit 1
}