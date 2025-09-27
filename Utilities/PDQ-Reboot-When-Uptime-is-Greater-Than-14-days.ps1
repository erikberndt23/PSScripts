# Add Windows Presentation Framework
Add-Type -AssemblyName PresentationFramework

# Calculate UpTime in Days
$WMI = Get-WmiObject win32_operatingsystem
$upTime = (Get-Date) - ($WMI.ConvertToDateTime($WMI.LastBootUpTime))
$upTimeDays = $Uptime.Days

if ($uptimeDays -gt "14") {
$output = "$upTimeDays Days" }
else {
Write-Output "Uptime condition not met"
Exit 1
}

# Message Box Options 
$title = "Windows Restart Manager"
$body = "Your computer hasn't been rebooted in $Output. Please save all current progress and restart your machine."
$icon = "Warning"
$button = "OK"

# Show Message Box
[System.Windows.MessageBox]::Show("$Body","$Title","$Button","$Icon")