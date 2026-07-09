param(
    [int]$DiskNumber = 0,
    [int]$OsPartitionNumber = 3,
    [string]$WinreSource = "C:\PDQ\Winre.wim",
    [uint64]$ShrinkSizeMB = 1024
)

$ErrorActionPreference = "Stop"
$log = "C:\PDQ\WinRE-Fix-Log.txt"
Start-Transcript -Path $log -Append

function Invoke-Reagentc {
    param([string]$Arguments)
    Write-Host "`n>> reagentc $Arguments"
    $output = & reagentc $Arguments.Split(' ') 2>&1 | Out-String
    Write-Host $output
    Write-Host "Exit code: $LASTEXITCODE"
    if ($LASTEXITCODE -ne 0) {
        throw "reagentc $Arguments failed with exit code $LASTEXITCODE. Output: $output"
    }
    return $output
}

try {
    if (!(Test-Path $WinreSource)) { throw "Winre.wim not found at $WinreSource." }

    Write-Host "Baseline WinRE status"
    $infoOutput = reagentc /info 2>&1 | Out-String
    Write-Host $infoOutput
    if ($infoOutput -match "Enabled") {
        try { Invoke-Reagentc "/disable" } catch { Write-Host "Note: $_" }
    }

    Write-Host "Creating recovery partition via diskpart"
    $diskpartScript = @"
select disk $DiskNumber
select partition $OsPartitionNumber
shrink desired=$ShrinkSizeMB
create partition primary
gpt attributes=0x8000000000000001
set id=de94bba4-06d1-4d40-a16a-bfd50179d6ac
format quick fs=ntfs label="Recovery"
assign letter=R
detail partition
"@
    $diskpartOutput = $diskpartScript | diskpart | Out-String
    Write-Host $diskpartOutput

    if ($diskpartOutput -notmatch "Required\s*:\s*Yes") {
        throw "Diskpart did not confirm Required=Yes on the new partition."
    }

    Write-Host "Copying Winre.wim"
    New-Item -Path "R:\Recovery\WindowsRE" -ItemType Directory -Force | Out-Null
    Copy-Item -Path $WinreSource -Destination "R:\Recovery\WindowsRE\Winre.wim" -Force
    Get-ChildItem "R:\Recovery\WindowsRE\" | Select-Object Name, Length | Format-Table -AutoSize

    Write-Host "Setting recovery image path"
    Invoke-Reagentc "/setreimage /path R:\Recovery\WindowsRE"

    Write-Host "Resetting WinREStaged flag in ReAgent.xml"
    $xmlPath = "C:\Windows\System32\Recovery\ReAgent.xml"
    [xml]$reagentXml = Get-Content $xmlPath -Raw
    $stagedNode = $reagentXml.WindowsRE.WinREStaged
    Write-Host "Current WinREStaged state: $($stagedNode.state)"
    if ($stagedNode.state -ne "0") {
        $stagedNode.state = "0"
        $reagentXml.Save($xmlPath)
        Write-Host "WinREStaged forced to 0."
    } else {
        Write-Host "WinREStaged already 0 -- no change needed."
    }

    Write-Host "Enabling WinRE"
    Invoke-Reagentc "/enable"

    Write-Host "Final status"
    $finalInfo = reagentc /info 2>&1 | Out-String
    Write-Host $finalInfo

    Write-Host "Final ReAgent.xml"
    Get-Content $xmlPath -Raw | Write-Host

Write-Host "Removing drive letter from recovery partition"
    $removeLetterScript = @"
select disk $DiskNumber
select volume R
remove letter=R
"@
    $removeLetterOutput = $removeLetterScript | diskpart | Out-String
    Write-Host $removeLetterOutput

    if ($finalInfo -match "Windows RE status:\s*Enabled") {
        Write-Host "SUCCESS: WinRE is Enabled."
    } else {
        Write-Host "WARNING: still showing Disabled."
    }
}
catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    Stop-Transcript
    exit 1
}

Stop-Transcript
exit 0