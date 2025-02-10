# Download MSI Installer from BeyondTrust
invoke-webrequest -URI 'https://sigmadefense.beyondtrustgov.com/download_client_connector?fn=sra-pin-win_x64-j130w8x765yw7gwy8g5f86zd7ziyhx5e8wizc90.msi&jc=f2e5bcdf54fd24c62ba95a1d3ec82f1a&p=winNT-64-msi&ss=2c25ca1d713b3e609090052cc43fd84856aa3468' -OutFile "c:\sra-pin-win_x64-j130w8x765yw7gwy8g5f86zd7ziyhx5e8wizc90.msi"

# Install MSI
$DataStamp = get-date -Format yyyyMMddTHHmmss
$logFile = '{0}-{1}.log' -f $file.fullname,$DataStamp
$Arguments = @(
    "/i" , "c:\sra-pin-win_x64-j130w8x765yw7gwy8g5f86zd7ziyhx5e8wizc90.msi"
    ('"{0}"' -f $file.fullname)
    "/qn"
    "/norestart"
    "/L*v"
    "INSTALLDIR='C:\ProgramData\BeyondTrust-24.2.2'"
    $logFile
)
Start-Process "msiexec.exe" -ArgumentList $Arguments -Wait -NoNewWindow 
#Start-Process msiexec.exe -Wait -ArgumentList '/I c:\sra-pin-win_x64-j130w8x765yw7gwy8g5f86zd7ziyhx5e8wizc90.msi INSTALLDIR="C:\ProgramData\BeyondTrust-24.2.2" /qn /norestart'