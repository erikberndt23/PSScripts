Import-Module ActiveDirectory

# Configuration
$DaysThreshold = 14
$MailFrom = "noreply@asti-usa.com"
$MailTo = "itdept@asti-usa.com"
$MailSubject = "ASTi Domain Users with Passwords Expiring in the Next $DaysThreshold Days"
$SMTPServer = "aspmx.l.google.com"

# Get the current date
$Today = Get-Date

# Get all enabled users with non-expired passwords
$Users = Get-ADUser -Filter {Enabled -eq $true -and PasswordNeverExpires -eq $false} -Properties DisplayName, SamAccountName, PasswordLastSet, PasswordNeverExpires, PasswordExpired, msDS-UserPasswordExpiryTimeComputed

# Filter users whose password is expiring within the threshold
$ExpiringUsers = $Users | Where-Object {
    $_."msDS-UserPasswordExpiryTimeComputed" -ne $null -and
    ([datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed") -le $Today.AddDays($DaysThreshold))
}

# Count users with expiring passwords
$countExpiringUsers = $ExpiringUsers.Count

# Exit if there are no expiring passwords
if (-not $countExpiringUsers -or $countExpiringUsers.Count -eq {}) {
    return
}

# Prepare the message body
if ($ExpiringUsers.Count -gt 0) {
    $MailBody = "The following users have passwords expiring within the next $DaysThreshold days:`n`n"
    foreach ($user in $ExpiringUsers) {
        $expiryDate = [datetime]::FromFileTime($user."msDS-UserPasswordExpiryTimeComputed")
        $MailBody += "User: $($user.SamAccountName) - $($user.DisplayName)`nExpires: $expiryDate`n`n"
    }
}

# Create and send the email
$MailMessage = New-Object System.Net.Mail.MailMessage
$MailMessage.From = $MailFrom
$MailMessage.To.Add($MailTo)
$MailMessage.Subject = $MailSubject
$MailMessage.Body = $MailBody

$SMTP = New-Object Net.Mail.SmtpClient($SMTPServer)
try {
    $SMTP.Send($MailMessage)
    Write-Output "Notification email sent to domain admins."
} catch {
    Write-Error "Failed to send email: $_"
}