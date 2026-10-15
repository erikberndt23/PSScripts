$sig = Get-AuthenticodeSignature "C:\Users\erikb\Downloads\MAPSetup_26.1.0.exe"
$cert = $sig.SignerCertificate

# Output CRL Distribution Points
$crlExt = $cert.Extensions | Where-Object { $_.Oid.Value -eq "2.5.29.31" }
Write-Host "=== CRL URLs ===" -ForegroundColor Yellow
$crlExt.Format($true)

# Output Authority Info Access (OCSP)
$aiaExt = $cert.Extensions | Where-Object { $_.Oid.Value -eq "1.3.6.1.5.5.7.1.1" }
Write-Host "`n=== AIA / OCSP URLs ===" -ForegroundColor Yellow
$aiaExt.Format($true)