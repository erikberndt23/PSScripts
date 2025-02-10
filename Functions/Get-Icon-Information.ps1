# Ex. "GetIcon 'C:\EWA-IT\Migration\ EWA Migration Checks - Run Me. lnk'"

function Get-ShortcutIcon {
    $private:Path = $args[0]

    $ws = New-Object -ComObject WScript.Shell
    $sc = $ws.CreateShortcut($Path)

    $scInd = 0                              # Default to 0
    $scLoc = $sc.IconLocation               # C:\Windows\System32\shell32.dll,164
    $scTar = $sc.TargetPath                 # "C:\Windows\System32\control.exe"
    $scArg = $sc.Arguments                  # "ncpa.cpl"

    if ($scLoc -match '^(.+),(\d+)') {
        # C:\Windows\System32\shell32.dll,164
        $scLoc  = [string]$matches[1]       # C:\Windows\System32\shell32.dll
        $scInd  = [int]$matches[2]          # 164
    }

    $Tar    = "  {0,-20} : " -f "Shortcut Target"           # $scTar
    $Arg    = "  {0,-20} : " -f "Shortcut Arguments"        # $scArg
    $Loc    = "  {0,-20} : " -f "Icon Location"             # $scLoc
    $Ind    = "  {0,-20} : " -f "Icon Location Index"       # $scInd

    Write-Host -f Yellow "`nFile Icon info:`n"
    Write-Host -f DarkGray "$Tar" -Non;     Write-Host -f White "$scTar"    # 
    Write-Host -f DarkGray "$Arg" -Non;     Write-Host -f Gray "$scArg" # 
    Write-Host -f DarkGray "$Loc" -Non;     Write-Host -f DarkYellow "$scLoc"   # 
    Write-Host -f DarkGray "$Ind" -Non;     Write-Host -f DarkYellow "$scInd"   # 
    
    # Clean up
    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($sc)
    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($ws)
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    Write-Host
}

Set-Alias -Name GetIcon -Value Get-ShortcutIcon -Description 'lnk icon' -Scope Local -Option ReadOnly, Private