# Install location
$installPath = $env:SystemDrive + "\WinAeroTweaker"

# Kill any running instances of WinAeroTweaker
$processName = "WinAeroTweaker"

$runningProcesses = Get-Process -Name $processName -ErrorAction SilentlyContinue
if ($runningProcesses) {
    foreach ($proc in $runningProcesses) {
        try {
            Write-Host "Stopping process $($proc.Name) with ID $($proc.Id)..."
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
            Write-Host "Successfully stopped process $($proc.Name) with ID $($proc.Id)!"
        }
        catch {
            Write-Host "Failed to stop process $($proc.Name) with ID $($proc.Id)"
            Exit 0
        }
    }
} else {
    Write-Host "No running instances of $processName found."
}

# Remove install location if it exists
if (Test-Path -Path $installPath) {
    try { 
    Write-Host "Removing WinAeroTweaker directory..."
    Remove-Item -Path $installPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Successfully removed WinAeroTweaker directory!"
    }
    catch {
        Write-Host "Failed to remove $installPath"
        Exit 0
    }
    }
    else {
        Write-Host "$installPath directory not found!"
        Exit 0
    }

# Remove AppData config files
# Parse all user profiles for WinAeroTweaker AppData directory

$usersRoot = $env:SystemDrive + "\Users"
$users = Get-ChildItem -Path $usersRoot -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -notin @("Public", "Default", "Default User", "All Users") }

foreach ($user in $users) {
    $appDataPath = $user.FullName + "\AppData\Roaming\WinAeroTweaker"
    if (Test-Path -Path $appDataPath) {
        try {
        Write-Host "Removing WinAeroTweaker AppData directory for user $($user.Name)..."
        Remove-Item -Path $appDataPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Successfully removed WinAeroTweaker AppData directory for user $($user.Name)!"
        }
        catch {
            Write-Host "Failed to remove $appDataPath for user $($user.Name)"
        }
    }
    else {
        Write-Host "$appDataPath directory not found for user $($user.Name)!"
    }
}

# Remove any registry keys related to WinAeroTweaker
$registryPaths = @(
    "HKCU:\SOftware\Winaero",
    "HKCU:\Software\WinAeroTweaker",
    "HKLM:\Software\WinAeroTweaker",
    "HKLM:\Software\WinAero",
    "HKLM:\Software\Wow6432Node\WinAeroTweaker",
    "HKLM:\Software\Wow6432Node\WinAero"
)

foreach ($regKey in $registryPaths) {
    if (Test-Path -Path $regKey) {
        try {
        Write-Host "Removing registry key $regKey..."
        Remove-Item -Path $regKey -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Successfully removed registry key $regKey!"
        }
        catch {
            Write-Host "Failed to remove registry key $regKey"
        }
    }
    else {
        Write-Host "Registry key $regKey not found!"
    }
}
Write-Host "WinAero Tweaker uninstall process complete!"
