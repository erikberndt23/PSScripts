# ========= Downloading FortiClient VPN Installer =========
# Define registry paths to check for installed Forticlient VPN
$reg = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

# Check if Forticlient VPN is already installed before proceeding
$agentRegPath = Get-ChildItem -Path $reg | Get-ItemProperty | Where-Object { $_.DisplayName -eq "Forticlient VPN" } -ErrorAction SilentlyContinue

if ($agentRegPath) {
    Write-Output "$($agentRegPath.DisplayName) is already installed. Exiting script."
    Exit 0
} else {
    Write-Host "Forticlient VPN not detected. Proceeding with installation..."
}

# Forticlient VPN installer path and destination
$installerLocation = "https://isos.asti-usa.com/ITDept/Forticlient%20VPN/FortiClientVPNSetup_7.4.3.1790_x64.exe"
$exePath = "$env:TEMP\ForticlientVPN.exe"

# Download Forticlient VPN agent
Write-Output "Downloading Forticlient VPN installer..."
try {
    #Invoke-WebRequest -URI $installerLocation -OutFile $msiPath
    (New-Object System.Net.WebClient).DownloadFile($installerLocation,$exePath)
} 
catch {
    throw "Failed to download Forticlient VPN installer: $_"
}

# ========= Downloading FortiClient VPN Agent =========
# Install Forticlient VPN silently
$arguments = @(
    "`"$exePath`"",
    "/quiet",
    "/norestart"
)
Write-Output "Installing Forticlient VPN..."
Start-Process -FilePath $exePath -ArgumentList $arguments -Wait -NoNewWindow

# Re-check installation after install
$agentRegPost = Get-ChildItem -Path $reg | Get-ItemProperty | Where-Object { $_.DisplayName -eq "Forticlient VPN" } -ErrorAction SilentlyContinue

if ($agentRegPost) {
    Write-Output "$($agentRegPost.DisplayName) installed successfully!"
} else {
    Write-Host "Forticlient VPN was not installed successfully."
}

# ========= FortiClient VPN Registry Import =========
# Variables
$regFileUrl = "https://isos.asti-usa.com/ITDept/Forticlient%20VPN/forticlient-IPSec-vpn-tunnel.reg"  # Update to your actual URL
$tempRegPath = "$env:TEMP\forticlient-IPSec-vpn-tunnel.reg"

# Download the .reg file
try {
    write-host "Downloading VPN registry config file from: $regFileUrl"
    Invoke-WebRequest -Uri $regFileUrl -OutFile $tempRegPath
    Write-Host "Downloaded registry config to: $tempRegPath"
} catch {
    Write-Host "Error downloading .reg file: $_"
    Exit 1
}

# Import the registry file
try {
    write-host "Importing VPN configuration into registry..."
    Start-Process -FilePath "regedit.exe" -ArgumentList "/s `"$tempRegPath`"" -Wait -NoNewWindow
} catch {
    Exit 1
}

