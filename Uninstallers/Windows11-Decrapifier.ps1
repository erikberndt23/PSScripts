# Windows 11 "De-Crapifier"

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*GetStarted*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*Messaging*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*MicrosoftOfficeHub*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*MicrosoftSolitaireCollection*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*Office.OneNote*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*OneConnect*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*People*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*SkypeApp*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*windowscommunicationsapps*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*WindowsFeedbackHub*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*GamingApp*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*MicrosoftTeams*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*ZuneMusic*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*ZuneVideo*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*ClipChamp*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*News*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*ToDo*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*Outlook*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*Phone*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-appxprovisionedpackage -online | where-object {$_.packagename -like "*Weather*"} | remove-appxprovisionedpackage -Online -AllUsers

Get-AppxPackage -AllUsers *MicrosoftSolitaireCollection* | Remove-AppxPackage -AllUsers

Get-AppxPackage -AllUsers *MixedReality.Portal* | Remove-AppxPackage -AllUsers

Get-AppxPackage -AllUsers *Office.OneNote* | Remove-AppxPackage -AllUsers

Get-AppxPackage -AllUsers *SkypeApp* | Remove-AppxPackage -AllUsers

Get-AppxPackage -AllUsers *Wallet* | Remove-AppxPackage -AllUsers

Get-AppxPackage -AllUsers *WindowsFeedbackHub* | Remove-AppxPackage -AllUsers

Get-AppxPackage -AllUsers *GamingApp* | Remove-AppxPackage -AllUsers

Get-AppxPackage -AllUsers *Teams* | Remove-AppxPackage -AllUsers

Get-AppxPackage -AllUsers *ZuneMusic* | Remove-AppxPackage -AllUsers

Get-AppxPackage -AllUsers *ZuneVideo* | Remove-AppxPackage -AllUsers

Get-AppxPackage -AllUsers *windowscommunicationsapps* | Remove-AppxPackage -AllUsers

Get-AppxPackage -AllUsers *Getstarted* | Remove-AppxPackage -AllUsers

Get-AppxPackage -AllUsers *People_* | Remove-AppxPackage -AllUsers

Get-AppxPackage -AllUsers *king* | Remove-AppxPackage -AllUsers

Get-AppxPackage -AllUsers *Spotify* | Remove-AppxPackage -AllUsers

If (-not (Test-Path -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned') )

{New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore' -Name "Deprovisioned"}

New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned' -Name "Microsoft.Getstarted_8wekyb3d8bbwe" -Force

New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned' -Name "Microsoft.Messaging_8wekyb3d8bbwe" -Force

New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned' -Name "Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe" -Force

New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned' -Name "Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe" -Force

New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned' -Name "Microsoft.Office.OneNote_8wekyb3d8bbwe" -Force

New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned' -Name "Microsoft.OneConnect_8wekyb3d8bbwe" -Force

New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned' -Name "Microsoft.People_8wekyb3d8bbwe" -Force

New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned' -Name "Microsoft.SkypeApp_kzf8qxf38zg5c" -Force

New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned' -Name "microsoft.windowscommunicationsapps_8wekyb3d8bbwe" -Force

New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned' -Name "Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe" -Force

New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned' -Name "Microsoft.GamingApp_8wekyb3d8bbwe" -Force

New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned' -Name "MicrosoftTeams_8wekyb3d8bbwe" -Force

New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned' -Name "Microsoft.ZuneMusic_8wekyb3d8bbwe" -Force

New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned' -Name "Microsoft.ZuneVideo_8wekyb3d8bbwe" -Force

New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned' -Name "king.com.FarmHeroesSaga_kgqvnymyfvs32" -Force

New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned' -Name "king.com.CandyCrushFriends_kgqvnymyfvs32" -Force

New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned' -Name "SpotifyAB.SpotifyMusic_1.133.569.0_x86__zpdnekdrzrea0" -Force