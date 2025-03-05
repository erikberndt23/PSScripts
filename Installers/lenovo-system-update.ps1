$lenovoSystemUpdate = Get-Package -Name "Lenovo System Update"
$installerLocation = "C:\Users\erikb\Downloads\system_update_5.08.03.59.exe"
$arguments = @(
    "/SP-"
    "/verysilent"
    "/norestart"
    "/log"
)

if ($lenovoSystemUpdate.Name -Contains "Lenovo System Update") {
Write-Output "Lenovo System Update is already installed - exiting"
}

else {
Write-Host "Lenovo System Update is not installed - installing now"
Start-Process $installerLocation -ArgumentList $Arguments
}