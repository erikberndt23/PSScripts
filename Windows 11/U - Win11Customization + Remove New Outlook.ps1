$regkey = 'HKCU:\Software\EWAScripts'
$name = 'Win11Customization'
$notdone = $true

# Remove New Outlook
Get-AppxPackage | Where-Object {$_.Name -Like '*OutlookForWindows*'} | Remove-AppxPackage -ErrorAction SilentlyContinue
# Remove Chat (Teams Personal)
Get-AppxPackage | Where-Object {$_.Name -Like '*MicrosoftTeams*'} | Remove-AppxPackage -ErrorAction SilentlyContinue
# Remove Dev Home
Get-AppxPackage | Where-Object {$_.Name -Like '*DevHome*'} | Remove-AppxPackage -ErrorAction SilentlyContinue

DO {

  $exists = Get-ItemProperty -Path $regkey -Name $name -ErrorAction SilentlyContinue
  
  if ($null -eq $exists) {
    #creates registry key value that pushes taskbar to the left orientation
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarAl -Value 0 -Force
    #creates registry key to turn off the modern right click menu
    New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Value "" -Force
    #creates registry key for tracking (HKCU\EWASCRIPTS), and sets a value of 1 (Win11Customization)
    New-Item -Path $regkey -Force
    Set-ItemProperty -Path $regkey -Name $name -Value 1 -Force
    taskkill /f /im explorer.exe
    start explorer.exe
    $notdone = $false
  }
  else {
    break
  }
}While ($notdone)