# Set the username and password for locla admin account. Password will be overwritten by LAPS upon domain connectivity. 
$lcadminUsername = "lcadmin"
$lcadminPassword = ConvertTo-SecureString "***********************" -AsPlainText -Force

# Check if lcadmin account already exists
$lcadmin = Get-LocalUser -Name $lcadminUsername -ErrorAction SilentlyContinue
if ($lcadmin) {
    Write-Output "User account '$lcadminUsername' already exists."
} else {
    try {
        # Create the lcadmin account if it doesn't already exist
        New-LocalUser -Name $lcadminUsername -Password $lcadminPassword -FullName "ASTi Local Admin" -Description "ASTi Local administrative account" -PasswordNeverExpires -AccountNeverExpires
        Add-LocalGroupMember -Group "Administrators" -Member $lcadminUsername
        Write-Output "User account '$lcadminUsername' has been created and added to the Administrators group."
    } catch {
        Write-Error "Failed to create user account '$lcadminUsername': $_"
    }
}

# Remove the astiadmin account if it still exists
$astiadmin = Get-LocalUser -Name "astiadmin" -ErrorAction SilentlyContinue
if ($astiadmin) {
    try {
        Remove-LocalUser -Name "astiadmin"
        Write-Output "User account 'astiadmin' has been removed."
    } catch {
        Write-Error "Failed to remove user account 'astiadmin': $_"
    }
} else {
    Write-Output "User account 'astiadmin' does not exist."
}