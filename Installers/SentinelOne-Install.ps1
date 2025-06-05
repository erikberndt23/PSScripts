$siteToken = "***************************************************************************************"
$sourceFile = "\\asti-usa.net\NETLOGON\SentinelOne\SentinelOneInstaller_windows_64bit_v24_2_3_471.exe"
$destinationFile = "$env:temp\SentinelOneInstaller_windows_64bit_v24_2_3_471.exe"

# Check if SentinelOne is already installed
if ($siteToken) {
        Write-Output "SentinelOneAgent is configured for this client, proceeding with app validation"
        if (Test-Path "C:\Program Files\SentinelOne\Sentinel Agent *\SentinelAgent.exe") {
        Write-Output "SentinelOne is currently installed. No further configuration needed."
} 

# Silently install SentinelOne if not detected
else {
    Write-Output "SentinelOne is not installed. Proceeding with download and installation"
    (New-Object System.Net.WebClient).DownloadFile($sourceFile,$destinationFile)
    Write-Output "SentinelOne agent downloaded, proceeding with installation..."
    & $destinationFile -t $siteToken --qn
}
}
else {
    Write-Output "SentinelOne installation failed "
}