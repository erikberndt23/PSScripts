# Grab the full Package object in JSON
# This script is needlessly convulated because of a bug in Powershell remoting where Get-AppxPackage returns an error
$teamsJson = powershell.exe -command "(Get-AppxPackage -AllUsers -Name '*MSTeams*') | ConvertTo-Json"

# Convert back to object
$teams = $teamsJson | ConvertFrom-Json

# Loop through results and output PSCustomObject for use in PDQ Inventory
foreach ($t in $teams) {
    [PSCustomObject]@{
        Name    = $t.Name
        Version = $t.Version
    }
}
