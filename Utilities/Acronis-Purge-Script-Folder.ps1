$acronisScripts = "C:\ProgramData\Acronis\TrueImageHome\Scripts"
$testPath = test-path -Path $acronisScripts

# Check if Acronis scripts folder exists
if ($testPath -eq $true) {
    Write-Host "Acronis directory exists!"
}
Else {
    Write-Host "Acronis directory does not exist - exiting script!"
    Exit 1
}

# Check if Acronis script folder is populated
if((Get-ChildItem -Path $acronisScripts | Select-Object -First 1 | Measure-Object).Count -eq 0)
{
   Write-Host "Acronis scripts folder is empty - exiting script!"
   Exit 1
}
else {
    get-childitem $acronisScripts | Remove-Item
    Write-Host "Purging Acronis scripts folder!"
}