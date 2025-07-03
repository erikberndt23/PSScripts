# Export to CSV
Get-ADUser -filter * -searchbase "OU='OU TO SEARCH',DC='asti-usa',DC='net'" -properties passwordlastset, passwordneverexpires, CanonicalName | sort-object name, CanonicalName | select-object Name, CanonicalName, passwordlastset, passwordneverexpires | Export-csv -path $env:temp\user-password-change-info.csv
Start-Sleep -s 5
Get-ChildItem -Filter $env:temp\user-password-change-info.csv| Select-Object -ExpandProperty FullName | Import-Csv | Export-Csv $env:temp\merged.csv -NoTypeInformation -Append

# One Liner
Get-ADUser -filter * -properties PasswordLastSet | Sort-Object Name | Format-Table Name, PasswordLastSet