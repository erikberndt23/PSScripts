$s = Get-Content "C:\Users\eberndt\OneDrive - Electronic Warfare Associates, Inc\Documents\WindowsPowerShell\Scripts\Bluetooth-3.ps1" | Out-String
$j = [PSCustomObject]@{
  "Script" =  [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($s))
} | ConvertTo-Json -Compress

$oneline = "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String(('" + $j + "' | ConvertFrom-Json).Script)) | iex"

$c = [convert]::ToBase64String([System.Text.encoding]::Unicode.GetBytes($oneline))

("Powershell -NoLogo -NonInteractive -NoProfile -ExecutionPolicy Bypass -Encoded " + $c) | Out-File -Encoding Default K:\script.cmd