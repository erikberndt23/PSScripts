$appList = @(
    "Clipchamp.Clipchamp",
    "Microsoft.BingNews",
    "Microsoft.BingWeather",
    "Microsoft.GamingApp",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MixedReality.Portal",
    "Microsoft.Office.OneNote",
    "Microsoft.People",
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.Print3D",
    "Microsoft.SkypeApp",
    "Microsoft.Wallet",
    "microsoft.windowscommunicationsapps",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.QuickAssist",
    "Microsoft.Family"
)

try {
    $provisionedAppxPackages = Get-ProvisionedAppPackage -Online

    foreach ($displayName in $appList) {
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