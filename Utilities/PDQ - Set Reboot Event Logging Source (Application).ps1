$Source = "PDQ Reboot Warning"
if (-not [System.Diagnostics.EventLog]::SourceExists($Source)) {
    New-EventLog -LogName Application -Source $Source
}