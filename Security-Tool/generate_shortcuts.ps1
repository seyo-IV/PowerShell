
    Param (
    [string]$ScriptName = "Copy_Tool",
	[string]$Directory,
	[string]$ScriptName2 = "Generate_shortcut"
	)
$Directory = $PSScriptRoot
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Directory\$($ScriptName).lnk")
$Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$Arguments1 = "-ExecutionPolicy Bypass –Noprofile -file"
$Arguments2 = "$($Directory)\0_code\$($ScriptName).ps1"
$Shortcut.Arguments = $Arguments1 + " " + $Arguments2
$Shortcut.WorkingDirectory = $Directory
$Shortcut.Save()

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Directory\generate_setup.lnk")
$Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$Arguments1 = "-ExecutionPolicy Bypass –Noprofile -file"
$Arguments2 = "$($Directory)\0_code\$($ScriptName2).ps1"
$Shortcut.Arguments = $Arguments1 + " " + $Arguments2
$Shortcut.WorkingDirectory = $Directory
$Shortcut.Save()