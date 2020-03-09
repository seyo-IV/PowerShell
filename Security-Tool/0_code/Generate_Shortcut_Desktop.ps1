$Directory = "C:\Users\Public\Desktop"
$Path = (get-item $PSScriptRoot).parent.parent.FullName
Remove-Item -Path "$Directory\Security-Tool.lnk" -Force -ErrorAction SilentlyContinue
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Directory\Security-Tool.lnk")
$Shortcut.TargetPath = "$Path\Security-Tool\Security-Tool.exe"
$Shortcut.WorkingDirectory = $Directory
$Shortcut.Save()