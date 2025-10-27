$KBID = "KB5070773"
$TargetBuild = "26100"
$MSUFileName = "Windows11.0-KB5070773-x64.msu"
$DownloadUrl = "https://catalog.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/5f9be7a2-56e4-4051-b992-2e2bb7d32db9/public/windows11.0-kb5070773-x64_b235da912270f84b761402e9511000a4f500b4ac.msu"
$DownloadFolder = "C:\Temp\Updates\$KBID"
$FullPath = Join-Path -Path $DownloadFolder -ChildPath $MSUFileName

# 1. Check OS build
$os = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
$build = [int]$os.CurrentBuild
Write-Host "Detected build: $build"

if ($build -lt $TargetBuild) {
    Write-Host "Build is below $TargetBuild.691? Update may not be applicable. Exiting."
    exit 1
}

# 2. Create download folder if not exists
if (!(Test-Path $DownloadFolder)) {
    New-Item -Path $DownloadFolder -ItemType Directory | Out-Null
}

# 3. Download the MSU if not present
if (!(Test-Path $FullPath)) {
    Write-Host "Downloading $KBID"
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $FullPath -UseBasicParsing
    if (!(Test-Path $FullPath)) {
        Write-Host "Download failed. Exiting."
        exit 1
    }
}

# 4. Install the MSU via DISM
Write-Host "Installing update $KBID"
dism.exe /Online /Add-Package /PackagePath:$FullPath /Quiet /NoRestart

# Check exit code
if ($LASTEXITCODE -eq 0) {
    Write-Host "Installation succeeded for $KBID"
    # Optionally reboot
    # Restart-Computer -Force
} else {
    Write-Host "Installation failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}