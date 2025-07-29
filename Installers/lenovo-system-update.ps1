$installerLocation = "C:\PATH\TO\system_update_5.08.03.59.exe"
$arguments = @(
    "/SP-"
    "/verysilent"
    "/norestart"
    "/log"
)

# Check if Lenovo System Update is installed
$lenovoSystemUpdate = Get-Package -Name "Lenovo System Update" -ErrorAction SilentlyContinue

if ($lenovoSystemUpdate) {
    Write-Output "Lenovo System Update is already installed - exiting"
}
else {
    Write-Host "Lenovo System Update is not installed - installing now"
    Start-Process -FilePath $installerLocation -ArgumentList $arguments -Wait
}
