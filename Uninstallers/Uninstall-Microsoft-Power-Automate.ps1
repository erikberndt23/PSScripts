$errMsg = $_.ExceptionMessage

# Detect whether Microsoft Power Automate is installed and remove it

if 
(Get-AppxPackage -AllUsers | Where-Object {$_.Name -Like '*PowerAutomate*'}) {
Write-Output "Not Compliant - Power Automate Installed - Remediation Required"
try{
    Get-AppxPackage -AllUsers | Where-Object {$_.Name -Like '*PowerAutomate*'} | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Write-Host "Remediation Complete - Microsoft Power Automate successfully removed!"
}
catch{
    Write-Error "Remediation Failed - Error removing Power Automate!"
    Write-Host $errMsg
}
}
else {
Write-Output "Compliant - Microsoft Power Automate not Installed - No Remediation Required"
Exit 0
}