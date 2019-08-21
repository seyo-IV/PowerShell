#requires -version 3
<#
.SYNOPSIS
  This script generates a list of NTFS-Permissions

.DESCRIPTION
  Show NTFS-Permissions

.PARAMETER Path
    Path to scan to.

.INPUTS
  None.

.OUTPUTS
  None.

.NOTES
  Version:        1.0
  Author:         Sergiy Ivanov
  Creation Date:  21.08.2019
  Purpose/Change: Initial script development
  
.EXAMPLE
  Get-NTFSPermissions.ps1 -Path \\server\share
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=$True,
	ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
	[string]$Path
	)

        $ErrorActionPreference = "SilentlyContinue"
        $Folders = $Path -Split "\\"
        $Plist = $Folders | % { $i = 0 } { $Folders[0..$i] -Join "\" -Replace ":$", ":\"; $i++ }
	    $FList   = foreach($dir in $Plist){
        
		Resolve-Path -Path $dir
		Get-Item $dir | select FullName
		Get-Acl -Path $dir -Filter Access | Select-Object -ExpandProperty Access | Where-Object {$_.IdentityReference -like "EBK\*"} | Select-Object IdentityReference
		}
	
	  $Flist | ft FullName, IdentityReference





