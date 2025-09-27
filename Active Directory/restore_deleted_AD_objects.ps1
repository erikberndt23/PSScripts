# Restore deleted computer object
get-adobject -filter 'isDeleted -eq $true' -IncludeDeletedObjects | where-object {$_.name -like "SPC-00247*" -and $_.objectclass -eq "computer"} | restore-adobject
# Restore deleted user object
get-adobject -filter 'isDeleted -eq $true' -IncludeDeletedObjects | where-object {$_.name -like "" -and $_.objectclass -eq "user"} | restore-adobject