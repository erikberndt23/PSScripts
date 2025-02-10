# Path to EWA-IT Folder
$folderPath = "C:\EWA-IT"
$errMsg = $_.ExceptionMessage

If (Test-Path $folderPath)
{
Write-Output "Not Compliant - Removing EWA-IT Folder"
Remove-Item $folderpath -Recurse
Write-Out "Removed EWA-IT Folder"
Exit 0
}
else 
{
    Write-Host $errMsg
    exit 1
}