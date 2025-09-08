$teamsApps = @()

# Look through each user profile on the system and exclude lcadmin user account
$profiles = Get-ChildItem 'C:\Users' -Directory | Where-Object { $_.FullName -notlike "*lcadmin*" -and (Test-Path "$($_.FullName)\AppData\Local\Packages")}

foreach ($profile in $profiles) {
    $packagePath = Join-Path $profile.FullName "AppData\Local\Packages"
    $teams = Get-ChildItem $packagePath -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*Teams*" }

    foreach ($t in $teams) {
        $teamsApps += "User: $($profile.Name) | Package: $($t.Name)"
    }
}

if ($teamsApps) {
    $teamsApps
}
else {
    "Name: $null | Version: $null"
}

if ($teamsApps) {
    $teamsApps
}
else {
    "Name: $null | Version: $null"
}
