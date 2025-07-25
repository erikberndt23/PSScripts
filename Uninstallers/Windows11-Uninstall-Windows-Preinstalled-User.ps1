$appList = @(
    "Clipchamp.Clipchamp",
    "Microsoft.BingNews",
    "Microsoft.BingWeather",
    "Microsoft.BingSearch",
    "Windows.DevHome",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.GamingApp",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MixedReality.Portal",
    "Microsoft.Office.OneNote",
    "Microsoft.OutlookForWindows",
    "Microsoft.People",
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.Print3D",
    "Microsoft.SkypeApp",
    "Microsoft.Wallet",
    "Microsoft.windowscommunicationsapps",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.YourPhone",,
    "Microsoft.Whiteboard",
    "Microsoft.MicrosoftJournal",
    "MicrosoftCorporationII.QuickAssist",
    "Microsoft.ToDos",
    "MicrosoftCorporationII.MicrosoftFamily"
)

try {
    $AppxPackages = Get-AppxPackage -AllUsers

    foreach ($displayName in $appList) {
        $packageToRemove = $AppxPackages | Where-Object { $_.DisplayName -eq $displayName }
        
        if ($packageToRemove) {
            Write-Host "Removing $($packageToRemove.DisplayName)..."
            Remove-AppxPackage -AllUsers -PackageName $packageToRemove.PackageName
            Write-Host "Removed $($packageToRemove.DisplayName) successfully."
        } else {
            Write-Host "Package '$displayName' not found. Skipping removal."
        }
    }
} catch {
    Write-Host "An error occurred: $($_.Exception.Message)"
}