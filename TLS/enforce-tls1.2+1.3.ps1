$goodProtocols = @('TLS 1.2', 'TLS 1.3')
$sides = @('Server', 'Client')
$base = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols'

foreach ($proto in $goodProtocols) {
    foreach ($side in $sides) {
        $path = "$base\$proto\$side"
        New-Item -Path $path -Force | Out-Null
        New-ItemProperty -Path $path -Name 'Enabled' -Value 1 -PropertyType DWord -Force
        New-ItemProperty -Path $path -Name 'DisabledByDefault' -Value 0 -PropertyType DWord -Force
        Write-Host "Enabled $proto ($side)"
    }
}