# SentinelOne VSS Cleanup Script
# This script is designed to clean up the VSS (Volume Shadow Copy Service) storage used by SentinelOne on Windows systems. 
# It disables the SentinelOne VSS protection, resizes the shadow storage, and then re-enables the protection.

param(
    [string]$Passphrase = "RETRIEVE MACHINE PASSPHRASE FROM SENTINELONE CONSOLE",
    [string]$MaxSize = "10GB"
)

$ErrorActionPreference = "Stop"
$log = "C:\PDQ\SentinelOne-VSS-Log.txt"
Start-Transcript -Path $log -Append

Set-Location "c:\program files\sentinelone\sentinel agent 25.2.6.442\"

$unloaded = $false

try {
    Write-Host "Unprotecting agent" -ForegroundColor Cyan
    .\sentinelctl.exe unprotect -k $Passphrase
    if ($LASTEXITCODE -ne 0) { throw "unprotect failed with exit code $LASTEXITCODE" }

    Write-Host "Unloading agent" -ForegroundColor Cyan
    .\sentinelctl.exe unload -slam -k $Passphrase
    if ($LASTEXITCODE -ne 0) { throw "unload failed with exit code $LASTEXITCODE" }
    $unloaded = $true

    Write-Host "Disabling VSS protection" -ForegroundColor Cyan
    .\sentinelctl.exe config -p vssConfig.vssProtection -v false

    Write-Host "Resizing shadow storage" -ForegroundColor Cyan
    vssadmin Resize ShadowStorage /For=C: /On=C: /MaxSize=$MaxSize

    Write-Host "Verifying reclaimable space" -ForegroundColor Cyan
    @"
select disk 0
select partition 3
shrink querymax
"@ | diskpart | Out-String | Write-Host
}
catch {
    Write-Host "ERROR during VSS resize: $_" -ForegroundColor Red
}
finally {
    Write-Host "Re-enabling VSS protection" -ForegroundColor Cyan
    .\sentinelctl.exe config -p vssConfig.vssProtection -v true

    if ($unloaded) {
        Write-Host "Reloading agent" -ForegroundColor Cyan
        .\sentinelctl.exe load -slam
    }

    Write-Host "Reprotecting agent" -ForegroundColor Cyan
    .\sentinelctl.exe protect -k $Passphrase

    Write-Host "Final state check" -ForegroundColor Cyan
    Get-Service -Name "Sentinel*" | Select-Object Name, Status
}

Stop-Transcript