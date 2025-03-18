$source = "\\PATH\TO\LARGE\FILE"
$destination = "\PATH\TO\DESTINATION\FILE"
$startTime = Get-Date
Copy-Item $source $destination -Force
$endTime = Get-Date
$timeTaken = New-TimeSpan -Start $startTime -End $endTime
$fileSizeMB = (Get-Item $destination).Length / 1MB
$speedMBps = $fileSizeMB / $timeTaken.TotalSeconds
$speedMbps = $speedMBps * 8
Write-Host "Speed: $($speedMbps) Mbps"