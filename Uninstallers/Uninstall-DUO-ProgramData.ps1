$uninstallpath = Get-ChildItem -Path "C:\ProgramData\Package Cache\{506f03f6-29ca-499a-bd38-5c313e6f3a7d}" -Filter "Setup64.exe" -Recurse -outvariable Newvar;
if ($uninstallpath) {
    Start-Process -FilePath $uninstallpath.FullName -ArgumentList "/uninstall /quiet" -NoNewWindow -Wait
} else {
    Write-Host "Uninstall executable not found."
}