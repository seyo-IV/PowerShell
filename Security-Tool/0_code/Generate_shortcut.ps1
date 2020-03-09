## Setup_Enviroment shortcut
$Directory = $PSScriptRoot
$ParentDir = (get-item $Directory).parent.FullName
Remove-Item -Path "$ParentDir\Setup_Enviroment.lnk" -Force -ErrorAction SilentlyContinue
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$ParentDir\Setup_Enviroment.lnk")
$Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$Arguments1 = "-ExecutionPolicy Bypass –Noprofile -file"
$Arguments2 = "$($Directory)\Install.ps1"
$Shortcut.Arguments = $Arguments1 + " " + $Arguments2
$Shortcut.WorkingDirectory = $Directory
$Shortcut.Save()

## Remove_Tools shortcut
Remove-Item -Path "$ParentDir\Remove_Tools.lnk" -Force -ErrorAction SilentlyContinue
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$ParentDir\Remove_Tools.lnk")
$Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$Arguments1 = "-ExecutionPolicy Bypass –Noprofile -file"
$Arguments2 = "$($Directory)\Remove_Tools.ps1"
$Shortcut.Arguments = $Arguments1 + " " + $Arguments2
$Shortcut.WorkingDirectory = $Directory
$Shortcut.Save()

## Delete_Tool shortcut
Remove-Item -Path "$ParentDir\Delete_Tool.lnk" -Force -ErrorAction SilentlyContinue
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$ParentDir\Delete_Tool.lnk")
$Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$Arguments1 = "-ExecutionPolicy Bypass –Noprofile -file"
$Arguments2 = "$($Directory)\Delete_Tool.ps1"
$Shortcut.Arguments = $Arguments1 + " " + $Arguments2
$Shortcut.WorkingDirectory = $Directory
$Shortcut.Save()