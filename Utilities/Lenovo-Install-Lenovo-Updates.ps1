$path = "$env:programfiles (x86)\Lenovo\System Update\tvsu.exe"
$arguments = @(
    "/ CM"
    "-search C"
    "-action INSTALL"
    "-includerebootpackages 1,3,4"
    "-noicon"
)
start-process $path -ArgumentList $arguments