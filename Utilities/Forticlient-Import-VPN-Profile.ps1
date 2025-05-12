# Path to config file containing the IPSec VPN profile
$profilePath = "\\asti-usa.net\netlogon\duo_sso_import_3.conf"
# Path to Forticlient executable
$fortiClient = "C:\Program Files\Fortinet\FortiClient\FCConfig.exe"

# Import VPN profile
& $fortiClient -m all -f $profilePath -o import -i 1
Write-Host "ASTi Forticlient IPSec VPN tunnel imported successfully!"