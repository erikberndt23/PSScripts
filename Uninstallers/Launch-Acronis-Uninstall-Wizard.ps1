# Target installed EXE program over MSI installation
$app = Get-Package -Name "Acronis True Image" -ProviderName Programs

# Get uninstall strings. Normally silent install paramaters can be apended below. Acronis True Image does not support silent install/uninstall switches however
$UninstallCommand = $app.Meta.Attributes['UninstallString']

# Uninstall Acronis True Image using uninstall command discovered on line 5
Start-Process -FilePath cmd.exe -ArgumentList '/c', $UninstallCommand