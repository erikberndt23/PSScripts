# Remove Google Chrome desktop Shortcut
Write-Output("Removing Google Chrome desktop Shortcuts...")
    if (test-path "C:\users\*\Desktop\Google Chrome.lnk") {
        Write-Output("Remove Google Chrome desktop Shortcut on the following user's desktop: ")
        Remove-Item -Path "C:\users\*\Desktop\Google Chrome.lnk" -Verbose -ErrorAction SilentlyContinue
}
# Remove Google Chrome taskbar pinnings
Write-Output("Removing Google Chrome taskbar pinnings...")
    if (test-path "C:\Users\*\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Google Chrome.lnk") {
        Write-Output("Remove Google Chrome taskbar pinnings for the following user's: ")
        Remove-Item -Path "C:\Users\*\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Google Chrome.lnk" -Verbose -ErrorAction SilentlyContinue
}