#requires -version 3

try{
$testchoco = Test-Path -Path C:\ProgramData\chocolatey
if(!$testchoco){
Write-Host -ForegroundColor Yellow "[INFO]  Starting Chocolatey setup."
Powershell.exe -noprofile -File "$PSScriptRoot\PreRequiments.ps1"
Write-Host -ForegroundColor Green "[OK]  Chocolatey installed"
}
"`n"
Write-Host -ForegroundColor Yellow "[INFO]  Starting PowerShell setup."
Powershell.exe -noprofile -File "$PSScriptRoot\Setup_PS.ps1"
Write-Host -ForegroundColor Green "[OK]  Setup of PowerShell is complete."
"`n"
Write-Host -ForegroundColor Yellow "[INFO]  Starting CMD setup."
cmd.exe /c '$PSScriptRoot\Setup_CMD.bat'
Start-Sleep -sec 3
Start-Process cmd.exe -argumentList '/c exit' -Wait -PassThru -NoNewWindow
$User = $env:UserName
$parentPath = (get-item $PSScriptRoot).parent.FullName
Copy-Item -Path "$parentPath\0_data\settings" -Destination "C:\Users\$user\AppData\Local\clink"
Start-Sleep -sec 3
$prevContennt = Get-Content "C:\Users\$user\AppData\Local\clink\settings"
$newContent = $prevContennt -replace "history_io = 0", "history_io = 1"
$newContent | Set-Content "C:\Users\$user\AppData\Local\clink\settings"
Write-Host -ForegroundColor Green "[OK]  Setup of CMD is complete."
"`n"
Write-Host -ForegroundColor Yellow "[INFO]  Generating shortcut."
Powershell.exe -noprofile -File "$PSScriptRoot\Generate_Shortcut_Desktop.ps1"
Write-Host -ForegroundColor Green "[OK]  Shortcut generated."
Start-Sleep -sec 3
}catch{$_.Exception.Message}