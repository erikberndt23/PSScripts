$dir = 'C:\temp\win11'
mkdir $dir
$webClient = New-Object System.Net.WebClient
$url = "https://go.microsoft.com/fwlink/?linkid=2156295"
$file = "$($dir)\MediaCreationTool.exe"
$webClient.DownloadFile($url,$file)
Start-Process -FilePath $file -ArgumentList "/auto upgrade /quiet /noreboot" -Wait