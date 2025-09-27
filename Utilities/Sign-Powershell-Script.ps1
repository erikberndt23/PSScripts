# Certificate path. Should be added to the local machine cert store and configured as a code signing certificate prior to running this script.
$cert = Get-ChildItem -Path Cert:\LocalMachine\My -CodeSigningCert
# Sign script with certificate
Set-AuthenticodeSignature -FilePath "C:\Path\To\script.ps1" -Certificate $cert
# Get certificate info and signing status
Get-AuthenticodeSignature -FilePath "C:\Path\To\script.ps1"