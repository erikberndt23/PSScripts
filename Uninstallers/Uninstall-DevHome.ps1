$errMsg = $_.ExceptionMessage

# Detect whether Dev Home is installed and remove it

if 
(Get-AppxPackage -AllUsers | Where-Object {$_.Name -Like '*DevHome*'}) {
Write-Output "Not Compliant - Dev Home Installed - Remediation Required"
try{
    Get-AppxPackage -AllUsers | Where-Object {$_.Name -Like '*DevHome*'} | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Write-Host "Remediation Complete - Dev Home successfully removed!"
}
catch{
    Write-Error "Remediation Failed - Error removing Dev Home!"
    Write-Host $errMsg
}
}
else {
Write-Output "Compliant - Dev Home not Installed - No Remediation Required"
Write-Host $errMsg
Exit 0
}