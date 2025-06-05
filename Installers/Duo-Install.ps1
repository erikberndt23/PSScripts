# Registry paths to check for Duo
$reg = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

# Check if Duo is already installed before proceeding
$agentRegPath = Get-ChildItem -Path $reg | Get-ItemProperty | Where-Object { $_.DisplayName -like "Duo Authentication*" }

if ($agentRegPath) {
    Write-Output "$($agentRegPath.DisplayName) is already installed. Exiting script."
    Exit 1
} else {
    Write-Host "Duo Authentication for Windows Logon not detected. Proceeding with installation..."
}

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
        Exit 1
    }
}

# Duo agent installer path and destination
$installerLocation = "\\asti-usa.net\netlogon\duo\DuoWindowsLogon64.msi"
$msiPath = "$env:temp\DuoWindowsLogon64.msi"

# Download Duo installer
Write-Output "Downloading Duo installer..."
try {
    (New-Object System.Net.WebClient).DownloadFile($installerLocation, $msiPath)
} catch {
    throw "Failed to download Duo installer: $_"
}

# Install Duo silently
$duoArguments = @(
"/i", "`"$msiPath`"",
"/qn",
"/norestart",
"AUTOPUSH=#0",
"FAILOPEN=#1"
)

Write-Output "Installing Duo for Windows..."
Start-Process -FilePath msiexec.exe -ArgumentList $duoArguments -Wait -NoNewWindow

# Cleanup
if (Test-Path $msiPath) { Remove-Item $msiPath -Force }
if (Test-Path $installerPath) { Remove-Item $installerPath -Force }
