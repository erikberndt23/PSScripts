# Defining variables
$errMsg = $_.ExceptionMessage
$userNames =  Get-LocalUser | Where-Object {$_.Name -like "*lcadmn*" -or "Migration"} | Where-Object {$_.Enabled -eq 'true'} | Where-Object { $_.Name -notlike '*~0000AEAdmin*'} -ErrorAction SilentlyContinue
# Check if EWA local admin accounts exist
if ($userNames) {  
Write-Host "Remediation required - local admins do exist!"
exit 1
} Else { ($userNames -eq $false)
Write-Host "No remediation required - local admins don't exist!"
Write-Host $errMsg
exit 0
}