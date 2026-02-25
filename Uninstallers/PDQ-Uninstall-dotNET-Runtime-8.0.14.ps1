# Detect Microsoft .NET Runtime 8.0.14 (x64)

$dotNet = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue | Where-Object {
        $_.DisplayName -like "Microsoft .NET Runtime*" -and
        $_.DisplayName -like "*8.0.14*"
    }

$dotNet | ForEach-Object {
    $uninstall = $_.QuietUninstallString
    if ($uninstall -match '^(\".+?\"|\S+)(.*)$') {
        $exe = $matches[1].Trim('"')
        $arguments = $matches[2].Trim()

        if (Test-Path $exe) {
            Write-Output "Uninstalling $($_.DisplayName) using $exe $arguments"
            Start-Process -FilePath $exe -ArgumentList $arguments -Wait -NoNewWindow
            Write-Output "Removed $($_.DisplayName)"
            Exit 0
        } else {
            Write-Warning "Uninstall executable not found: $exe"
            Exit 1
        }
    } else {
        Write-Warning "Cannot parse uninstall string: $uninstall"
        Exit 1
    }
}