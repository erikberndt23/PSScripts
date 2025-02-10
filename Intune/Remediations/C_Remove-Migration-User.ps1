# Defining variables
$errMsg = $_.ExceptionMessage
$userNames = @('Migration','lcadmn','lcadmn2021','lcadmn2023','lcadmn2024')
$localAdmins = Get-LocalGroupMember -Group Administrators | Where-Object { $_.PrincipalSource -eq "local"} | Where-Object {$_.Name -like "*lcadmn*" -or "*migration*"}

if ($localAdmins) {
$UserNames | Where-Object {$userNames -contains $_}
try {
Write-Output "Removing $userNames"
Remove-LocalGroupMember -Group Administrators -Member $localAdmins -ErrorAction SilentlyContinue -WhatIf
Remove-LocalGroupMember -Group Users -Member $userName -ErrorAction SilentlyContinue -WhatIf
Remove-LocalUser -Name $localAdmins -Comfirm:$true -WhatIf
Exit 0
}
Catch {
Write-Host $errMsg
Exit 1
}
}