$EnrollmentsPath = "HKLM:\SOFTWARE\Microsoft\Enrollments\"
 $Enrollments = Get-ChildItem -Path $EnrollmentsPath
 $DiscoveryServerFullUrls = @("https://wip.mam.manage.microsoft.us/Enroll")
 Foreach ($Enrollment in $Enrollments) {
 $EnrollmentObject = Get-ItemProperty Registry::$Enrollment
 if ($EnrollmentObject."DiscoveryServiceFullURL" -in $DiscoveryServerFullUrls ) {
 $EnrollmentPath = $EnrollmentsPath + $EnrollmentObject."PSChildName"
 Remove-Item -Path $EnrollmentPath -Recurse
 & "C:\Windows\System32\deviceenroller.exe /c /AutoEnrollMDM"
 }
 }