# Get list of Xbox apps that can be removed
$xboxApps = @(
    "Microsoft.GamingApp",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay"
)

# Remove detected apps
try {
    $provisionedAppxPackages = Get-ProvisionedAppPackage -Online

    foreach ($displayName in $xboxApps) {
        $packageToRemove = $provisionedAppxPackages | Where-Object { $_.DisplayName -eq $displayName }
        
        if ($packageToRemove) {
            Write-Host "Removing $($packageToRemove.DisplayName)..."
            Remove-ProvisionedAppPackage -Online -AllUsers -PackageName $packageToRemove.PackageName
            Write-Host "Removed $($packageToRemove.DisplayName) successfully."
        } else {
            Write-Host "Package '$displayName' not found. Skipping removal."
        }
    }
} catch {
    Write-Host "An error occurred: $($_.Exception.Message)"
}