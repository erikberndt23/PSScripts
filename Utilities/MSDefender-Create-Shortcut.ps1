# Create path if not existing
$folderPath = "C:\IT-Tools"
If(!(test-path -PathType container $folderPath)) {
New-Item -ItemType Directory -Path $folderPath 
}

# Define the path to the PowerShell script
$scriptPath = "C:\IT-Tools\MSDefender.ps1"

# Define the path where the shortcut will be created (e.g., Desktop)
$shortcutPath = ("$Env:ALLUSERSPROFILE\Desktop\"), "Microsoft Defender Anti-Virus Scan.lnk"

# Create a new WScript.Shell COM object
$wshShell = New-Object -ComObject WScript.Shell

# Create the shortcut
$shortcut = $wshShell.CreateShortcut($shortcutPath)

# Set the target path to the PowerShell executable and pass the script path as an argument
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$scriptPath`""

# Set the working directory
$shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName($scriptPath)

# Set the window style (1 = Normal, 3 = Maximized, 7 = Minimized)
$shortcut.WindowStyle = 1

# Set a description for the shortcut
$shortcut.Description = "Shortcut to run on-demand MS Defender AV Scans"

# Set an icon for the shortcut - Using Windows Defender Icon Index 184
$shortcut.IconLocation = "C:\Windows\System32\imageres.dll,184"

# Save the shortcut
$shortcut.Save()