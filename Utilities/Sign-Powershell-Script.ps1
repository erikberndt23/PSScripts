# Certificate path. Should be added to local machine cert store prior to running this script.
$cert = Get-ChildItem -Path Cert:\LocalMachine\My -CodeSigningCert
# Sign script with certificate
Set-AuthenticodeSignature -FilePath "C:\Path\To\script.ps1" -Certificate $cert
# Get certificate status after signing script
Get-AuthenticodeSignature -FilePath "C:\Path\To\script.ps1"