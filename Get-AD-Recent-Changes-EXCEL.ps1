#requires -version 3 -module ActiveDirectory, NTFSSecurity, ImportExcel
 <#
 .SYNOPSIS
 Generates an EXCEL-based permission report.

 .PARAMETER Path
 Path to scan.

 .EXAMPLE
 .\Effective_Permissions_EXCEL.ps1 -Path "\\Server\share"
 #>
[CmdletBinding()]
param(
	[Parameter(Mandatory=$True,
	ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
	[string]$Path
	)

try{
import-module ActiveDirectory
Import-Module NTFSSecurity
Import-Module ImportExcel
}
catch
{ 
  Write-Host "[ERROR]`t  Module couldn't be loaded. Script will stop! $($_.Exception.Message)" 
  Exit 1 
}
$ObjectList =  @()
$PList = @()
$ErrorActionPreference = "SilentlyContinue"
$plist                 = @()
$Pathfinder			   = $Path -split "\\"
$Pathfinder 		   = $Pathfinder | Select-Object -Last 1
$tpPath = Test-Path $Path
if(!$tpPath){return "Path does not exist"
exit
}
$DirList 	= (Get-Childitem -Path $Path -Recurse -Depth 3 | ?{ $_.PSIsContainer }).FullName
$Plist += $Path
$PList += $DirList
$i = 1
#------------------------------------------------------------------------ 
# Foreach Loop 
#------------------------------------------------------------------------
foreach($Dir in $PList)
    {
    Write-Host "on dir $i of $($Plist.count)"
    if($true){
#------------------------------------------------------------------------ 
# Collecting ACLs
#------------------------------------------------------------------------
        $ACLList = Get-NTFSAccess -Path $dir | Where-Object {$_.Account -like "DOMAIN\*"} | select AccessRights, Account
            foreach($ID in $ACLList)
                {
					$UID = $ID.Account.AccountName -replace "DOMAIN\\"
					$Account = $ID.Account.AccountName
					$AccessRight = $ID.AccessRights
                    $UIDcheck = Get-ADObject -LDAPFilter "(sAMAccountName=$UID)"
				    sleep -sec 1
                    if($UIDcheck.ObjectClass -eq "user")
                        {
$data     = @()
$list = New-Object PSCustomObject
$list | Add-Member -type NoteProperty -Name Path -value $dir
$list | Add-Member -type NoteProperty -Name Account -value $Account
$list | Add-Member -type NoteProperty -Name AccessRight -value $AccessRight
$list | Add-Member -type NoteProperty -Name User -value $UID
$data += $list
$ObjectList += $data
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

$data     = @()
$list = New-Object PSCustomObject
$list | Add-Member -type NoteProperty -Name Path -value $dir
$list | Add-Member -type NoteProperty -Name Account -value $Account
$list | Add-Member -type NoteProperty -Name AccessRight -value $AccessRight
$list | Add-Member -type NoteProperty -Name User -value $GetName.SamAccountName
$data += $list
$ObjectList += $data
									
                                }
                                
                                
		                }
							}else{
					$token = Get-ADGroup -Filter {name -eq $UID -and GroupScope -eq "DomainLocal"}
					if($token)
					{

					$nestedgroups = Get-ADGroupMember $id | ?{$_.ObjectClass -eq "Group"} | %{(Get-ADGroupMember $_ | ?{$_.ObjectClass -eq "Group"}).name}
					foreach($group in $nestedgroups)
					{
                   
                    
 
                    
                    $ADGroup = Get-ADGroup $group -Properties member | Select-Object -ExpandProperty member

                    foreach ($Object in $ADGroup)
		                {
		                    
                            $GetName	  = Get-ADUser -filter * -SearchBase "$Object"
		                    if($GetName -ne $null)
                                {
                                    

$data     = @()
$list = New-Object PSCustomObject
$list | Add-Member -type NoteProperty -Name Path -value $dir
$list | Add-Member -type NoteProperty -Name Account -value $Account
$list | Add-Member -type NoteProperty -Name AccessRight -value $AccessRight
$list | Add-Member -type NoteProperty -Name User -value $GetName.SamAccountName
$data += $list
$ObjectList += $data

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
                                    

$data     = @()
$list = New-Object PSCustomObject
$list | Add-Member -type NoteProperty -Name Path -value $dir
$list | Add-Member -type NoteProperty -Name Account -value $Account
$list | Add-Member -type NoteProperty -Name AccessRight -value $AccessRight
$list | Add-Member -type NoteProperty -Name User -value $GetName.SamAccountName
$data += $list
$ObjectList += $data
                                    

                                }
                                
                                
		                }
							}
								}
                        } 

                 }
}
$i++
}



$xlfile = "\\SERVER\Logs\Effective_Permissions_$Pathfinder.xlsx"
Remove-Item $xlfile -ErrorAction SilentlyContinue

#
$ObjectList  | Export-Excel $xlfile -AutoSize -StartRow 1 -TableName NTFSReport
