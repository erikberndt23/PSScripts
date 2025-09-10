# Detect and disable Windows PowerShell 2.0

Write-Host "Checking if Windows PowerShell 2.0 is installed..."

# Get PowerShell 2.0 feature status
$feature = Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -ErrorAction SilentlyContinue

if ($null -eq $feature) {
    Write-Host "PowerShell 2.0 feature not found on this system."
}
else {
    Write-Host "PowerShell 2.0 state: $($feature.State)"

    if ($feature.State -eq "Enabled") {
        Write-Host "Disabling Windows PowerShell 2.0..."
        Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -NoRestart -ErrorAction SilentlyContinue
        Write-Host "PowerShell 2.0 has been disabled. A restart may be required."
    }
    elseif ($feature.State -eq "Disabled") {
        Write-Host "PowerShell 2.0 has already been disabled."
        Exit 1
    }
}