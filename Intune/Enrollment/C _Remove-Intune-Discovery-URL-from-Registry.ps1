$EnrollmentsPath = "HKLM:\SOFTWARE\Microsoft\Enrollments\"
$Enrollments = Get-ChildItem -Path $EnrollmentsPath
$DiscoveryServerFullUrls = @("https://enrollment.manage.microsoft.us/enrollmentserver/discovery.svc")
Foreach ($Enrollment in $Enrollments) {
$EnrollmentObject = $Enrollments
if ($EnrollmentObject."DiscoveryServiceFullURL" -in $DiscoveryServerFullUrls ) {
$EnrollmentPath = $EnrollmentsPath + $EnrollmentObject."PSChildName"
Remove-Item -Path $EnrollmentsPath -Recurse
& "C:\Windows\System32\deviceenroller.exe /c /AutoEnrollMDM"
}
}