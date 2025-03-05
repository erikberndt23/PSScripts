IF EXIST "%PROGRAMFILES(x86)%\Lenovo\System Update\tvsu.exe" GOTO END
"\\asti-usa.net\software\system_update_5.08.03.59.exe" /SP- /verysilent /log /norestart
echo "Lenovo System Update is installed on this computer" > "%PROGRAMFILES(x86)%\Lenovo\System Update\tvsu.exe"
goto END
:END