# Get the installed .NET Framework 4.x version from the registry
$netRegPath = 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'

if (Test-Path $netRegPath) {
    $release = (Get-ItemProperty -Path $netRegPath -Name Release -ErrorAction SilentlyContinue).Release
    if ($release) {
        # Map the release number to a human-readable version
        $version = switch ($release) {
            {$_ -ge 533320} { "4.8.1" ; break }
            {$_ -ge 528040} { "4.8" ; break }
            {$_ -ge 461808} { "4.7.2" ; break }
            {$_ -ge 461308} { "4.7.1" ; break }
            {$_ -ge 460798} { "4.7" ; break }
            {$_ -ge 394802} { "4.6.2" ; break }
            {$_ -ge 394254} { "4.6.1" ; break }
            {$_ -ge 393295} { "4.6" ; break }
            {$_ -ge 379893} { "4.5.2" ; break }
            {$_ -ge 378675} { "4.5.1" ; break }
            {$_ -ge 378389} { "4.5" ; break }
            default { "Unknown ($release)" }
        }

        [PSCustomObject]@{
            'NET_Framework_Release' = $release
            'NET_Framework_Version' = $version
        }
    }
    else {
        [PSCustomObject]@{
            'NET_Framework_Release' = 'Not Found'
            'NET_Framework_Version' = 'Not Found'
        }
    }
}
else {
    [PSCustomObject]@{
        'NET_Framework_Release' = 'Not Installed'
        'NET_Framework_Version' = 'Not Installed'
    }
}
