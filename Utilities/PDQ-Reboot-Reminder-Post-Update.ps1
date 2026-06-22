Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Settings

$TimeoutSeconds = 90
$AccentColor     = [System.Drawing.ColorTranslator]::FromHtml("#3A61AA")
$BackgroundColor = [System.Drawing.ColorTranslator]::FromHtml("#E7E9ED")
$uptime = (Get-Date) - (gcim Win32_OperatingSystem).LastBootUpTime
$uptimeStr = "{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
# Build Form

$form = New-Object System.Windows.Forms.Form
$form.Text = "Restart Required"
$form.Size = New-Object System.Drawing.Size(560,330)
$form.StartPosition = "CenterScreen"
$form.TopMost = $true
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.BackColor = $BackgroundColor

# Default result = Cancel (covers X + timeout)
$form.Tag = "Cancel"

# Header

$header = New-Object System.Windows.Forms.Panel
$header.Dock = "Top"
$header.Height = 45
$header.BackColor = $AccentColor
$form.Controls.Add($header)

$headerLabel = New-Object System.Windows.Forms.Label
$headerLabel.Text = "System Maintenance Completed"
$headerLabel.ForeColor = "White"
$headerLabel.Font = New-Object System.Drawing.Font("Segoe UI",11,[System.Drawing.FontStyle]::Bold)
$headerLabel.AutoSize = $true
$headerLabel.Location = New-Object System.Drawing.Point(15,12)
$header.Controls.Add($headerLabel)

# Message

$label = New-Object System.Windows.Forms.Label
$label.Text = "Updates and maintenance are complete.`r`n`r`nFor optimal performance and security, please restart your computer.`r`n`r`nCurrent uptime: $uptimeStr"
$label.Size = New-Object System.Drawing.Size(460,110)
$label.Location = New-Object System.Drawing.Point(25,65)
$label.Font = New-Object System.Drawing.Font("Segoe UI",10)
$form.Controls.Add($label)

# Reboot Button

$rebootBtn = New-Object System.Windows.Forms.Button
$rebootBtn.Text = "Restart Now"
$rebootBtn.Size = New-Object System.Drawing.Size(140,32)
$rebootBtn.Location = New-Object System.Drawing.Point(120,185)
$rebootBtn.BackColor = $AccentColor
$rebootBtn.ForeColor = "White"
$rebootBtn.FlatStyle = "Flat"
$rebootBtn.Add_Click({
    $form.Tag = "Reboot"
    $form.Close()
})
$form.Controls.Add($rebootBtn)

# Cancel Button

$cancelBtn = New-Object System.Windows.Forms.Button
$cancelBtn.Text = "Cancel"
$cancelBtn.Size = New-Object System.Drawing.Size(140,32)
$cancelBtn.Location = New-Object System.Drawing.Point(280,185)
$cancelBtn.FlatStyle = "Flat"
$cancelBtn.Add_Click({
    $form.Tag = "Cancel"
    $form.Close()
})
$form.Controls.Add($cancelBtn)

# Footer

$footer = New-Object System.Windows.Forms.Label
$footer.AutoSize = $false
$footer.Width = 520
$footer.Height = 20
$footer.TextAlign = 'MiddleCenter'
$footer.Font = New-Object System.Drawing.Font("Segoe UI",8)
$footer.ForeColor = [System.Drawing.Color]::DimGray

$footer.Text = @"
ASTi IT Department
"@

$footer.Location = New-Object System.Drawing.Point(20,270)
$form.Controls.Add($footer)

# Auto-close timer (Cancel)

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = $TimeoutSeconds * 2000
$timer.Add_Tick({
    $timer.Stop()
    $form.Close()
})
$timer.Start()

# Bring dialog box to foreground

$form.Add_Shown({
    $form.Activate()
    $form.BringToFront()
    $form.Focus()
})


# Show dialog

$form.ShowDialog() | Out-Null


# Result handling

if ($form.Tag -eq "Reboot") {
    Start-Process shutdown.exe -ArgumentList "/r /f /t 60"
}