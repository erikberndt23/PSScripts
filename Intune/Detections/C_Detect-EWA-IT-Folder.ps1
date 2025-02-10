# Detect path to EWA-IT folder
$folderPath = "C:\EWA-IT"
$errMsg = $_.ExceptionMessage

If (Test-Path $folderPath)
{
Write-Output "Not Compliant - EWA-IT Folder Exists - Remediation Required"
Exit 1
}
else {
    Write-Output "Not Compliant - EWA-IT Folder not Located - No Remediation Required"
    Write-Host $errMsg
    exit 0
}