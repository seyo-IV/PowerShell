#------------------------------------------------------------------------ 
# Author: Sergiy Ivanov (Im Auftrag der ECKD Service GmbH) 
# Verwendungszweck: Script to generate a permission report. 
# Modules Required: ActiveDirectory and NTFSSecurity
# Datum: 20.03.2019 
#------------------------------------------------------------------------ 
#requires -module ActiveDirectory, NTFSSecurity
 <#
 .SYNOPSIS
 Generates an HTML-based permission report

 .PARAMETER Path
 Path to scan.

 .EXAMPLE
 .\Get-Effective-Permissions-HTMLV3.ps1 -Path \\SERVER\SHARE
 #> 
#------------------------------------------------------------------------ 
# Variables 
#------------------------------------------------------------------------ 
$head = "<style>
td {font-family:candara;width:100px; max-width:300px; background-color:white;}
table {width:100%;}
th {font-family:candara;font-size:14pt;background-color:grey;}
h1 {font-family:candara;font-size:18pt}
p1 {font-family:candara;font-size:9pt}
</style>
<title>Effective Permissions</title>"
[CmdletBinding()]
param(
	[Parameter(Mandatory=$True,
	ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
	[string]$Path,
	[string]$DomainPrefix = $env:USER
	)
import-module ActiveDirectory
Import-Module NTFSSecurity
$ObjectList =  @()
$i					   = 0
$ErrorActionPreference 	= "SilentlyContinue"
$plist                 	= @()
$pathfinder		= $PPath -split "\\"
$pathfinder 		= $pathfinder | Select-Object -Last 1
$PPath                  = "\\SERVER\SHARE\Logs\"
$file                   = $PPath + "Effective_Permissions_" + $Pathfinder + ".html"
$Folders                = $Path -Split "\\"
$PathList	        = $Folders | % { $i = 0 } { $Folders[0..$i] -Join "\" -Replace ":$", ":\"; $i++ }
$Plist 			+= $pathlist
Write-Progress -Activity “Scanning Directory” -Status “Scanning” -PercentComplete 50
try
{
$list 	= Get-Childitem -Path $Path -Recurse | ?{ $_.PSIsContainer } | Select-Object FullName
$list 	= $list.fullname
$Plist += $list
}
catch {Write-Warning "Enter a correct path"}
Write-Progress -Activity “Scaning Directory” -Status “Complete” -PercentComplete 100

#------------------------------------------------------------------------ 
# Foreach Loop 
#------------------------------------------------------------------------
foreach($Dir in $PList)
    {
	Write-Progress -Activity “Scanning folders” -Status “On $dir” -PercentComplete ($i / $plist.count*100)

#------------------------------------------------------------------------ 
# Collecting ACLs
#------------------------------------------------------------------------
        $ACLList = Get-NTFSAccess -path $dir | Where-Object {$_.Account -like "$DomainPrefix\*"} | select AccessRights, Account
            foreach($ID in $ACLList)
                {
					$UID = $ID.Account.AccountName -replace '$DomainPrefix\\'
					$Account = $ID.Account.AccountName
					$AccessRight = $ID.AccessRights
                    
                    $UserList =@()
                    try{$UIDcheck = get-aduser -identity $UID}catch{$UIDcheck = get-adgroup -identity $UID}
				    sleep -sec 1
                    if($UIDcheck.ObjectClass -eq "user")
                        {
                        
                        }
                    else
					{
                        if($UID -Like "*LOCAL_GROUP_PREFIX*")
                                                    {
                    $GrName  = (Get-ADGroup $UID -Properties member | Select-Object -ExpandProperty member | Select -first 1 | %{Get-ADGroup $_}).name
                    $ADGroup = Get-ADGroup $GrName -Properties member | Select-Object -ExpandProperty member

                    foreach ($Object in $ADGroup)
		                {
		                    $GetName		= Get-ADUser -filter * -SearchBase "$Object"
		                    if($GetName -ne $null)
                                {
									$Name = $GetName.SamaccountName
                                    $UserList += $Name
									
                                }
                                
                                
		                }
                        }else{
					$token = Get-ADGroup -Filter {name -eq $UID -and GroupScope -eq "DomainLocal"}
					if($token)
					{

					$nestedgroups = Get-ADGroupMember $UID | ?{$_.ObjectClass -eq "Group"} | %{Get-ADGroupMember $_ | ?{$_.ObjectClass -eq "Group"}| Select-Object Name}
					foreach($group in $nestedgroups)
					{
                   
                    $group = $group -replace "@{name=", "" -replace "}"
 
                    
                    $ADGroup = Get-ADGroup $group -Properties member | Select-Object -ExpandProperty member

                    foreach ($Object in $ADGroup)
		                {
		                    
                            $GetName	  = Get-ADUser -filter * -SearchBase "$Object"
		                    if($GetName -ne $null)
                                {
                                    
									$Name = $GetName.SamaccountName
									$UserList += $Name
                                    

                                }
                                
                                
		                }
                           
                           else{}
                           }
						   }
						   else
							{
					$ADGroup = Get-ADGroup $UID -Properties member | Select-Object -ExpandProperty member

                   
                    foreach ($Object in $ADGroup)
		                {
		                    
                            $GetName	  = Get-ADUser -filter * -SearchBase "$Object"
		                    if($GetName -ne $null)
                                {
                                    
									$Name = $GetName.SamaccountName
									$UserList += $Name
                                    

                                }
                                
                                
		                }
							}
						   }
                        } 
$data     = @()
$Account = $Account | Out-String
$AccessRight = $AccessRight | Out-String
$UserList = $UserList | Get-Unique
$UserList = $UserList | ForEach-Object { 
    if( $UserList.IndexOf($_) -eq ($UserList.count -1) ){
        $_.replace(";","")
    }else{$_}  
}
$UserList = $userlist | Out-String


$list = New-Object PSCustomObject
$list | Add-Member -type NoteProperty -Name Path -value $dir
$list | Add-Member -type NoteProperty -Name Account -value $Account
$list | Add-Member -type NoteProperty -Name AccessRight -value $AccessRight
$list | Add-Member -type NoteProperty -Name UserList -value $UserList
$data += $list
$ObjectList += $data
                 }

$i++
}

$ObjectList | ConvertTo-Html -As table -Head $head -PreContent "<h1>Effective Permissions</h1>" | Out-File $file
