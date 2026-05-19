$softwareNames = @(
    "PDQConnectAgent",
    "PDQConnectUpdater",
    "PDQ RD Agent*"
)

foreach ($softwareName in $softwareNames) {
    try {
        $msi = (Get-Package -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$softwareName*" }).FastPackageReference

        if ($msi) {
            Write-Host "$softwareName is installed. Uninstalling now..."
            Start-Process msiexec.exe -Wait -PassThru -ArgumentList "/x $msi /qn /norestart"
            Write-Host "$softwareName successfully uninstalled!"

            $stillInstalled = Get-Package -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$softwareName*" }

            if ($stillInstalled) {
                Write-Host "$softwareName is still installed..."
            }

        } else {
            Write-Host "$softwareName not found...Skipping!"
        }

    } catch {
        Write-Host "Error uninstalling $softwareName : $_"
    }
}