Import-Module ActiveDirectory

# Configuration
$groupName  = "service accounts"
$gmsaOU     = "OU=Managed Service Accounts,DC=asti-usa,DC=net"

$outputPath = "C:\Logs\GroupLoginActivity_$(Get-Date -Format 'yyyyMMdd')_$env:COMPUTERNAME.csv"

# Resolve the group
$group = Get-ADGroup -Identity $groupName

if (-not $group) {
    Write-Error "Group '$groupName' not found."
    return
}

Write-Host "Resolved group: $($group.DistinguishedName)"

# Get recursive group membership via LDAP matching rule (includes users and gMSAs that are members)
$groupMembers = Get-ADObject -LDAPFilter "(&(memberOf:1.2.840.113556.1.4.1941:=$($group.DistinguishedName))(|(objectClass=user)(objectClass=msDS-GroupManagedServiceAccount)))" -Properties SamAccountName |
    Select-Object -ExpandProperty SamAccountName

Write-Host "Found $($groupMembers.Count) users/gMSAs as members of '$groupName'"

# Also pull ALL gMSAs directly from the specified OU, regardless of group membership
$ouGMSAs = Get-ADServiceAccount -Filter * -SearchBase $gmsaOU |
    Select-Object -ExpandProperty SamAccountName

Write-Host "Found $($ouGMSAs.Count) gMSAs directly in OU '$gmsaOU'"

# Combine both sets, removing duplicates (in case a gMSA is both in the OU and a group member)
$members = @($groupMembers + $ouGMSAs) | Select-Object -Unique

if (-not $members -or $members.Count -eq 0) {
    Write-Warning "No members resolved from group '$groupName' or OU '$gmsaOU'. Exiting."
    return
}

Write-Host "Total unique accounts to check: $($members.Count)"

# Query local Security log for logon events (4624) in the last 30 days
$results = Get-WinEvent -FilterHashtable @{
    LogName   = 'Security'
    Id        = 4624
    StartTime = $startDate
} | Where-Object {
    $_.Properties[5].Value -in $members
} | Select-Object TimeCreated,
    @{N='User';E={$_.Properties[5].Value}},
    @{N='LogonType';E={$_.Properties[8].Value}},
    @{N='SourceIP';E={$_.Properties[18].Value}},
    @{N='DC';E={$env:COMPUTERNAME}}

# Export results
$results | Sort-Object TimeCreated -Descending |
    Export-Csv -Path $outputPath -NoTypeInformation

Write-Host "Done. $($results.Count) logon events found on $env:COMPUTERNAME. Exported to $outputPath"

# To merge CSVs from multiple DCs later:
#Get-ChildItem "C:\Logs\*.csv" | ForEach-Object {
#Import-Csv -Path $_.FullName } | Sort-Object TimeCreated -Descending | Export-Csv "C:\Logs\GroupLoginActivity_Combined.csv" -NoTypeInformation
