Import-Module ActiveDirectory

# Configuration
$DaysThreshold = 14
$MailFrom = "noreply@asti-usa.com"
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

        $MailSubject = "Your ASTi Domain Password is Expiring Soon"

        $MailBody = @"
<html>
<body style="font-family:Segoe UI, sans-serif; font-size:14px;">
<p>Hi $($user.givenName),</p>

<p>This is a friendly reminder that your <strong>ASTi domain password</strong> will expire on <strong>$friendlyDate</strong>.</p>

<p>Please change your password before this date to avoid any disruptions.</p>

<p><strong>Important:</strong> Make sure you're connected to the internal ASTi network either on-site via Ethernet or through the VPN when changing your password.</p>

<p>If you use Windows and Mac devices, please reset your password from your <strong>Macbook first</strong>.</p>

<hr>
<h3>Mac Devices: Password Reset Instructions</h3>
<ol>
<li>Go to <em>System Settings</em> > <em>Users &amp; Groups</em></li>
<li>Click the "i" icon next to your account, then click <strong>Change Password</strong></li>
<li>Follow the on-screen prompts and enter your current password, then then the new password twice</li>
</ol>

<h3>Windows Devices: Password Reset Instructions</h3>
<ol>
<li>Press <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Delete</kbd></li>
<li>Select <strong>Change a password</strong></li>
<li>Enter your current password, then the new password twice</li>
<li>Click <strong>OK</strong> to confirm</li>
</ol>

<hr>

<p><strong>Security Reminder:</strong> The IT department will <u>never</u> ask you to reset your password through an emailed link. Please follow the directions above or visit the Intranet site for detailed instructions on resetting your password.</p>

<p>If you have any questions or concerns, feel free to reach out.</p>

<p>Thank you,<br>ASTi IT Department</p>
</body>
</html>
"@

        $MailMessage = New-Object System.Net.Mail.MailMessage
        $MailMessage.From = $MailFrom
        $MailMessage.To.Add($email)
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
