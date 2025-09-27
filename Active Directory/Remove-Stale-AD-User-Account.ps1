$staleUser = "astidadmin"

Get-CimInstance -ClassName Win32_UserProfile |
    Where-Object { $_.LocalPath -like "*$staleUser" } |
    Remove-CimInstance -Confirm:$false