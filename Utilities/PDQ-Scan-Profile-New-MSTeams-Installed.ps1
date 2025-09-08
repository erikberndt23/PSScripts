# Grab the full AppxPackage object in JSON
$teamsJson = powershell.exe -command "(Get-AppxPackage -AllUsers -Name '*MSTeams*') | ConvertTo-Json"

# Convert back to object(s)
$teams = $teamsJson | ConvertFrom-Json

# Loop through results and output PSCustomObject
foreach ($t in $teams) {
    [PSCustomObject]@{
        Name    = $t.Name
        Version = $t.Version
    }
}