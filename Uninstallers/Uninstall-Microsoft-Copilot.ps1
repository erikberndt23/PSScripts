$errMsg = $_.ExceptionMessage

# Detect whether Microsoft Copilot is installed and remove it

if 
(Get-AppxPackage -AllUsers | Where-Object {$_.Name -Like '*Copilot*'}) {
Write-Output "Not Compliant - Copilot Installed - Remediation Required"
try{
    Get-AppxPackage -AllUsers | Where-Object {$_.Name -Like '*CoPilot*'} | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Write-Host "Remediation Complete - Microsoft Copilot successfully removed!"
}
catch{
    Write-Error "Remediation Failed - Error removing Copilot!"
    Write-Host $errMsg
}
}
else {
Write-Output "Compliant - Microsoft Copilot not Installed - No Remediation Required"
Exit 0
}