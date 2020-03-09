Start-Process cmd.exe -ArgumentList '/c choco uninstall clink -y' -Wait
sleep -sec 3
Remove-Item -Path C:\ProgramData\chocolatey -Recurse -Force
