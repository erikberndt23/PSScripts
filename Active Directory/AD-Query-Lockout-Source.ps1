# Get primary domain controller
$PDC = (Get-ADDomainController -Filter * | Where-Object {$_.OperationMasterRoles -contains "PDCEmulator"})

# Get the username to check
$userName = "Username"

# Check security event log for Event ID 4740, indicating an account lockout
$LockedOutEvents = Get-WinEvent -ComputerName $PDC.HostName -FilterHashtable @{LogName='Security';Id=4740} -ErrorAction Stop | Sort-Object -Property TimeCreated -Descending

# Filter lockout evevnts for user
$UserLockoutEvent = $LockedOutEvents | Where-Object {$_.Message -like "*Account Name: $($userName)*"} | Select-Object -First 1

# Get the lockout source computer name
if ($UserLockoutEvent) {
    $LockoutSource = ($UserLockoutEvent.Message -split "`n" | Where-Object {$_ -like "*Caller Computer Name*"}).Split(":")[1].Trim()
    Write-Host "Account '$UserName' was locked out from: $LockoutSource"
    } else {
        Write-Host "No lockout events found for user '$UserName'."
    }