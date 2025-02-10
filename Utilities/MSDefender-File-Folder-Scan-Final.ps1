# Set up loop condition
$continue = $true
add-type -AssemblyName System.Windows.Forms
while ($continue) {

# Get MS Defender path    
$Defender = where.exe /r 'C:\Program Files\Windows Defender' MpCmdRun.exe

# Get user input
$FilePath = Read-Host "Are you scanning a Directory of files or a Single File? Enter 1 for Directory, Enter 2 for File"

# Open a Windows Folder dialog 
if ($FilePath -eq "1") {
$foldername = New-Object System.Windows.Forms.FolderBrowserDialog
$foldername.Description = "Select a folder"
$foldername.rootfolder = "MyComputer"
$foldername.SelectedPath = $initialDirectory
$modalform = New-Object System.Windows.Forms.Form
$modalform.TopMost = $true

# Scan the selected folder
if($foldername.ShowDialog($modalform) -eq "OK") {
$folder = $foldername.SelectedPath
$Path = $folder
& $Defender -scan -scantype 3 -File $Path
$Response = Read-Host "Do you want to scan more? (Y/N)"

# Prompt user to continue
if ($response = $response -ne "Y") {
Write-Host "Exiting Script..."
continue $false
Exit 0}
}

}

else {
if ($FilePath -eq "2") {
# Enable the use of Windows Forms
Add-Type -AssemblyName System.Windows.Forms
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
# Prompt user to continue
$Response = Read-Host "Do you want to scan more? (Y/N)"
if ($response = $response -ne "Y") {
    Write-Host "Exiting Script..."    
continue $false
Exit 0}
} else {
    Write-Host "No file selected. Exiting."
    Exit 0
}

}

}

}