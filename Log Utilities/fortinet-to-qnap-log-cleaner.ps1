# Clean up changes made by Qnaps syslog server to Fortinet logs
# Qnaps add a timestamp and some dashes to the beginning of each line, which breaks Fortinet's log parsing
# This script removes the timestamp and dashes, leaving only the original log content

$ workingDir = "C:\users\erikb\Downloads\fortigate1"

# Step 1: Rename numerical file extensions like .1 .2 .3 to .log

Get-ChildItem -Path "$workingDir" | Where-Object { $_.Extension -match '^\.\d+$' } | ForEach-Object {
    Rename-Item $_.FullName -NewName "$($_.Name).log"
}

# Step 2: Clean the syslog headers from all .log files and write to output folder

New-Item -ItemType Directory -Force -Path "$workingDir\CleanedLogs" | Out-Null

Get-ChildItem -Path "$workingDir" -Filter "*.log" | ForEach-Object {
    (Get-Content $_.FullName) |
     Where-Object { $_ -match 'date=' -or $_ -match 'logver=' } |
        ForEach-Object { $_ -replace '^.*?((?:date=|logver=).*)', '$1' } |
        ForEach-Object { $_ -replace 'time=\d+\s+-\s+-\s+-\s+', '' } |
        Set-Content "$workingDir\CleanedLogs\$($_.Name)" -Encoding utf8
}