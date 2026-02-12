# Registry paths to check for Duo

$reg = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

# Minimum Duo version required for upgrade

$minimumDuoVersion = [version]"5.1.1.1102"

# Minimum Microsoft Visual C++ Redistributable x64 required version

$minimumVersion = [version]"14.40.33810"

# VC++ Redist download URL and local path

$installerURL = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$installerPath = "$env:temp\vc_redist.x64.exe"
$installerArgs = @(
"/quiet",
"/norestart"
)

# Registry paths to check for installed Visual C++ Redistributables

$vcPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

# Registry paths to check for Duo

$duoRegPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

# Minimum Duo for Windows Login required version

$minimumDuoVersion = [version]"5.1.1.1102"

# Parse version string into [version]
function Convert-ToVersion {
    param($verString)
    try {
        return [version]$verString
    } catch {
        return $null
    }
}

# Detect installed Duo version

$installedDuoVersion = $null
foreach ($path in $duoRegPaths) {
    $apps = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -match "Duo Authentication for Windows Logon" }

    foreach ($app in $apps) {
        if ($app.DisplayVersion) {
            $parsed = Convert-ToVersion $app.DisplayVersion
            if ($parsed) {
                $installedDuoVersion = $parsed
                break
            }
        }
    }

    if ($installedDuoVersion) { break }
}

if ($installedDuoVersion) {
    Write-Host "Found installed Duo version: $installedDuoVersion"
    if ($installedDuoVersion -ge $minimumDuoVersion) {
        Write-Host "Installed Duo version meets requirement (>= $minimumDuoVersion). Skipping installation."
        exit 1
    } else {
        Write-Host "Installed Duo version $installedDuoVersion is lower than required $minimumDuoVersion. Proceeding with update..."
    }
} else {
    Write-Host "Duo for Windows Logon not found. Proceeding with installation..."
}

# Get all installed Visual C++ x64 Redistributables

$installedVC = foreach ($path in $vcPaths) {
    Get-ItemProperty -Path $path -ErrorAction SilentlyContinue |
    Where-Object {
        $_.DisplayName -like "Microsoft Visual C++ *x64*" -and $_.DisplayVersion
    } |
    ForEach-Object {
        try {
            [version]$_.DisplayVersion
        } catch {
            $null
        }
    }
}

# Check if minimum required version is met

$meetsRequirement = $false
foreach ($version in $installedVC) {
    if ($version -ge $minimumVersion) {
        $meetsRequirement = $true
        break
    }
}

# Install VC++ if needed

if ($meetsRequirement) {
    Write-Host "A suitable Microsoft Visual C++ x64 Redistributable version is already installed."
} else {
    Write-Host "No suitable Microsoft Visual C++ x64 Redistributable version found. Downloading and installing..."

    try {
        (New-Object System.Net.WebClient).DownloadFile($installerURL, $installerPath)
        Start-Process -FilePath $installerPath -ArgumentList $installerArgs -Wait
        Write-Host "VC++ Redistributable installed successfully."
    } catch {
        Write-Host "Failed to install VC++ Redistributable: $_"
        exit 1
    }
}

# Duo agent installer path and destination

$installerLocation = "https://dl.duosecurity.com/duo-win-login-latest.exe"
$exePath = "$env:temp\duo-win-login-latest.exe"

# Download Duo installer

Write-Output "Downloading Duo installer..."
try {
    (New-Object System.Net.WebClient).DownloadFile($installerLocation, $exePath)
} catch {
    throw "Failed to download Duo installer: $_"
}

# Install Duo silently with no auto-push and fail open parameters

$duoArguments = @(
"/S",
"/V",
"AUTOPUSH=#0",
"FAILOPEN=#1"
)

Write-Output "Installing Duo for Windows..."
Start-Process -FilePath $exePath -ArgumentList $duoArguments -Wait -NoNewWindow
Write-Output "Successfully installed/updated Duo for Windows!"
Exit 0
