$continue = $true
while ($continue) {

$Defender = where.exe /r 'C:\Program Files\Windows Defender' MpCmdRun.exe
$FilePath = Read-Host "Are you scanning a Directory of files or a Single File? Enter 1 for Directory, Enter 2 for File"

if ($FilePath -eq "1") {
$Path = Read-Host "Please enter the exact folder path or volume you wish to scan for viruses. For example: C:\Temp or D:\"
& $Defender -scan -scantype 3 -File $Path
$Response = Read-Host "Do you want to scan more? (Y/N)"
if ($response = $response -ne "Y") {
Write-Host "Exiting Script..."
continue $false
Exit 0}


}
else {
if ($FilePath -eq "2") {
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
$Response = Read-Host "Do you want to scan more? (Y/N)"
if ($response = $response -ne "Y") {
    Write-Host "Exiting Script..."    
continue $false
Exit 0}
} else {
    Write-Host "No file selected. Exiting."
}
}}
}