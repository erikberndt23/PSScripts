# software to uninstall

$software = "*notepad++*"

# registry path to search

$reg = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'

# Query registry for uninstall strings for software to be uninstalled and uninstall it via CMD

Get-ChildItem $reg |
    Where-Object{ $_.GetValue('DisplayName') -like "$software" } |
    ForEach-Object{
        $uninstallString = $_.GetValue('UninstallString')
        $UninstallString = "$UninstallString"
        $UninstallString += ' /S'
Write-Host $uninstallString }
Start-Process cmd.exe -wait -NoNewWindow -argumentlist "/c $uninstallstring"