# PDQ Reboot Notification
# Provides live countdown, friendly messaging, snooze limit, and progressive escalation
# Gives users 6 hour deadline to reboot. Users can pause reboot notifications up to 3 times before system reboots automatically. Otherwise, if no response system will reboot in 6 hours

# Parameters

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Config

$totalHours   = 6
$snoozeHours  = 1
$maxSnoozes   = 3
$regPath      = "HKCU:\Software\PDQ Reboot Popup"
$logFile      = "$env:LOCALAPPDATA\PDQ-Reboot-Popup.log"
$eventSource  = "PDQ Reboot Warning"
$shutdownArgs = "/r /f /t 120"
$headerText = "Scheduled Reboot Required"
$bannerText = "System Maintenance - Please Reboot Your Computer"

# Calculate system uptime to display to user

$os = Get-CimInstance Win32_OperatingSystem
$lastBoot = $os.LastBootUpTime
$uptime = (Get-Date) - $lastBoot

# Format uptime to reader friendly format

$uptimeString = ""
if ($uptime.Days -gt 0) { $uptimeString += "$($uptime.Days) day(s) " }
if ($uptime.Hours -gt 0) { $uptimeString += "$($uptime.Hours) hour(s) " }
$uptimeString += "$($uptime.Minutes) minute(s)"

# Logging Function

function Write-Log {
    param([string]$message, [int]$EventId=1001)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts  $message" | Out-File -Append -FilePath $logFile

    try {
        if (-not [System.Diagnostics.EventLog]::SourceExists($eventSource)) {
            New-EventLog -LogName Application -Source $eventSource
        }
        Write-EventLog -LogName Application -Source $eventSource -EventId $EventId -EntryType Information -Message $message
    } catch {}
}

# Show Reboot Prompt Function
function Show-RebootPrompt {
    param(
        [datetime]$Deadline,
        [int]$SnoozesUsed,
        [int]$MaxSnoozes,
        [int]$SnoozeHours
    )

    $AccentColor     = [System.Drawing.ColorTranslator]::FromHtml("#3A61AA")
    $BackgroundColor = [System.Drawing.ColorTranslator]::FromHtml("#E7E9ED")
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $headerText
    $form.Size = New-Object System.Drawing.Size(560,350)
    $form.StartPosition = 'CenterScreen'
    $form.TopMost = $true
    $form.ControlBox = $false # Hide close button
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.ShowInTaskbar = $false
    $form.BackColor = $BackgroundColor
    $form.Tag = "No"

    # Block Alt+F4 Exit

    $form.KeyPreview = $true
    $form.Add_KeyDown({
        if ($_.Alt -and $_.KeyCode -eq 'F4') { $_.Handled = $true }
    })

    # Header Panel

    $header = New-Object System.Windows.Forms.Panel
    $header.Dock = 'Top'
    $header.Height = 48
    $header.BackColor = $AccentColor
    $form.Controls.Add($header)
    $headerLabel = New-Object System.Windows.Forms.Label
    $headerLabel.Text = $bannerText
    $headerLabel.ForeColor = [System.Drawing.Color]::White
    $headerLabel.Font = New-Object System.Drawing.Font("Segoe UI",11,[System.Drawing.FontStyle]::Bold)
    $headerLabel.AutoSize = $true
    $headerLabel.Location = New-Object System.Drawing.Point(15,14)
    $header.Controls.Add($headerLabel)

    # Message Label

    $msgLabel = New-Object System.Windows.Forms.Label
    $msgLabel.Text = ""
    $msgLabel.Size = New-Object System.Drawing.Size(520,150)
    $msgLabel.Location = New-Object System.Drawing.Point(20,70)
    $msgLabel.Font = New-Object System.Drawing.Font("Segoe UI",10)
    $msgLabel.ForeColor = [System.Drawing.Color]::Black
    $form.Controls.Add($msgLabel)

    # Buttons

    $yes = New-Object System.Windows.Forms.Button
    $yes.Text = "Reboot now"
    $yes.Size = New-Object System.Drawing.Size(150,32)
    $yes.Location = New-Object System.Drawing.Point(110,230)
    $yes.BackColor = $AccentColor
    $yes.ForeColor = [System.Drawing.Color]::White
    $yes.FlatStyle = 'Flat'
    $yes.Add_Click({
        $form.Tag = "Yes"
        $form.Close()
    })
    $form.Controls.Add($yes)

    $no = New-Object System.Windows.Forms.Button
    $no.Text = "Snooze"
    $no.Size = New-Object System.Drawing.Size(150,32)
    $no.Location = New-Object System.Drawing.Point(300,230)
    $no.BackColor = [System.Drawing.Color]::White
    $no.FlatStyle = 'Flat'
    $no.Add_Click({
        $form.Tag = "No"
        $form.Close()
    })
    $form.Controls.Add($no)

    # Footer

    $footer = New-Object System.Windows.Forms.Label
    $footer.Text = "ASTi IT Department"
    $footer.Font = New-Object System.Drawing.Font("Segoe UI",8)
    $footer.ForeColor = [System.Drawing.Color]::DimGray
    $footer.TextAlign = 'MiddleLeft'
    $footer.Dock = 'Bottom'
    $footer.Height = 25
    $footer.Padding = '5,0,0,0'
    $form.Controls.Add($footer)

    # Timer for live countdown

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 1000
    $timer.Add_Tick({
        $remaining = [math]::Max(0, ($Deadline - (Get-Date)).TotalMinutes)
        $hours = [math]::Floor($remaining / 60)
        $mins  = [math]::Floor($remaining % 60)
        $msgLabel.Text = "This computer must restart soon for system maintenance.`n`n" +
                         "Time remaining: $hours hour(s) $mins minute(s)`n" +
                         "Your computer has been online: $uptimeString.`n" +
                         "Snoozes used: $SnoozesUsed of $MaxSnoozes.`n" +
                         "Click 'Reboot now' to restart immediately or 'Snooze' to delay $SnoozeHours hour(s)."
    })
    $timer.Start()

    $form.ShowDialog() | Out-Null
    $timer.Stop()
    return $form.Tag
}

