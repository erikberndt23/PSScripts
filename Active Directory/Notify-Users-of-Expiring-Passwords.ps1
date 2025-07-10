Import-Module ActiveDirectory

# Configuration
$DaysThreshold = 14
$MailFrom = "noreply@asti-usa.com"
$MailReplyTo = "itdept@asti-usa.com"
$SMTPServer = "aspmx.l.google.com"
$Today = Get-Date

# Get users and include needed properties
$Users = Get-ADUser -Filter {
    Enabled -eq $true -and PasswordNeverExpires -eq $false
} -Properties DisplayName, SamAccountName, EmailAddress, mail, givenName, PasswordLastSet, PasswordNeverExpires, PasswordExpired, msDS-UserPasswordExpiryTimeComputed

# Filter users with passwords expiring soon
$ExpiringUsers = $Users | Where-Object {
    $_."msDS-UserPasswordExpiryTimeComputed" -ne $null -and
    ([datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed") -le $Today.AddDays($DaysThreshold))
}

foreach ($user in $ExpiringUsers) {
    $email = $user.EmailAddress
    if (-not $email) { $email = "$user.mail" }

    if ($email) {
        $expiryDate = [datetime]::FromFileTime($user."msDS-UserPasswordExpiryTimeComputed")
        $friendlyDate = $expiryDate.ToString("dddd, MMMM d, yyyy")

        $MailSubject = "[Action Required] Your ASTi Domain Password is Expiring Soon"

        $MailBody = @"
<html>
<body style="font-family:Segoe UI, sans-serif; font-size:14px; color:#333;">
<p>Hi $($user.givenName),</p>

<p>This is a friendly reminder that your <strong>ASTi domain password</strong> will expire on <strong>$friendlyDate</strong>.</p>

<p>Please change your password before this date to avoid any disruptions. This is the password you use to sign into your computer and the VPN.</p>

<p><strong>Important:</strong> Make sure you're connected to the internal ASTi network on-site via Ethernet cable (<strong>not on WiFi</strong>) or through the VPN when changing your password.</p>

<p>If you use both Windows and Mac devices, please <strong>reset your password from your MacBook first</strong>.</p>

<h3>ASTi Password Requirements</h3>
<ul>
  <li>Must be at least <strong>15 characters</strong></li>
  <li>Must include <strong>uppercase & lowercase letters, numbers,</strong> and <strong>special characters</strong></li>
  <li>Cannot reuse any of your previous <strong>24 passwords</strong></li>
  <li>Password must be changed every <strong>90 days</strong></li>
</ul>

<hr style="border:none; border-top:1px solid #ccc;">

<h3>Mac: Password Reset Instructions</h3>
<ol>
  <li>Go to <em>System Settings</em> > <em>Users &amp; Groups</em></li>
  <li>Click the <strong>"i"</strong> icon next to your account, then click <strong>Change Password</strong></li>
  <li>Follow the on-screen prompts and enter your current password, then the new password twice</li>
</ol>

<h3>Windows: Password Reset Instructions</h3>
<ol>
  <li>Press <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Delete</kbd> at the same time</li>
  <li>Select <strong>Change a password</strong></li>
  <li>Enter your current password, then the new password twice</li>
  <li>Click <strong>the arrow button</strong> to confirm</li>
  <li>Respond to the Duo prompt</li>
</ol>

<hr style="border:none; border-top:1px solid #ccc;">

<h3>Security Reminder</h3>
<p>The IT department will <u>never</u> ask you to reset your password through an emailed link. Please follow the directions above or visit the Intranet site for detailed instructions on resetting your password.</p>

<p>If you have any questions or concerns, feel free to reach out.</p>

<p>Thank you,<br>
ASTi IT Department</p>
</body>
</html>
"@

        $MailMessage = New-Object System.Net.Mail.MailMessage
        $MailMessage.From = $MailFrom
        $MailMessage.To.Add($email)
        $MailMessage.ReplyTo = $MailReplyTo
        $MailMessage.Subject = $MailSubject
        $MailMessage.Body = $MailBody
        $MailMessage.IsBodyHtml = $true

        $SMTP = New-Object Net.Mail.SmtpClient($SMTPServer)

        try {
            $SMTP.Send($MailMessage)
            Write-Output "Sent expiration notice to $($user.SamAccountName) <$email>"
        } catch {
            Write-Error "Failed to send email to $($user.SamAccountName) <$email>: $_"
        }
    } else {
        Write-Warning "No email address found for user $($user.SamAccountName)."
    }
}