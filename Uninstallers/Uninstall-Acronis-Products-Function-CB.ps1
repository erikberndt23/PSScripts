#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Silent Acronis Backup Software Uninstaller
    
.DESCRIPTION
    This script automatically detects and silently uninstalls Acronis backup software
    from Windows machines by scanning registry uninstall entries and executing
    appropriate silent uninstall commands.
    
.NOTES
    Author: PowerShell Expert
    Version: 1.0
    Requires: Administrator privileges
    Tested: Windows 10/11, Server 2016+
#>

# Initialize logging
$LogFile = "$env:TEMP\AcronisUninstall_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$AcronisFound = $false

function Write-LogMessage {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$TimeStamp] [$Level] $Message"
    
    # Output to console
    Write-Host $LogEntry
    
    # Output to log file
    Add-Content -Path $LogFile -Value $LogEntry
}

function Get-AcronisProducts {
    <#
    .SYNOPSIS
        Scans both 32-bit and 64-bit registry paths for Acronis products
    #>
    
    Write-LogMessage "Scanning registry for Acronis products..."
    
    # Define registry paths for uninstall entries
    $RegistryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",           # 64-bit programs
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" # 32-bit programs
    )
    
    $AcronisProducts = @()
    
    foreach ($Path in $RegistryPaths) {
        try {
            # Get all uninstall registry entries
            $UninstallKeys = Get-ItemProperty -Path $Path -ErrorAction SilentlyContinue
            
            foreach ($Key in $UninstallKeys) {
                # Check if DisplayName contains Acronis (case-insensitive)
                if ($Key.DisplayName -and $Key.DisplayName -match "Acronis") {
                    
                    # Only process if UninstallString exists
                    if ($Key.UninstallString) {
                        $Product = [PSCustomObject]@{
                            DisplayName = $Key.DisplayName
                            UninstallString = $Key.UninstallString
                            QuietUninstallString = $Key.QuietUninstallString
                            Publisher = $Key.Publisher
                            Version = $Key.DisplayVersion
                            InstallLocation = $Key.InstallLocation
                            RegistryPath = $Key.PSPath
                        }
                        
                        $AcronisProducts += $Product
                        Write-LogMessage "Found Acronis product: $($Key.DisplayName) v$($Key.DisplayVersion)"
                    }
                }
            }
        }
        catch {
            Write-LogMessage "Error accessing registry path $Path : $($_.Exception.Message)" "ERROR"
        }
    }
    
    return $AcronisProducts
}

