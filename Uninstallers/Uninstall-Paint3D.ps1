# Remove Paint 3D for all users

Get-AppxPackage -AllUsers -Name Microsoft.MSPaint | Remove-AppxPackage -AllUsers
Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ "Microsoft.MSPaint" | Remove-AppxProvisionedPackage -Online