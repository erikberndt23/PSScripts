$errMsg = $_.ExceptionMessage
$userName = "Migration"
$userExists = (Get-LocalUser).Name -like $userName
# Detect whether Migration user exists
if 
($userExists) {
Write-Output "Not Compliant - Migration User Exists - Remediation Required"
Write-Host $errMsg
exit 1
}
else {
Write-Output "Compliant - Migration User Not Detected - No Remediation Required"
Write-Host $errMsg
exit 0
}