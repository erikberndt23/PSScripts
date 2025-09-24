$dir = "C:\temp\wu"
New-Item -Path $dir -ItemType Directory -Force | Out-Null
$webClient = New-Object System.Net.WebClient
$url1 = "https://catalog.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/7342fa97-e584-4465-9b3d-71e771c9db5b/public/windows11.0-kb5065426-x64_32b5f85e0f4f08e5d6eabec6586014a02d3b6224.msu"
$url2 = "https://catalog.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/d8b7f92b-bd35-4b4c-96e5-46ce984b31e0/public/windows11.0-kb5043080-x64_953449672073f8fb99badb4cc6d5d7849b9c83e8.msu"
$file1 = "$($dir)\wu1.msu"
$file2 = "$($dir)\wu2.msu"
$webClient.DownloadFile($url1,$file1)
$webClient.DownloadFile($url2,$file2)
Start-Process -FilePath "dism.exe" -ArgumentList "/Online /Add-Package /PackagePath:$dir /Quiet /NoRestart" -Wait -Verb RunAs