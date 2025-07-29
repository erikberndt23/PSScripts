# Software to be uninstalled

$software = "qBackup"

# Registry paths to search

$registryPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

# Email configuration

$smtpServer = "aspmx.l.google.com"
$mailFrom = "noreply@asti.usa.com"
$mailTo = "erik.berndt@asti-usa.com"
$hostName = $env:COMPUTERNAME
$currentUser = $env:USERNAME
$subject = "Successfully Uninstalled $software on $hostname for $currentUser"
$messageBody = ""

# Uninstall checks

$found = $false
$uninstalled = $false

# Scan and uninstall

foreach ($regPath in $registryPaths) {
    Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue | ForEach-Object {
        $displayName = $_.GetValue("DisplayName")
        if ($displayName -like $software) {
            $found = $true
            $uninstallString = $_.GetValue("UninstallString")

            if ($uninstallString) {
                $messageBody += "Found: $displayName`n"
                $messageBody += "Uninstall String: $uninstallString`n"

                # Add silent uninstall flags
                if ($uninstallString -like "*msiexec*") {
                    $uninstallString += " /quiet /norestart"
                } else {
                    $uninstallString += " /SP- /verysilent"
                }

                # Attempt uninstall
                try {
                    Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallString" -NoNewWindow -Wait
                    $uninstalled = $true
                    $messageBody += "Status: $software uninstalled successfuly on $hostName for $currentUser.`n`n"
                } catch { 
                    $messageBody += "Status: $software uninstall FAILED on $hostName for $currentUser. $_`n`n"
                }
            }
        }
    }
}

# Exit script if not found

if (-not $found) {
    Exit 0
}

# Send email

Send-MailMessage -From $mailFrom -To $mailTo -Subject $subject -Body $messageBody -SmtpServer $smtpServer