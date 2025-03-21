# Notifies IT staff of an account lockout when it occurs
# To be run on a domain controller
# Define message subject, sender, and recipient(s)
$MailSubject= “ALERT: User Account locked out”
$MailFrom="DC1@asti-usa.com"
$MailTo="erik.berndt@asti-usa.com"

# Check the security event log for the most recent lockout event
$EventID = Get-EventLog -LogName Security -InstanceId 4740 -Newest 1

# Creates a variable which contains the contents of the lockout event log. This is used for the actual message in the email
$MailBody= $EventID.Message + $EventID.TimeGenerated

# Creates an SMTP object and assigns an SMTP address
$SmtpClient = New-Object system.net.mail.smtpClient
$SmtpClient.host = “aspmx.l.google.com”

# Creates a new mail message object
$MailMessage = New-Object system.net.mail.mailmessage
$MailMessage.from = $MailFrom
$MailMessage.To.add($MailTo)
$MailMessage.IsBodyHtml = 0
$MailMessage.Subject = $MailSubject
$MailMessage.Body = $MailBody

# Sends the message to specified recipients
$SmtpClient.Send($MailMessage)