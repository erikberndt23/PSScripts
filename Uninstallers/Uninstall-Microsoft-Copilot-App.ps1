# Parameters
$AppName     = "Microsoft Copilot"
$BaseDir     = "C:\Program Files (x86)\Microsoft\Copilot\Application"
$ExeName     = "copilot_setup.exe"
$UninstallArgs = "--uninstall --mscopilot --channel=stable --system-level --verbose-logging"

# Find installer path
$installer = Get-ChildItem -Path $BaseDir -Recurse -Filter $ExeName -ErrorAction SilentlyContinue |
             Where-Object { $_.FullName -like "*\Installer\$ExeName" } |
             Select-Object -First 1

if (-not $installer) {
    Write-Output "[$AppName] Installer not found under '$BaseDir'. Copilot may already be uninstalled."
    Exit 0
}

Write-Output "[$AppName] Found installer: $($installer.FullName)"
Write-Output "[$AppName] Running uninstall..."

# Uninstall
try {
    $process = Start-Process -FilePath $installer.FullName -ArgumentList $UninstallArgs -Wait -PassThru -NoNewWindow -ErrorAction Stop

    $exitCode = $process.ExitCode
    Write-Output "[$AppName] Process exited with code: $exitCode"

    if ($exitCode -eq 0 -or $exitCode -eq 19) {
        Write-Output "[$AppName] Uninstall completed successfully."
        Exit 0
    } else {
        Write-Error "[$AppName] Uninstall returned unexpected exit code: $exitCode"
        Exit $exitCode
    }
}
catch {
    Write-Error "[$AppName] Failed to launch installer: $_"
    Exit 1
}