Import-Module ActiveDirectory

# Change this to your threshold
$DaysInactive = 90

$CurrentDate = Get-Date
$StaleDate = $CurrentDate.AddDays(-$DaysInactive)

# Locate inactive users
$StaleUsers = Get-ADUser -Filter * -Properties Name, LastLogonDate, Enabled |
    Where-Object {
        $_.Enabled -eq $true -and
        $_.LastLogonDate -lt $StaleDate
    } |
    Select-Object Name, SamAccountName, LastLogonDate, Enabled

$StaleUsers | Format-Table -AutoSize

# Export to a CSV
$StaleUsers | Export-Csv -Path "C:\temp\StaleADUsers.csv" -NoTypeInformation
Write-Host "`nFound $($StaleUsers.Count) stale user accounts older than $DaysInactive days." -ForegroundColor Yellow
