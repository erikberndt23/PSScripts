$path = 'HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown'
if (!(Test-Path -LiteralPath $path)) { [void] (New-Item -Path $path -Force) }
Set-ItemProperty -Path $path -Name bEnableAV2Enterprise -Value 0 -Type DWord