# Cleanup
if (Test-Path $tempRegPath) {
    Remove-Item $tempRegPath -Force
}
if (Test-Path $exePath) {
    Remove-Item $exePath -Force
}
# SIG # Begin signature block
# MIIORQYJKoZIhvcNAQcCoIIONjCCDjICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUmDwwkX+S2IFSY0909x1SxjH+
# +XKgggryMIIFPTCCAyWgAwIBAgIRANGiCFUnVyLrp+pxe+XLCVcwDQYJKoZIhvcN
# AQELBQAwJTEjMCEGA1UEAwwaIkFTVGkgU3Vib3JkaW5hdGUgQ0EgMjAyNSIwHhcN
# MjUwNjE4MTkzMTI2WhcNMjcwNjA4MTkzMTI2WjAiMSAwHgYDVQQDDBdwb3dlcnNo
# ZWxsLWNvZGUtc2lnbmluZzCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AOitGgcONQxnTABoxcyOZcOycd+yOE/m0xLfY5zLiKFp56F2XVbqrbWt6UunoFc8
# GhxmKUhYQ3hFz8Gqhf2q1iA6bDk+jV8AkSFXnuCCygFzOPq2rdo7u09lV9tAQyAz
# IE4fS8mb4EeAkbxQl2hT+HRqt3VQJGB98CCgbqI761jAoO63Q86pM2lF85WOyf26
# 98/qFOfFTjD8Wz1x+P8fpgijcwMsFrNQU3JxJ0Q9+pCcKFmyEv6p/UWEROpw2AKd
# Xt34cnZUkWMuWgduOziDbEibSblS3KovDh5INnA7Bhs2GEdjIaNFlmC5InB3MITh
# MWOnLUgZgHjFF1r7TUkTyv1pEBDuXe5G21HbAUXnkNLS9mrO6WuPTmil+Cygxg+J
# aM7/Zu590Vm7JKvtsW0kl86+yKYL4jODwFGgfn6mtWSjTbKXAlSjvtzbsC/Ezx+T
# PJqV6twALqWNoCc0d/ww/lGCFcQeTFHtIgllF1aPTEwP+MrxznmhQFgqbhAUfbf5
# P5qyNfipStInE72pnbmuwGpSsWPZ6oUDqCoyloDDYnkndiUGmGKnJboPFQ0LuFT/
# UpeK3JlzpSsUaHgKI58N8sy5r1c7qu/L2J58kQHZ4OdzbSWzMzuNU6sKZb5kRmrV
# Z+SeGaUv2VdkzfMPaEWW2DzB1Och13XWJWhBtQVgCkw1AgMBAAGjazBpMCIGA1Ud
# EQQbMBmCF3Bvd2Vyc2hlbGwtY29kZS1zaWduaW5nMEMGA1UdHwQ8MDowOKA2oDSG
# Mmh0dHBzOi8vcGtpLmFzdGktdXNhLm5ldC9hc3RpLWludGVybWVkaWF0ZS1jYTIu
# Y3JsMA0GCSqGSIb3DQEBCwUAA4ICAQC3R0vfJ/YkI65IIumx0xLuYAdoduMR3Wxq
# HPUVnugU7V6woivRJiPEzfQPhW3IlCY3RRxVcqSMKKlOu/VSWJOoBdjW0Ie0mrfB
# RCQ8iNiq7eeDVKuCuZ/SreGA76c03poRIa9Kg2xPJ3DNOr/fkBIaf9yJI9SIWXst
# zEwMrpzH+gXEwpv1FLxlLfHXW1XY1vyW1ZGEsNVQejT8vcjYff3QOLOjC01U8Qx9
# LnsBSHSC5uHXrI7ear8Yo8+TvBj48+utqjL14R739IjxR2E2XvijVOg02I/yIck+
# 97JCyfjPL9e8EmTJ3iYHsr0ABvee/x/6iWOE/qTZJSpmuGgacUaUZo6XgCORkPXj
# 90pAEGviaTsEQ86ae/bn4hSIgNfuImrry6QMGWArAm1YjLommzklYePBxAxU6exB
# Bbcqp1ghPZHqusl42dH1kAONBY4/v1LK6rOTTF25CwrqWB5OR+39s/k8RyUjb7IU
# qgZU+o4eMeBeMwWvpfCVbZ7rIr5zwq3SeXMp5wAB/CsyLwHxRl+LDOrTkGjSw2zq
# wQJmBg0cIMo0hwKUBgoMuzjwza4h9qusqFgA2EBvHg1RMyHDq4eiiKBhIPIahUbR
# 1zwUG1cdZU45OVrFsubxYE3yRqA5pWPrrvXqg+MvX30uXJShxnHBSCmBF6NDQFd6
# amSx92+ygTCCBa0wggOVoAMCAQICAQIwDQYJKoZIhvcNAQELBQAwGjEYMBYGA1UE
# AwwPY2EuYXN0aS11c2EubmV0MB4XDTI1MDQxMzE1NTYyMloXDTM1MDQxMTE1NTYy
# MlowJTEjMCEGA1UEAwwaIkFTVGkgU3Vib3JkaW5hdGUgQ0EgMjAyNSIwggIiMA0G
# CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDQomDO+a/MIN6AqfjBdFD+5claqEJO
# lU9IyuYHZdCA+e/txd9pxKQbliQaSaplXZBwKXoeWLKLTGBslA+unn1n3zic7BeM
# Rk6sRC06HY/+mq6zaFAxdbYRCNWiio0+PdNnSC5hE3A5lXCoHjaQCinqX/OX05BX
# UfZ22b7EEehtmQWNytavMK3LvJxml9kLG2MyYKcAVv3Lsa5zRmYh9CCuWdCP3iZ6
# 7AUzaJ3oeZQLY8e/4C34y04YabdYdKoDQveBnbyLccO5Z/mQ/a16zqcsvLLGcuBU
# GPqgyB1axcCokIOZgJWHjYWehKj52ZU6F44MutZOc1qa+jP6dl9U8QFIRQqtO6lG
# YRR0t+eDPQFXmowhZugVAAF7zrKdapgb2jsV0iGwsbfrBlUN0W9QwtSmAW8Jxv/U
# LdCAcnicE9DorgoK2Jetp5AWJdzoFfPs3k3IBh6atId3ha+pVmyLGgHm3dG4DhM1
# exoV2s8OtlKvcl9BBkHgbJa+7qsRKLlKKd1tMt7l2SqeIu8WSSOH/yRdYjTET3bI
# nwL7nTL7fnFVdF1xIYDFAZx5WbgHlMzL0LctQ3O5Gl17EgSc/nmPTT8pwPxL3hCE
# 14r1lAozQ5U1NFyGYXxPQZvw0VRoOnWv8EDx3z0lKc5gXDaYDs94bLURPVbMg8EG
# S6Su2O8rjeZOrwIDAQABo4HyMIHvMB0GA1UdDgQWBBQdY6/rm7j2YSD7GukX6RJw
# 7qew4TAfBgNVHSMEGDAWgBSvPXL6m2Yb+R09zDK9bRPv4GaYKTASBgNVHRMBAf8E
# CDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjBJBggrBgEFBQcBAQQ9MDswOQYIKwYB
# BQUHMAKGLWh0dHA6Ly9wa2kuYXN0aS11c2EubmV0L0FTVGlOZXRSb290Q0EyMDIw
# LmNydDA+BgNVHR8ENzA1MDOgMaAvhi1odHRwOi8vcGtpLmFzdGktdXNhLm5ldC9B
# U1RpTmV0Um9vdENBMjAyMC5jcmwwDQYJKoZIhvcNAQELBQADggIBALUk9E1kSTKF
# yaEC6j9GXWi8plsSLKhOxSKxcMUiLfZgbuSRzdjThk74r7S5p1sQsXGEtv284L3W
# UJDmtnRQ+rnIKpsEXz2NlbmO63Kniij4KEDYDSWcStqi+eBKVeAw+BkUdnN8EH6k
# BvwNZEYhtH9BVbq1KiO2mbYMwQ/9TvRSE5JIYuvDCH2KHmHYSaGRXCcX+ODF00uh
# NcD5M4uOGGXemVV+Hc1kE1uPXSs7uwNVydIZmcx4hPFuMCEc5Efe46+rM6BJct9y
# cLjTZ0CnPU8hpCMyxM/E+jA9+cOgyVqODk4J7jMHMLes66v5tZbsimoHI9iMbfXd
# G5PpnkYnq+VCcbEKgl2oVHspg2tV4YhVKkLgCRLdPw1jQ/Z+qLhTcdlFxQ/8b77z
# paKI+BbNrBYTgHTtoygNWkCUzHEhG/r3xDSB8lKDfIgpN2eR1F6P4exB26nZCJm0
# dTsrfEH5+R5aa3OTssqwbiX3Hc8/AM/3iAweMC2i27Nr6BIQLkLGtTjFaZYZU4RP
# /D/MqLkPhRIMEQES0SIy+V/bQj1f8zVODxcM5XUn6UTloK3txLvtoUTL8COJrZPg
# J3zu4cS2+PkuVUmHyXT+jfbIz/WaQRXs927txfKmfhGCyeNmNBnAHhkS3P2YVg/G
# JN9GRyOpevB1hCLmgqt+lWuVOs6RjgHiMYICvTCCArkCAQEwOjAlMSMwIQYDVQQD
# DBoiQVNUaSBTdWJvcmRpbmF0ZSBDQSAyMDI1IgIRANGiCFUnVyLrp+pxe+XLCVcw
# CQYFKw4DAhoFAKBaMBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcN
# AQkDMQwGCisGAQQBgjcCAQQwIwYJKoZIhvcNAQkEMRYEFA2lvHnbrBmh6VYNZmyj
# hZ4bsTZbMA0GCSqGSIb3DQEBAQUABIICAD0wOZrHYmOpF9cdu+RSZoOLRZOOn/za
# w7WgmcRaA0SD5DLkKpacGnOWOmuwPhD2x2EogVSkhJBeGkKmBIP52BWCfRLeknN1
# 3edU/tR56ULqlUWYPJaxKS6J765TYyvar0UIPmqMWGPxg8vrdqwTCb1gH8fK1WlW
# EHAxDxt3NiEqwAVfCPKeAvcat5Ho/NpGTbRS5WEMElBD6Ybg4zGeAQeDDVpIKrMo
# IVs3VNIfLA/a7aE8kwuflSu4rwT2B2fhscti26gUUnetI+Nwbt77C7cbSia/0FtX
# ONy5CbU7Mr8lko5kRfyYbE3l3ihEvYn9GPYVMZVfLKuZdfomWfijWnIp8V1U8xjr
# 1c1X4WZ1Gyzc5n0u4sXUd8hFVSufzRTCVLpIqF4TvkPaDsRHy0mZi1aUg3nOyeyY
# bnDBYD0WblQZWaZLTiZxwTV/+4BaemPxcDsPQePFBAKoma23kcCbzAUdxuu6XXdF
# ZhU3mrECB7Oi/X/27usftn2Pmy7fWdWKCKJqpQqs6St7MjFCBci4jQMuvG7A1DEe
# FIPB7pSUEG7bJx2NFV8MiSRu98qFtao2a6cXAOoMabW4+w4FOtnUYR6Phj4cvPrA
# hR4Xhz6yJ9jeUG88WdxWFyI5l3+bi02G8LhcS6mIVDSxBOsz2XTL7Opg4al8p63S
# 3snfqw5XNX5A
# SIG # End signature block
