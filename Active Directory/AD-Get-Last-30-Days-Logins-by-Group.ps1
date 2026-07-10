Import-Module ActiveDirectory

# Configuration
$groupName  = "service accounts"
$startDate  = (Get-Date).AddDays(-30)
$outputPath = "C:\Logs\GroupLoginActivity_$(Get-Date -Format 'yyyyMMdd')_$env:COMPUTERNAME.csv"

# esolve the group
# If you have multiple groups with the same name in different OUs, use:
#   Get-ADGroup -Filter "Name -eq '$groupName'" -SearchBase "OU=Groups,DC=yourdomain,DC=com"
# to scope to the correct one instead of the line below.
$group = Get-ADGroup -Identity $groupName

if (-not $group) {
    Write-Error "Group '$groupName' not found."
    return
}

Write-Host "Resolved group: $($group.DistinguishedName)"

# Get recursive group membership via LDAP matching rule
$members = Get-ADUser -LDAPFilter "(memberOf:1.2.840.113556.1.4.1941:=$($group.DistinguishedName))" |
    Select-Object -ExpandProperty SamAccountName

if (-not $members -or $members.Count -eq 0) {
    Write-Warning "No members resolved for group '$groupName'. Exiting."
    return
}

Write-Host "Found $($members.Count) users in group '$groupName'"

# Query local Security log for logon events (4624) in the last 30 days
# Returns all logon types, including interactive, network, remote interactive (RDP), etc.
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

#To merge CSVs from multiple DCs later, run this on your workstation:
# Get-ChildItem "C:\Logs\*.csv" |
#     Import-Csv |
#     Sort-Object TimeCreated -Descending |
#     Export-Csv "C:\Logs\GroupLoginActivity_Combined.csv" -NoTypeInformation