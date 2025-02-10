# Defining variables
$errMsg = $_.ExceptionMessage
$userNames = @('Migration','lcadmn','lcadmn2021','lcadmn2023','lcadmn2024')
$localAdmins =  Get-LocalUser | Where-Object {$_.Name -like "*lcadmn*" -or "*migration*"} | Where-Object {$_.Enabled -eq 'true'} | Where-Object { $_.Name -notlike '*~0000AEAdmin*'} -ErrorAction SilentlyContinue

# Remove any local administrator accounts created by EWA
if ($localAdmins) {
$UserNames | Where-Object {$userNames -contains $_}
try {
Write-Output "Removing $localAdmins"
Remove-LocalGroupMember -Group Administrators -Member $localAdmins -ErrorAction SilentlyContinue
Remove-LocalGroupMember -Group Users -Member $localAdmins -ErrorAction SilentlyContinue
Remove-LocalUser -Name $localAdmins -Confirm:$false
}
Catch {
Write-Host $errMsg
}
}