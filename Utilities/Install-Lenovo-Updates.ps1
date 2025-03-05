$path = "$env:programfiles (x86)\Lenovo\System Update\tvsu.exe"
$arguments = @(
    "/ CM"
    "-search R"
    "-action INSTALL"
    "-includeRebootPackages 1,3,4"
    "-NoIcon"
)
start-process $path -ArgumentList $arguments