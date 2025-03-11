#Kill ScreenConnect Service
net stop ltsvcmon & taskkill /im ltsvcmon.exe /f & taskkill /im ltsvc.exe /f & taskkill /im lttray.exe /f & net start ltsvcmon & net start ltservice

#Get BIOS version
wmic bios get smbiosbiosversion

#Get BIOS Serial Number
Get-WmiObject win32_bios | select SerialNumber
wmic bios get serialnumber

#Reset or add new user
net user Username NewPassword
net user username password /add
Net localgroup administrators username /add

#Reset TCP/IP Stack
Netsh winsockreset
Netsh int ip reset
Netsh int ipv6 reset
Ipconfig /flushdns
Ipconfig /release
Ipconfig /renew

#Log off user
Query user
Logoff user id #

#Turn off Monitor
(Add-Type '[DllImport("user32.dll")]public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name a -Pas)::SendMessage(-1,0x0112,0xF170,2)

#Turn on Monitor
(Add-Type '[DllImport("user32.dll")]public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name a -Pas)::SendMessage(-1,0x0112,0xF170,-1)

#Pings/Latency
Test-Connection 1.1 -Repeat | select {Get-Date},Status,Latency
ping 1.1 -t | select {Get-Date; $_}

#Get HP Computer Product Number
Get-WmiObject win32_computersystem | Select-Object SystemSKUNumber

#Get DNS Servers

netsh interface ipv4 show dnsservers

#Set interface to DHCP

netsh interface ip set address "Interface Name" dhcp

#Determine version of Adobe installed

Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize | findstr Adobe

#List files by date modified
ls | sort LastWriteTime -Descending | Select -First 5

#Get Net Adapter Stats
Get-NetAdapter
Get-NetAdapter | select Name,Status, LinkSpeed
Get-NetAdapterStatistics
Get-NetRoute | ? DestinationPrefix -eq '0.0.0.0/0' | Get-NetIPInterface | Where ConnectionState -eq 'Connected'

#Download File
Invoke-WebRequest -Uri "http://www.contoso.com\file.exe" -OutFile "C:\path\file.exe"

#HP Flash Firmware
Ilorest.exe$: flashfwpkg --url iLO IP Address -u username -p "password" "C:\Users\eberndt\Download
s\U32_2.80_04_20_2023.fwpkg"

#Join Computer to Domain and Rename
add-computer –domainname ad.contoso.com -Credential AD\adminuser -restart –force

Add-Computer -DomainName MYLAB.Local -newname NewTARGETCOMPUTER

Add-Computer  -DomainName Domain02 -NewName Server044 -Credential Domain02\Admin01 -Restart

Add-Computer -DomainName Domain02 -OUPath "OU=testOU,DC=domain,DC=Domain,DC=com"

add-computer -domainname ewacorp.com -OUPath "OU=Huntsville,OU=Warrior,OU=Win11,OU=EWA Computers,DC=ewacorp,DC=com" -newname "HNT-MXL4364Q6G" -DomainCredential ewacorp\administrator

#Rename Computer
Rename-Computer -NewName "Server044" -DomainCredential ewacorp\administrator -force -Restart

$SerialNumber = (Get-WmiObject -class win32_bios).SerialNumber  
$computer = "NEW-$SerialNumber"  
Rename-Computer -NewName $computer -Force  

#Get Exchange Inbox Rules
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline
get-inboxrule -mailbox user@ewa.com | select -ExpandProperty Description

#Uninstall Visual Studio 2019
"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" uninstall --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community" --quiet --norestart

#Find Uninstall Strings
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

Get-ChildItem -Path $RegPath | Get-ItemProperty | Where-Object {$_.DisplayName -match "softwarename" }

#Uninstall
(Get-WMIObject -Classname Win32_Product | Where-Object Name -Match 'softwarename').UnInstall()

wmic product where "name like 'softwarename'" call uninstall /nointeractive

Get-CimInstance -Classname WIn32_Product | Where-Object Name -Match 'softwarename' |
Invoke-CimMethod -MethodName UnInstall

Uninstall-Package -Name "softwarename"

%windir%\system32\msiexec.exe /x (Get-WmiObject -Class Win32_Product -Filter "Name='Cisco AnyConnect Secure Mobility Client'").IdentifyingNumber /norestart /qn

#Re-install all Windows Store Apps
Get-AppXPackage -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

#Re-Install XBOX Game Bar
Get-AppXPackage *Microsoft.XboxGamingOverlay* -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

$manifestpath = (get-appxpackage -Name "*xbox*").InstallLocation + "\Appxmanifest.xml" 
Add-AppxPackage -register $manifestpath -DisableDevelopmentMode


#Get Immutable ID
Install-Module AzureAD
Import-Module AzureAD
Install-Module MSOnline
Import-Module MSOnline
Connect-MSOLService
Get-MsolUser -UserPrincipalName upn@domain.com | select ImmutableID
[GUID][system.convert]::FromBase64String("IMMUTABLEID")

#Compare Immutable ID between cloud and on-prem user
Get-ADUser "username" | fl UserPrincipalName,objectGUID
Connect-MsolService
Get-MsolUser -UserPrincipalName "username@ewa.com" | fl UserPrincipalName,ImmutableId
[GUID][system.convert]::FromBase64String("immutableid==")

#Calculate and set immutable ID
Import-Module ActiveDirectory
$userUPN = "testuser@2azure.nl" 
$guid = [guid]((Get-ADUser -LdapFilter "(userPrincipalName=$userUPN)").objectGuid) 
$immutableId = [System.Convert]::ToBase64String($guid.ToByteArray())
Connect-MsolService 
Get-MsolUser -UserPrincipalName $userUPN | Set-MsolUser -ImmutableId $immutableId

#Clear Immutable ID
Set-MSOLUser -UserPrincipalName upn@domain.com -ImmutableID "$null"

Get-AzureADUser -All $true | Select-Object -Property UserPrincipalName,ObjectId,ImmutableId,DirSyncEnabled | Export-Csv -Path C:/Users1.Csv -NoTypeInformation

# Connect to Azure AD with global admin credentials 
Connect-MsolService 
# Set the ImmutableID to null for the affected user 
Set-MsolUser -ObjectId '<user's object ID>' -ImmutableId "$null"
# Trigger a Delta sync 
Start-ADSyncSyncCycle -PolicyType Delta

#Move Hyper-V VM
Move-VM -Name "VMNAME" -DestinationHost HOSTNAME -IncludeStorage -DestinationStoragePath C:\Users\Public\Documents\Hyper-V\VMNAME

Disable net adapters before migrating

#Turn off New Outlook
HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences\UseNewOutlook = 0
#Turn on New Outlook
HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences\UseNewOutlook = 1

#Get Installed Windows Updates (Powershell)
Get-HotFix

#Get Profile List
Get-ItemProperty -path  "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" | select ProfileImagePath, PSChildName

#GPO Scopes
gpresult /s $env:computername /u ewacorp\USERNAME /scope COMPUTER /Z

#Search EXO for permission changes
import-module ExchangeOnlineManagement
Connect-ExchangeOnline
Search-AdminAuditLog –cmdlets Add-MailboxPermission

#Create a List of all the OneDrive URLs in your Organization
$TenantUrl = Read-Host "https://ewacorp-admin.sharepoint.com/"
$LogFile = [Environment]::GetFolderPath("Desktop") + "\OneDriveSites.log"
Connect-SPOService -Url $TenantUrl
Get-SPOSite -IncludePersonalSite $true -Limit all -Filter "Url -like '-my.sharepoint.com/personal/'" | Select -ExpandProperty Url | Out-File $LogFile -Force
Write-Host "Done! File saved as $($LogFile)."

#Extend Expired Password
Import-Module ActiveDirectory
Set-ADUser -Identity <username> -Replace @{pwdlastset="0"}
Set-ADUser -Identity <username> -Replace @{pwdlastset="-1"}

#Get Expired Password Users (Excludes disabled accounts)
Get-ADUser -Filter "enabled -eq 'true'" -SearchBase "OU=ewa users,DC=ewacorp,DC=com" -Properties Enabled, PasswordLastSet, PasswordExpired, PasswordNeverExpires | Where-Object{($_.PasswordExpired -eq $True)} | sort Name | ft Name, PasswordLastSet, PasswordExpired, PasswordNeverExpires

#Get Expired Password Users
Get-ADUser -Filter * -SearchBase "OU=ewa users,DC=ewacorp,DC=com" -Properties Enabled, PasswordLastSet, PasswordExpired, PasswordNeverExpires | Where-Object{($_.PasswordExpired -eq $True)} | sort Name | ft Name, PasswordLastSet, PasswordExpired, PasswordNeverExpires

#Get GMSA Allowed Principals
Get-ADServiceAccount AzureATP-GMSA -Properties * | fl DNSHostName, SamAccountName, KerberosEncryptionType, ManagedPasswordIntervalInDays, PrincipalsAllowedToRetrieveManagedPassword, passwordlastset

Get-ADServiceAccount -Identity AzureATP-GMSA -Properties PrincipalsAllowedToRetrieveManagedPassword | select PrincipalsAllowedToRetrieveManagedPassword |ForEach-Object { $_.PrincipalsAllowedToRetrieveManagedPassword }

#Set GMSA Allowed Principals
Set-ADServiceAccount -Identity AzureATP-GMSA -PrincipalsAllowedToRetrieveManagedPassword EWA-PDC$,EWA-BDC$,EWA-WVADC$,EWA-HUNTDC$,EWA-RDG$,EWA-NJDC$,EWA-HNTDC01$

#Test GMSA Credentials (run on DC)
Test-ADServiceAccount -identity azureatp-gmsa

#Speech
Add-Type -AssemblyName System.speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$speak.Speak('Hello...')

#Get Number of Attached Monitors
@(Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams).Length

#Get Number of Active Displays
@(Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams | where-object { $_.Active }).Length

#Backup BitLocker key to Entra
BackupToAAD-BitLockerKeyProtector -MountPoint $env:SystemDrive
-KeyProtectorId ((Get-BitLockerVolume -MountPoint $env:SystemDrive
).KeyProtector | where {$_.KeyProtectorType -eq "RecoveryPassword"
}).KeyProtectorId

OR

BackupToAAD-BitlockerKeyProtector -mountpoint c: -KeyProtectorID "{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}"

OR

$BLV = Get-BitLockerVolume -MountPoint "C:"
BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId

#Backup BitLocker key to AD
manage-bde -protectors -get c: (list protectors and recovery ID/password. Make note of ID)
manage-bde -protectors -adbackup c: -id "{XXXXXX-XXXXX-XXXXX}"

#Rotate BitLocker key
manage-bde -protectors -get c: (list protectors and recovery ID/password. Make note of ID)
manage-bde -protectors -add -recoverypassword c: (add new recovery password)
verify bitlocker key has been added to device page in Entra before proceeding 
manage-bde -protectors -delete -id "{XXXXXX-XXXXX-XXXXX}" (delete password from step 1)

get-childitem -path C:\Windows\LTSvc\packages -Include *.* -File -recurse | ? { $_.FullName -inotmatch 'EWAScripts' } | foreach { $_.Delete()}

get-childitem -path C:\Windows\LTSvc\packages -Include *.* -File -recurse | ? { $_.FullName -inotmatch 'EWAScripts' } | Remove-Item

get-childitem -path C:\Windows\LTSvc\packages -recurse | ? { $_.FullName -inotmatch 'EWAScripts'
 } | foreach { $_.Delete()}

get-childitem -path C:\Windows\LTSvc\packages -recurse | ? { $_.FullName -inotmatch 'EWAScripts'} | Remove-Item -Recurse -Force

get-childitem -path C:\Windows\LTSvc\packages -recurse | ? { $_.FullName -inotmatch 'EWAScripts'} | Remove-Item -Recurse -Force

#Get Active Network Connection
get-netadapter | where {$_.Status -eq 'Up'}

#Get Dynamic Distribution List Membership (EXO)
Install-Module ExchangeOnlineManagement
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline
$DGName = "DDG Group Name"
Get-DynamicDistributionGroupMember -Identity $DGName | Select DisplayName, PrimarySMTPAddress, RecipientType, RecipientTypeDetails | Export-CSV "C:\\Distribution-List-Members-1.csv" -NoTypeInformation -Encoding UTF8

#Setup Dynamic Distribution Group (EXO)
New-DynamicDistributionGroup -Name "HRN-CORP" -PrimarySmtpAddress "HRN-CORP@ewa.com" -IncludedRecipients "MailboxUsers" -ConditionalDepartment "Accounting","Corporate", "IT"

#Clear AD Attributes
set-aduser -identity USERNAME -clear 'manager','homeDirectory','homeDrive','physicalDeliveryOfficeName','telephoneNumber','o','postalcode','st','streetaddress','title','department','l','company','c','department'

#Change WSL Root Password
Open cmd.exe
Type wsl -u root
Type passwd username and change the password
Type exit
Type wsl
Type sudo echo hi to confirm the new password works.

#Get-Installed Package
get-package | Where-Object {$_.Name -like "*forticlient*"}

#get a list of installed apps
Get-Package | Sort name

#uninstall an app
get-package dropbox | uninstall-package  -force

OR

get-package | Where-Object {$_.Name -like "*forticlient*"} | Uninstall-Package -Force

#Measure command time
(Measure-Command {Get-CimInstance Win32_Product}).TotalSeconds
14.2854306
(Measure-Command {Get-Package}).TotalSeconds
1.3287564

#Exclude Folder(s) from Deletion
get-childitem -path C:\Windows\LTSvc\packages -recurse | ? { $_.FullName -inotmatch 'EWAScripts'} | Remove-Item -Recurse -Force

#Exclude multiple folders

get-childitem -path C:\Windows\LTSvc\packages -Exclude 'EWAScripts','HPIA' | Remove-Item -Recurse -Force

#Get Last Access Time of Program
Get-ChildItem -Path ${env:ProgramFiles} -Filter "FileZilla.exe" -Recurse | Get-ItemProperty | select name,lastaccesstime | sort -Property lastaccesstime 

#Get Installed Outlook Com Add-ins
$searchScopes = "HKCU:\SOFTWARE\Microsoft\Office\Outlook\Addins","HKLM:\SOFTWARE\Wow6432Node\Microsoft\Office\Outlook\Addins"
$Results = $searchScopes | % {Get-ChildItem -Path $_ | % {Get-ItemProperty -Path $_.PSPath} | Select-Object @{n="Name";e={Split-Path $_.PSPath -leaf}},FriendlyName,Description} | Sort-Object -Unique -Property name
$Results

#Get Last Boot Time
Get-CimInstance -ClassName Win32_OperatingSystem | Select LastBootUpTime

#Get OS installation date, version, and architecture
Get-CimInstance -ClassName Win32_OperatingSystem | select Version, InstallDate, OSArchitecture


#Factory Reset HP Dock
Disconnect it from your laptop.
Unplug everything including the AC cable from your dock.
Press and hold the Power button for about 1 minute to drain the remaining power from the dock.
Plug everything back in.

#Classic Device and Printers Dialogue 
shell:::{A8A91A66-3A7D-4424-8D24-04E180695C7A}

#Crowdstrike Falcon Connectwise Automate Configuration
Name: CrowdStrike Falcon Sensor
Program Location: %programfiles%\CrowdStrike\CSFalconService.exe
Definition Location: %systemroot%\System32\drivers\CrowdStrike
AP Process: CSFalconService*
Date Mask: (,*)
OS Type: All OS's
(Remainder of fields leave blank) 



#Set DNS servers via powershell
Set-DnsClientServerAddress -InterfaceIndex X -ServerAddresses ("10.0.1.20", "10.0.1.30")

#Get USB Flash Drive Serial Number
Get-WmiObject Win32_DiskDrive | select Model, Name, InterfaceType, SerialNumber

$path = 'HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown'
if (!(Test-Path -LiteralPath $path)) { [void] (New-Item -Path $path -Force) }
Set-ItemProperty -Path $path -Name bEnableAV2Enterprise -Value 0 -Type Dword

#Re-Run MDM Join Script
C:\windows\System32\DeviceEnroller.exe /c /AutoEnrollMDM

#Re-register the BitLocker WMI (win32_encryptablevolume) class.
mofcomp.exe c:\windows\system32\wbem\win32_encryptablevolume.mof

#Create a new entry in Credential Manager
cmdkey /add:computer-name /user:user-name /pass:your-password

#Delete an entry in Credential Manager
cmdkey /list
cmdkey /delete:target-name

#Remove and re-install Windows Store App for all users
Remove-Appxpackage -Package "NVIDIACorp.NVIDIAControlPanel_8.1.967.0_x64__56jybvy8sckqj" -AllUsers

Add-AppxPackage -DisableDevelopmentMode -Register "C:\Program Files\WindowsApps\NVIDIACorp.NVIDIAControlPanel_8.1.967.0_x64__56jybvy8sckqj\AppxManifest.xml" -Verbose 

Get-AppxPackage -User sigmadefense\lierin.martin -Name NVIDIACorp.NVIDIAControlPanel

#Clear Outlook Auto-CompleteCache
Start-Process -filepath 'C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE' -ArgumentList '/cleanautocompletecache','/recycle'

#Cleanup Folder but preserve specific folders
get-childitem -path C:\Windows\LTSvc\packages -Exclude 'EWAScripts','HPIA' | Remove-Item -Recurse -Force
