# Enable the use of Windows Forms
Add-Type -AssemblyName System.Windows.Forms
 
# Find the Defender executable
$Defender = where.exe /r 'C:\Program Files\Windows Defender' MpCmdRun.exe
 
# Create an Open File Dialog box
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.Title = "Select a File to Scan"
$OpenFileDialog.Filter = "All Files (*.*)|*.*"
$OpenFileDialog.InitialDirectory = [Environment]::GetFolderPath('Desktop')
 
# Show the dialog and capture the result
$Result = $OpenFileDialog.ShowDialog()
 
# If the user selected a file, scan it
if ($Result -eq [System.Windows.Forms.DialogResult]::OK) {
    $Path = $OpenFileDialog.FileName
& $Defender -scan -scantype 3 -File $Path
} else {
    Write-Host "No file selected. Exiting."
}