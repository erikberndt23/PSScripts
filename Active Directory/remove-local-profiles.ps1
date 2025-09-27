# Remove local profiles
# Run as Administrator
# Find User folder matched with their Registry SID <= use if folder is present in the files system

Get-WMIObject -class Win32_UserProfile | Format-List LocalPath, SID

# SID(S) to be removed

$SIDS = @(
    "<SID to Remove>",
    "<SID to Remove>"
    # Add more SIDs as needed
)
foreach ($SID in $SIDS) {
    
 $userProfile = Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.SID -eq $SID }

    if ($userProfile) {
        if (-not $userProfile.Loaded) {
            Write-Host "Removing profile for SID: $SID (Path: $($userProfile.LocalPath))"
            $userProfile | Remove-WmiObject
        } else {
            Write-Warning "Profile for SID $SID is currently loaded and cannot be removed."
        }
    } else {
        Write-Warning "No profile found for SID: $SID"
    }
}