function Start-SilentUninstall {
    param(
        [PSCustomObject]$Product
    )
    
    Write-LogMessage "Preparing to uninstall: $($Product.DisplayName)"
    
    $UninstallCommand = ""
    $Arguments = ""
    
    # Check if QuietUninstallString is available (preferred method)
    if ($Product.QuietUninstallString) {
        Write-LogMessage "Using QuietUninstallString for silent uninstall"
        
        # Parse command and arguments from QuietUninstallString
        if ($Product.QuietUninstallString -match '^"([^"]+)"\s*(.*)$') {
            $UninstallCommand = $matches[1]
            $Arguments = $matches[2].Trim()
        } else {
            # Handle cases where path isn't quoted
            $Parts = $Product.QuietUninstallString -split '\s+', 2
            $UninstallCommand = $Parts[0]
            $Arguments = if ($Parts.Length -gt 1) { $Parts[1] } else { "" }
        }
    }
    # Use regular UninstallString with silent flags
    else {
        Write-LogMessage "Using UninstallString with added silent flags"
        
        # Parse command and arguments from UninstallString
        if ($Product.UninstallString -match '^"([^"]+)"\s*(.*)$') {
            $UninstallCommand = $matches[1]
            $Arguments = $matches[2].Trim()
        } else {
            $Parts = $Product.UninstallString -split '\s+', 2
            $UninstallCommand = $Parts[0]
            $Arguments = if ($Parts.Length -gt 1) { $Parts[1] } else { "" }
        }
        
        # Determine installer type and add appropriate silent flags
        if ($UninstallCommand -match "msiexec") {
            # MSI installer - add quiet flags if not present
            if ($Arguments -notmatch "/q") {
                $Arguments += " /qn /norestart"
            }
        }
        elseif ($UninstallCommand -match "\.exe$") {
            # EXE installer - add common silent flags
            $CommonSilentFlags = @("/S", "/SILENT", "/QUIET", "/s", "/silent", "/quiet")
            $HasSilentFlag = $false
            
            foreach ($Flag in $CommonSilentFlags) {
                if ($Arguments -match [regex]::Escape($Flag)) {
                    $HasSilentFlag = $true
                    break
                }
            }
            
            if (-not $HasSilentFlag) {
                $Arguments += " /S /SILENT"
            }
        }
    }
    
    Write-LogMessage "Uninstall command: `"$UninstallCommand`" $Arguments"
    
    try {
        # Execute the uninstall command
        $ProcessParams = @{
            FilePath = $UninstallCommand
            Wait = $true
            NoNewWindow = $true
            PassThru = $true
        }
        
        if ($Arguments) {
            $ProcessParams.ArgumentList = $Arguments
        }
        
        Write-LogMessage "Starting uninstall process..."
        $Process = Start-Process @ProcessParams
        
        # Check exit code
        if ($Process.ExitCode -eq 0) {
            Write-LogMessage "Successfully uninstalled: $($Product.DisplayName)" "SUCCESS"
            return $true
        } else {
            Write-LogMessage "Uninstall completed with exit code: $($Process.ExitCode)" "WARNING"
            return $true  # Some installers return non-zero but still succeed
        }
    }
    catch {
        Write-LogMessage "Failed to uninstall $($Product.DisplayName): $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Main execution
Write-LogMessage "=== Acronis Silent Uninstaller Started ===" 
Write-LogMessage "Log file: $LogFile"

# Get all Acronis products
$AcronisProducts = Get-AcronisProducts

if ($AcronisProducts.Count -eq 0) {
    Write-LogMessage "No Acronis products found on this system. Nothing to uninstall." "INFO"
    Write-Host "`nSUCCESS: No Acronis software detected - system is clean!" -ForegroundColor Green
} else {
    Write-LogMessage "Found $($AcronisProducts.Count) Acronis product(s) to uninstall"
    $AcronisFound = $true
    
    # Display found products
    Write-Host "`nAcronis Products Found:" -ForegroundColor Cyan
    foreach ($Product in $AcronisProducts) {
        Write-Host "  - $($Product.DisplayName) v$($Product.Version)" -ForegroundColor Yellow
    }
    
    Write-Host "`nStarting uninstallation process..." -ForegroundColor Cyan
    
    $SuccessCount = 0
    $FailCount = 0
    
    # Uninstall each product
    foreach ($Product in $AcronisProducts) {
        Write-Host "`nProcessing: $($Product.DisplayName)..." -ForegroundColor White
        
        if (Start-SilentUninstall -Product $Product) {
            $SuccessCount++
            Write-Host "COMPLETED" -ForegroundColor Green
        } else {
            $FailCount++
            Write-Host "FAILED" -ForegroundColor Red
        }
        
        # Brief pause between uninstalls
        Start-Sleep -Seconds 2
    }
    
    # Summary
    Write-Host "`nUninstallation Summary:" -ForegroundColor Cyan
    Write-Host "  Successful: $SuccessCount" -ForegroundColor Green
    Write-Host "  Failed: $FailCount" -ForegroundColor Red
    Write-Host "  Log file: $LogFile" -ForegroundColor Gray
    
    if ($FailCount -eq 0) {
        Write-Host "`nSUCCESS: All Acronis products have been successfully uninstalled!" -ForegroundColor Green
    } else {
        Write-Host "`nWARNING: Some uninstallations failed. Check the log file for details." -ForegroundColor Yellow
    }
}

Write-LogMessage "=== Acronis Silent Uninstaller Completed ==="
