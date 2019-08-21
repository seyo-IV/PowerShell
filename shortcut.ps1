[CmdletBinding ()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$ScriptName,
		[string]$Directory = $PWD
		)
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$PWD\$($ScriptName).lnk")
$Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$Arguments1 = "-windowstyle hidden -Noninteractive -ExecutionPolicy Bypass –Noprofile -file"
$Arguments2 = "$($Directory)\$($ScriptName).ps1"
$Shortcut.Arguments = $Arguments1 + " " + $Arguments2
$Shortcut.WorkingDirectory = $Directory
$Shortcut.Save()