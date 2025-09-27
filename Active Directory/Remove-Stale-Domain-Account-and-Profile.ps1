# Domain account to be removed
$domainUser = "ASTI-USA\astidadmin"

Write-Host "Checking for stale account: $domainUser"

# Extract the username from the domain account

try {
    $profileName = $domainUser.Split("\")[-1]    

# Remove local cached user account if it exists

$localUser = Get-LocalUser -Name $profileName -ErrorAction SilentlyContinue
if ($localUser) {
    Write-Host "Removing local user account: $profileName"
    Remove-LocalUser -Name $profileName
} else {
    Write-Host "Local user account $profileName does not exist."
}   

# Remove user profile folder if it exists

$profilePath = "C:\Users\$profileName"
if (Test-Path -Path $profilePath) {
    Write-Host "Removing user profile folder: $profilePath"
    Remove-Item -Path $profilePath -Recurse -Force
    Write-Host "$profilePath folder removed"
} else {
    Write-Host "User profile folder $profilePath does not exist."
    Exit 1
}

Write-Host "Domain account for $domainUser has been removed from local machine."
}
catch {
    Write-Error "Failed to extract username from domain account: $_"
    exit 1
}