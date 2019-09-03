#requires -version 3
<#
.SYNOPSIS
  This script creates a shortcutt in the current directory for the GUI scripts with some
  fancy start parametern, so the shell isn't visible etc...
  
.DESCRIPTION
  Create a sortcut for the GUI scripts.
  
.PARAMETER ScriptName
  Name of the script without the fileextension.
    
.INPUTS
  None.
  
.OUTPUTS
  Create a shortcut in the current dierctory.
  
.NOTES
  Version:        1.0
  Author:         Sergiy Ivanov
  Creation Date:  30.08.2019
  Purpose/Change: Initial script development
  
.EXAMPLE
  shortcut.ps1 -ScriptName SomeScript
#>
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
