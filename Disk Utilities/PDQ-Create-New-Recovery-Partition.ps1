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

function Invoke-DiskpartStep {
    param(
        [string]$Description,
        [string]$Script,
        [string]$SuccessPattern
    )
    Write-Host "`n>> diskpart step: $Description"
    $output = $Script | diskpart | Out-String
    Write-Host $output
    if ($output -notmatch $SuccessPattern) {
        throw "Diskpart step '$Description' did not confirm success (expected pattern: $SuccessPattern). Aborting. Output: $output"
    }
    return $output
}

try {
    if (!(Test-Path $WinreSource)) { throw "Winre.wim not found at $WinreSource." }

    Write-Host "Pre-flight: checking free space on OS partition"
    $osVolume = Get-Partition -DiskNumber $DiskNumber -PartitionNumber $OsPartitionNumber | Get-Volume
    $freeMB = [math]::Round($osVolume.SizeRemaining / 1MB, 0)
    $requiredMB = $ShrinkSizeMB + 500  # buffer for filesystem overhead / shrink minimum
    Write-Host "Free space: $freeMB MB. Required (shrink size + 500MB buffer): $requiredMB MB."
    if ($freeMB -lt $requiredMB) {
        throw "Insufficient free space to safely shrink. Free: $freeMB MB, Required: $requiredMB MB. Aborting before touching disk."
    }

    Write-Host "Baseline WinRE status"
    $infoOutput = reagentc /info 2>&1 | Out-String
    Write-Host $infoOutput
    if ($infoOutput -match "Enabled") {
        try { Invoke-Reagentc "/disable" } catch { Write-Host "Note: $_" }
    }

    Write-Host "Diskpart: shrink OS partition"
    Invoke-DiskpartStep -Description "Shrink" -SuccessPattern "successfully shrunk the volume" -Script @"
select disk $DiskNumber
select partition $OsPartitionNumber
shrink desired=$ShrinkSizeMB
"@

    Write-Host "Diskpart: create new partition"
    Invoke-DiskpartStep -Description "Create partition" -SuccessPattern "succeeded in creating the specified partition" -Script @"
select disk $DiskNumber
create partition primary
"@

    Write-Host "Locating the new partition (highest partition number)"
    Start-Sleep -Seconds 2
    $newPartNum = (Get-Partition -DiskNumber $DiskNumber | Sort-Object PartitionNumber -Descending | Select-Object -First 1).PartitionNumber
    if ($newPartNum -eq $OsPartitionNumber -or -not $newPartNum) {
        throw "Could not confirm a new partition number distinct from the OS partition. Aborting."
    }
    Write-Host "New partition number: $newPartNum"

    Write-Host "Diskpart: set GPT attributes on NEW partition only"
    Invoke-DiskpartStep -Description "Set attributes" -SuccessPattern "successfully assigned the attributes" -Script @"
select disk $DiskNumber
select partition $newPartNum
gpt attributes=0x8000000000000001
"@

    Write-Host "Diskpart: set partition type ID"
    Invoke-DiskpartStep -Description "Set ID" -SuccessPattern "successfully set the partition ID" -Script @"
select disk $DiskNumber
select partition $newPartNum
set id=de94bba4-06d1-4d40-a16a-bfd50179d6ac
"@

    Write-Host "Diskpart: format"
    Invoke-DiskpartStep -Description "Format" -SuccessPattern "successfully formatted the volume" -Script @"
select disk $DiskNumber
select partition $newPartNum
format quick fs=ntfs label="Recovery"
"@

    Write-Host "Diskpart: assign drive letter"
    Invoke-DiskpartStep -Description "Assign letter" -SuccessPattern "successfully assigned the drive letter" -Script @"
select disk $DiskNumber
select partition $newPartNum
assign letter=R
"@

    Write-Host "Verify final partition state"
    $verifyOutput = @"
select disk $DiskNumber
select partition $newPartNum
detail partition
"@ | diskpart | Out-String
    Write-Host $verifyOutput
    if ($verifyOutput -notmatch "Required\s*:\s*Yes") {
        throw "Final verification failed: Required attribute not confirmed on partition $newPartNum."
    }

    Write-Host "Copying Winre.wim ==="
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
    }

    Write-Host "Enabling WinRE"
    Invoke-Reagentc "/enable"

    Write-Host "Final status"
    $finalInfo = reagentc /info 2>&1 | Out-String
    Write-Host $finalInfo

    Write-Host "Removing drive letter"
    @"
select disk $DiskNumber
select volume R
remove letter=R
"@ | diskpart | Out-String | Write-Host

    if ($finalInfo -match "Windows RE status:\s*Enabled") {
        Write-Host "SUCCESS: WinRE is Enabled."
    } else {
        Write-Host "WARNING: WinRE is still showing Disabled."
    }
}
catch {
    Write-Host "ERROR: $_"
    Stop-Transcript
    exit 1
}

Stop-Transcript
exit 0