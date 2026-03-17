$protocols = @('SSL 2.0', 'SSL 3.0')
$sides = @('Server', 'Client')
$base = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols'

foreach ($proto in $protocols) {
    foreach ($side in $sides) {
        $path = "$base\$proto\$side"
        New-Item -Path $path -Force | Out-Null
        New-ItemProperty -Path $path -Name 'Enabled' -Value 0 -PropertyType DWord -Force
        New-ItemProperty -Path $path -Name 'DisabledByDefault' -Value 1 -PropertyType DWord -Force
        Write-Host "Disabled $proto ($side)"
    }
}