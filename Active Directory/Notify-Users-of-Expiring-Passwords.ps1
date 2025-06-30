Import-Module ActiveDirectory

# Configuration
$DaysThreshold = 14
$MailFrom = "noreply@asti-usa.com"
$SMTPServer = "aspmx.l.google.com"

# Get the current date
$Today = Get-Date

# Get all enabled users with expiring passwords
$Users = Get-ADUser -Filter {
    Enabled -eq $true -and PasswordNeverExpires -eq $false -and PasswordLastSet -ne $null
} -Properties DisplayName, SamAccountName, EmailAddress, mail, PasswordLastSet, PasswordNeverExpires, PasswordExpired, msDS-UserPasswordExpiryTimeComputed

# Filter users whose password is expiring within the threshold
$ExpiringUsers = $Users | Where-Object {
    $_."msDS-UserPasswordExpiryTimeComputed" -ne $null -and
    ([datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed") -le $Today.AddDays($DaysThreshold))
}

# Notify each user individually
foreach ($user in $ExpiringUsers) {
    $email = $user.EmailAddress
    if (-not $email) {
        # Fallback to 'mail' attribute
        $email = $user.mail
    }

    if ($email) {
        $expiryDate = [datetime]::FromFileTime($user."msDS-UserPasswordExpiryTimeComputed")

        # Compose message
        $MailSubject = "Your ASTi Domain Password Will Expire Soon"
        $MailBody = @"
Hello $($user.DisplayName),

This is a reminder that your ASTi domain password is set to expire on $expiryDate.

Please change your password before this date to avoid any disruptions.

IMPORTANT: Make sure you are connected to the ASTi network (on-site or via VPN) when changing your password!

Password Reset Instructions for Windows Users (on Domain-Joined Computers)

1. Press Ctrl + Alt + Delete on your keyboard.

2. Click Change a password.

3. Enter your current password, then your new password twice.

4. Click OK. You will see a confirmation if the change is successful

Password Reset Instructions for Mac Users (on Domain-Joined Computers)

1. Go to System Settings or System Preferences > Users & Groups.

2. Select your account and click Change Password.

3. Follow the prompts to enter your old and new password.

As a reminder, the IT department will never ask you to reset your password through a link. Please follow the directions above or contact the IT department if you have any questions or concerns.

Thank you,

ASTi IT Department
"@

        # Create and send the email
        $MailMessage = New-Object System.Net.Mail.MailMessage
        $MailMessage.From = $MailFrom
        $MailMessage.To.Add($email)
        $MailMessage.Subject = $MailSubject
        $MailMessage.Body = $MailBody

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