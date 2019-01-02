###########################################################################
# ORIGINAL AUTHOR	: Sergiy Ivanov / ECKD Service GmbH - http://www.eckd.de
# DATE    			: 20-10-2017  
# EDIT			    : 20-10-2017 
# COMMENT 			: Query the ACL's on a Pathtree. And output it in a clean format
# VERSION			: 1.0 
###########################################################################
 
# ERROR REPORTING ALL 

$Path = read-host "Enter full path `
[WORKS ONLY WITH LOCAL OR NETWORK DRIVES] `
----- [A REMOTE ADRESS WORNT WORK] -----"

$ErrorActionPreference = "SilentlyContinue"
$Folders = $Path -Split "\\"
$Plist	 = $Folders | % { $i = 0 } { $Folders[0..$i] -Join "\" -Replace ":$", ":\"; $i++ } 

$FList   = foreach($dir in $Plist)
	{
    Resolve-Path -Path $dir
	Get-Item $dir | select FullName
	Get-Acl -Path $dir -Filter Access | Select-Object -ExpandProperty Access | Where-Object {$_.IdentityReference -like "EBK\*"} | Select-Object IdentityReference
    }
	
$Flist | ft FullName, IdentityReference
