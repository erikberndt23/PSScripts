$mailSubject = "Alert: user account locked out"
$mailFrom = "noreply@asti-usa.com"
$mailTo = "itdept@asti-usa.com"

$EventID = Get-EventLog -LogName Security -InstanceId 4740 -Newest 1

$mailBody = $EventID.Message + " " + $EventID.TimeGenerated

$smtpClient = New-Object system.net.mail.smtpClient
$smtpClient.Host = "aspmx.l.google.com"

$mailMessage = New-Object System.Net.Mail.MailMessage
$mailMessage.from = $mailFrom
$mailMessage.to.add($MailTo)
$mailMessage.IsBodyHtml = 0
$mailMessage.subject = $mailSubject
$MailMessage.body = $mailBody

$smtpClient.Send($mailMessage)