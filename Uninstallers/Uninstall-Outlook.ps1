# Detect whether Windows Store Outlook is installed
$outlookPackages = Get-AppxPackage -AllUsers | Where-Object {$_.Name -like '*OutlookforWindows*'}

if ($outlookPackages) {
    Write-Output "Not Compliant - Outlook Installed - Remediation Required"
    try {
        foreach ($pkg in $outlookPackages) {
            Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction SilentlyContinue
        }
        Write-Host "Remediation Complete - Outlook successfully removed!"
    }
    catch {
        Write-Host "Remediation Failed - Error removing Outlook!"
        Write-Host $_.Exception.Message
    }
}
else {
    Write-Output "Compliant - Outlook not Installed - No Remediation Required"
    Exit 0
}