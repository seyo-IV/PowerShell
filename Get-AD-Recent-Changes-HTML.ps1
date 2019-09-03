#requires -version 3 -module ActiveDirectory
<#
.SYNOPSIS
  Generate a HTML report with effective permissions for user and groups.
  
.DESCRIPTION
  Show effective permissions for user and groups..
  
.PARAMETER Path
  Path to scan.

.PARAMETER Depth
  How deep should the scan go.
  
.INPUTS
  None.
  
.OUTPUTS
  "\\SERVER\Logs\Recent-Group-Changes.html"
  
.NOTES
  Version:        1.0
  Author:         Sergiy Ivanov
  Creation Date:  03.09.2019
  Purpose/Change: Initial script development
  
.EXAMPLE
  Get-AD-Recent-Changes-HTML.ps1 -Path \\SERVER\SHARE -Depth 5
#>
[CmdletBinding()]
param(
	[Parameter(Mandatory=$True,
	ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
	[string]$Path,
	[Parameter(Mandatory=$True,
	ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
	[int]$Depth
	)

$head = "<style>
td {font-family:candara;width:100px; max-width:300px; background-color:white;}
table {width:100%;}
th {font-family:candara;font-size:14pt;background-color:#9e1981;}
h1 {font-family:candara;font-size:18pt}
p1 {font-family:candara;font-size:9pt}
</style>

<title>Effective Permissions</title>"
try{
import-module ActiveDirectory
Import-Module NTFSSecurity
}
catch
{ 
  Write-Host "[ERROR]`t  Module couldn't be loaded. Script will stop! $($_.Exception.Message)" 
  Exit 1 
}
$ObjectList =  @()
$i					   = 0
$ErrorActionPreference = "SilentlyContinue"
$plist                 = @()
$Pathfinder			   = $Path -split "\\"
$Pathfinder 		   = $Pathfinder | Select-Object -Last 1
$PPath                 = "\\SERVER\Logs\"
$file                  = $PPath + "Effective_Permissions_" + $Pathfinder + ".html"
Write-Progress -Activity “Scanning Directory” -Status “Scanning” -PercentComplete 50
try
{
If($Depth -eq ""){
$DirList 	= (Get-Childitem -Path $Path -Recurse | ?{ $_.PSIsContainer }).FullName
$Plist += $Path
$PList += $DirList
}else{
$DirList 	= (Get-Childitem -Path $Path -Recurse -Depth 3 | ?{ $_.PSIsContainer }).FullName
$Plist += $Path
$PList += $DirList
}
}
catch {Write-Warning "Enter a correct Path"}
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
        $ACLList = Get-NTFSAccess -Path $dir | Where-Object {$_.Account -like "Domain\*"} | select AccessRights, Account
            foreach($ID in $ACLList)
                {
					$UID = $ID.Account.AccountName -replace 'Domain\\'
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
									$Name = $GetName.sAMAccountName
                                    $UserList += $Name + ";"
									
                                }
                                
                                
		                }
							}else{
					$token = Get-ADGroup -Filter {name -eq $UID -and GroupScope -eq "DomainLocal"}
					if($token)
					{

					$nestedgroups = Get-ADGroupMember $id | ?{$_.ObjectClass -eq "Group"} | %{(Get-ADGroupMember $_ | ?{$_.ObjectClass -eq "Group"}).name}
					foreach($group in $nestedgroups)
					{
                   
                    #$group = $group -replace "@{name=", "" -replace "}"
 
                    
                    $ADGroup = Get-ADGroup $group -Properties member | Select-Object -ExpandProperty member

                    foreach ($Object in $ADGroup)
		                {
		                    
                            $GetName	  = Get-ADUser -filter * -SearchBase "$Object"
		                    if($GetName -ne $null)
                                {
                                    
									$Name = $GetName.sAMAccountName
									$UserList += $Name + ";"

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
                                    
									$Name = $GetName.sAMAccountName
									$UserList += $Name + ";"
                                    

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
$UserList = $UserList | Out-String


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
