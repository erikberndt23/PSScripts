# Output CSV path
$OutputFile = "C:\Reports\BitLockerKeyCompliance.csv"
$OutputFolder = Split-Path $OutputFile
if (-not (Test-Path $OutputFolder)) { New-Item -Path $OutputFolder -ItemType Directory | Out-Null }
Write-Host "Generating BitLocker compliance report for Windows computers in Active Directory..."
# Get all Windows computers
$Computers = Get-ADComputer -Filter 'OperatingSystem -like "*Windows*"' -Properties Name, OperatingSystem, OperatingSystemVersion
$Results = @()
foreach ($Computer in $Computers) {
    # Query BitLocker recovery objects under this computer
    $BitLockerRecoveryInfo = Get-ADObject `
        -SearchBase $Computer.DistinguishedName `
        -SearchScope Subtree `
        -LDAPFilter "(objectClass=msFVE-RecoveryInformation)" `
        -ErrorAction SilentlyContinue
    # Normalize to array count (handles single-object vs. collection)
    $HasRecoveryKey = if ($BitLockerRecoveryInfo) { "Yes" } else { "No" }
    # Output to console only if missing
    if ($HasRecoveryKey -eq "No") {
        Write-Host "Computer: $($Computer.Name) - MISSING BitLocker Recovery Key" -ForegroundColor Red
    }
    # Add to results for CSV
    $Results += [PSCustomObject]@{
        ComputerName           = $Computer.Name
        OperatingSystem        = $Computer.OperatingSystem
        OperatingSystemVersion = $Computer.OperatingSystemVersion
        HasRecoveryKey         = $HasRecoveryKey
    }
}
# Export results to CSV
$Results | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8
Write-Host "Report complete. Results exported to $OutputFile" -ForegroundColor Green