# Software to be uninstalled

$software = "qBackup"

# Registry paths to search for software

$registryPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

# Email server configuration

$smtpServer = "aspmx.l.google.com"
$mailFrom = "noreply@asti.usa.com"
$mailTo = "itdept@asti-usa.com"
$hostName = $env:COMPUTERNAME
$subject = "Successfully Uninstalled $software on $hostname"
$messageBody = ""

# Uninstall checks

$found = $false
$uninstalled = $false

# Scan and uninstall software

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

                # Uninstall software

                try {
                    Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallString" -NoNewWindow -Wait
                    $uninstalled = $true
                    $messageBody += "Status: $software uninstalled successfuly on $hostName.`n`n"
                } catch { 
                    $messageBody += "Status: $software uninstall FAILED on $hostName. $_`n`n"
                }
            }
        }
    }
}

# Exit script silently if not found

if (-not $found) {
    Exit 0
}

# Send email message if software located and uninstalled/failed

Send-MailMessage -From $mailFrom -To $mailTo -Subject $subject -Body $messageBody -SmtpServer $smtpServer