# Initialize reboot state

$reset = $false

if (-not (Test-Path $regPath)) {
    New-Item $regPath -Force | Out-Null
    $reset = $true
} else {
    $state = Get-ItemProperty $regPath -ErrorAction SilentlyContinue
    if (-not $state.Deadline) { $reset = $true }
}

if ($reset) {
    $startTime = Get-Date
    $deadline = $startTime.AddHours($totalHours)
    Set-ItemProperty $regPath Deadline $deadline
    Set-ItemProperty $regPath SnoozesUsed 0
    Set-ItemProperty $regPath StartTime $startTime
    Write-Log "Initialized reboot countdown. Deadline: $deadline" 1000
}

# Load current state

$state = Get-ItemProperty $regPath
$deadline = [datetime]$state.Deadline
$startTime = [datetime]$state.StartTime
$snoozes = if ($null -ne $state.SnoozesUsed) { [int]$state.SnoozesUsed } else { 0 }
$maxDeadline = $startTime.AddHours($totalHours)

$remainingMinutes = [math]::Ceiling(($deadline - (Get-Date)).TotalMinutes)

if ($remainingMinutes -le 0) {
    Write-Log "Deadline reached. Rebooting now." 1003
    Remove-ItemProperty $regPath Deadline -ErrorAction SilentlyContinue
    Remove-ItemProperty $regPath SnoozesUsed -ErrorAction SilentlyContinue
    Start-Process shutdown.exe -ArgumentList $shutdownArgs
    exit
}

# Progressive escalation titles
if ($remainingMinutes -le 60) { $title = "⚠️ CRITICAL: REBOOT IMMINENT" }
elseif ($remainingMinutes -le 180) { $title = "⚠️ Scheduled Reboot Warning" }
else { $title = "⚠️ Scheduled Reboot Notice" }

# Max snooze reached check
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

# Show user prompt
$result = Show-RebootPrompt -Deadline $deadline -SnoozesUsed $snoozes -MaxSnoozes $maxSnoozes -SnoozeHours $snoozeHours

# Handle user response

if ($result -eq "No") {
    $newDeadline = $deadline.AddHours($snoozeHours)
    if ($newDeadline -gt $maxDeadline) { $newDeadline = $maxDeadline }

    Set-ItemProperty $regPath Deadline $newDeadline
    Set-ItemProperty $regPath SnoozesUsed ($snoozes + 1)
    Write-Log "User snoozed reboot. New deadline: $newDeadline ($($snoozes + 1)/$maxSnoozes)" 1002
} else {
    Write-Log "User approved immediate reboot." 1003
    Remove-ItemProperty $regPath Deadline -ErrorAction SilentlyContinue
    Remove-ItemProperty $regPath SnoozesUsed -ErrorAction SilentlyContinue
    Start-Process shutdown.exe -ArgumentList $shutdownArgs
}