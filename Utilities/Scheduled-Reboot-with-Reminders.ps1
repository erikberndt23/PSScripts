# PDQ Reboot Notification 
# Schedules reboot in 6 hours and gives users ample warnings / 3 "snooze buttons" before automatically rebooting

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Paramters

$totalHours   = 6          # Total countdown hours
$snoozeHours  = 1          # Hours added per snooze
$maxSnoozes   = 3          # Maximum snoozes
$regPath      = "HKCU:\Software\PDQ Reboot Popup"
$logFile      = "$env:LOCALAPPDATA\PDQ-Reboot-Popup.log"
$eventSource  = "PDQ Reboot Warning"
$shutdownArgs = "/r /f /t 60"


# Logging Function

function Write-Log {
    param (
        [string]$message,
        [int]$EventId = 1001
    )

    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts  $message" | Out-File -Append -FilePath $logFile

    try {
        if (-not [System.Diagnostics.EventLog]::SourceExists($eventSource)) {
            New-EventLog -LogName Application -Source $eventSource
        }
        Write-EventLog -LogName Application -Source $eventSource `
            -EventId $EventId -EntryType Information -Message $message
    } catch {}
}

# Reset Snooze & Reboot State

$reset = $false

if (-not (Test-Path $regPath)) {
    New-Item $regPath -Force | Out-Null
    $reset = $true
} else {
    $state = Get-ItemProperty $regPath -ErrorAction SilentlyContinue
    if (-not $state.Deadline) {
        $reset = $true
    }
}

if ($reset) {
    $deadline = (Get-Date).AddHours($totalHours)
    Set-ItemProperty $regPath Deadline $deadline
    Set-ItemProperty $regPath SnoozesUsed 0
    Write-Log "Initialized reboot countdown. Deadline: $deadline" 1000
}

# Load Reboot Timeline State

$state    = Get-ItemProperty $regPath
$deadline = [datetime]$state.Deadline
$snoozes  = if ($state.SnoozesUsed -ne $null) { [int]$state.SnoozesUsed } else { 0 }

# Calculate Maximum Possible Deadline

$maxDeadline = (Get-Date).AddHours($totalHours)

# Calculate Time Remaining Before Reboot

$remainingMinutes = [math]::Ceiling(($deadline - (Get-Date)).TotalMinutes)

if ($remainingMinutes -le 0) {
    Write-Log "Deadline reached. Rebooting now." 1003
    Remove-ItemProperty $regPath Deadline -ErrorAction SilentlyContinue
    Remove-ItemProperty $regPath SnoozesUsed -ErrorAction SilentlyContinue
    Start-Process shutdown.exe -ArgumentList $shutdownArgs
    exit
}

#  Progressive Escalation

if ($remainingMinutes -le 60) {
    $title = "⚠️ CRITICAL: REBOOT IMMINENT ⚠️"
    $icon  = [System.Windows.Forms.MessageBoxIcon]::Error
} elseif ($remainingMinutes -le 180) {
    $title = "⚠️ Scheduled Reboot Warning ⚠️"
    $icon  = [System.Windows.Forms.MessageBoxIcon]::Warning
} else {
    $title = "⚠️ Scheduled Reboot Notice ⚠️"
    $icon  = [System.Windows.Forms.MessageBoxIcon]::Information
}

# Maximum Snooze Count Check

if ($snoozes -ge $maxSnoozes) {
    [System.Windows.Forms.MessageBox]::Show(
        "Maximum snoozes reached.`n`nYour computer will reboot now.",
        $title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )

    Write-Log "Max snoozes reached. Forcing reboot." 1003
    Remove-ItemProperty $regPath Deadline -ErrorAction SilentlyContinue
    Remove-ItemProperty $regPath SnoozesUsed -ErrorAction SilentlyContinue
    Start-Process shutdown.exe -ArgumentList $shutdownArgs
    exit
}

# Message Box Contents

$hours = [math]::Floor($remainingMinutes / 60)
$mins  = $remainingMinutes % 60

$msg = @"
This computer is scheduled to reboot in:

$hours hour(s) and $mins minute(s)

Snoozes used: $snoozes of $maxSnoozes

Click YES to reboot now.
Click NO to snooze for $snoozeHours hour(s).
"@

$result = [System.Windows.Forms.MessageBox]::Show(
    $msg,
    $title,
    [System.Windows.Forms.MessageBoxButtons]::YesNo,
    $icon
)

# User Actions

if ($result -eq [System.Windows.Forms.DialogResult]::No) {
    # Add snooze, but do not exceed initial TotalHours
    $newDeadline = $deadline.AddHours($snoozeHours)

    # Cap at maximum allowed deadline
if ($newDeadline -gt $maxDeadline) {
    $newDeadline = $maxDeadline
}

    Set-ItemProperty $regPath Deadline $newDeadline
    Set-ItemProperty $regPath SnoozesUsed ($snoozes + 1)

    Write-Log "User snoozed reboot. New deadline: $newDeadline ($($snoozes + 1)/$maxSnoozes)" 1002

} else {
    Write-Log "User approved immediate reboot." 1003
    Remove-ItemProperty $regPath Deadline -ErrorAction SilentlyContinue
    Remove-ItemProperty $regPath SnoozesUsed -ErrorAction SilentlyContinue
    Start-Process shutdown.exe -ArgumentList $shutdownArgs
}
