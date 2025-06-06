# Download MSI Installer
invoke-webrequest -URI 'https://www.url.com' -OutFile "c:\file.msi"

# Install MSI
$DataStamp = get-date -Format yyyyMMddTHHmmss
$logFile = '{0}-{1}.log' -f $file.fullname,$DataStamp
$Arguments = @(
    "/i" , "c:\file.msi"
    ('"{0}"' -f $file.fullname)
    "/qn"
    "/norestart"
    "/L*v"
    "INSTALLDIR='C:\ProgramData\BeyondTrust-24.2.2'"
    $logFile
)
Start-Process "msiexec.exe" -ArgumentList $Arguments -Wait -NoNewWindow 