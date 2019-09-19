#requires -version 3 -module ActiveDirectory, NTFSSecurity
 <#
 .SYNOPSIS
 Generates an HTML-based permission report.

 .PARAMETER Path
 Path to scan.

 .EXAMPLE
 .\Effective_Permissions_HTMLv2.ps1 -Path "\\Server\share"
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
}
catch
{ 
  Write-Host "[ERROR]`t  Module couldn't be loaded. Script will stop! $($_.Exception.Message)" 
  Exit 1 
}
function Get-ADNestedGroupMembers { 
<#  
.SYNOPSIS
Author: Piotr Lewandowski
Version: 1.01 (04.08.2015) - added displayname to the output, changed name to samaccountname in case of user objects.

.DESCRIPTION
Get nested group membership from a given group or a number of groups.

Function enumerates members of a given AD group recursively along with nesting level and parent group information. 
It also displays if each user account is enabled. 
When used with an -indent switch, it will display only names, but in a more user-friendly way (sort of a tree view) 
   
.EXAMPLE   
Get-ADNestedGroupMembers "MyGroup" | Export-CSV .\NedstedMembers.csv -NoTypeInformation

.EXAMPLE  
Get-ADGroup "MyGroup" | Get-ADNestedGroupMembers | ft -autosize
            
.EXAMPLE             
Get-ADNestedGroupMembers "MyGroup" -indent
 
#>

param ( 
[Parameter(ValuefromPipeline=$true,mandatory=$true)][String] $GroupName, 
[int] $nesting = -1, 
[int]$circular = $null, 
[switch]$indent 
) 
    function indent  
    { 
    Param($list) 
        foreach($line in $list) 
        { 
        $space = $null 
         
            for ($i=0;$i -lt $line.nesting;$i++) 
            { 
            $space += "    " 
            } 
            $line.name = "$space" + "$($line.name)"
        } 
      return $List 
    } 
     
$modules = get-module | select -expand name
    if ($modules -contains "ActiveDirectory") 
    { 
        $table = $null 
        $nestedmembers = $null 
        $adgroupname = $null     
        $nesting++   
        $ADGroupname = get-adgroup $groupname -properties memberof,members 
        $memberof = $adgroupname | select -expand memberof 
        write-verbose "Checking group: $($adgroupname.name)" 
        if ($adgroupname) 
        {  
            if ($circular) 
            { 
                $nestedMembers = Get-ADGroupMember -Identity $GroupName -recursive 
                $circular = $null 
            } 
            else 
            { 
                $nestedMembers = Get-ADGroupMember -Identity $GroupName | sort objectclass -Descending
                if (!($nestedmembers))
                {
                    $unknown = $ADGroupname | select -expand members
                    if ($unknown)
                    {
                        $nestedmembers=@()
                        foreach ($member in $unknown)
                        {
                        $nestedmembers += get-adobject $member
                        }
                    }

                }
            } 
 
            foreach ($nestedmember in $nestedmembers) 
            { 
                $Props = @{Type=$nestedmember.objectclass;Name=$nestedmember.name;DisplayName="";ParentGroup=$ADgroupname.name;Enabled="";Nesting=$nesting;DN=$nestedmember.distinguishedname;Comment=""} 
                 
                if ($nestedmember.objectclass -eq "user") 
                { 
                    $nestedADMember = get-aduser $nestedmember -properties enabled,displayname 
                    $table = new-object psobject -property $props 
                    $table.enabled = $nestedadmember.enabled
                    $table.name = $nestedadmember.samaccountname
                    $table.displayname = $nestedadmember.displayname
                    if ($indent) 
                    { 
                    indent $table | select @{N="Name";E={"$($_.name)  ($($_.displayname))"}}
                    } 
                    else 
                    { 
                    $table | select type,name,displayname,parentgroup,nesting,enabled,dn,comment 
                    } 
                } 
                elseif ($nestedmember.objectclass -eq "group") 
                {  
                    $table = new-object psobject -Property $props 
                     
                    if ($memberof -contains $nestedmember.distinguishedname) 
                    { 
                        $table.comment ="Circular membership" 
                        $circular = 1 
                    } 
                    if ($indent) 
                    { 
                    indent $table | select name,comment | %{
						
						if ($_.comment -ne "")
						{
						[console]::foregroundcolor = "red"
						write-output "$($_.name) (Circular Membership)"
						[console]::ResetColor()
						}
						else
						{
						[console]::foregroundcolor = "yellow"
						write-output "$($_.name)"
						[console]::ResetColor()
						}
                    }
					}
                    else 
                    { 
                    $table | select type,name,displayname,parentgroup,nesting,enabled,dn,comment 
                    } 
                    if ($indent) 
                    { 
                       Get-ADNestedGroupMembers -GroupName $nestedmember.distinguishedName -nesting $nesting -circular $circular -indent 
                    } 
                    else  
                    { 
                       Get-ADNestedGroupMembers -GroupName $nestedmember.distinguishedName -nesting $nesting -circular $circular 
                    } 
              	                  
               } 
                else 
                { 
                    
                    if ($nestedmember)
                    {
                        $table = new-object psobject -property $props
                        if ($indent) 
                        { 
    	                    indent $table | select name 
                        } 
                        else 
                        { 
                        $table | select type,name,displayname,parentgroup,nesting,enabled,dn,comment    
                        } 
                     }
                } 
              
            } 
         } 
    } 
    else {Write-Warning "Active Directory module is not loaded"}        
}

$Domain = $env:UserDomain
$ObjectList =  @()
$PList = @()
$ErrorActionPreference = "SilentlyContinue"
$plist                 = @()
$Pathfinder			   = $Path -split "\\"
$Pathfinder 		   = $Pathfinder | Select-Object -Last 1
$tpPath = Test-Path $Path
if(!$tpPath){
return "Path does not exist"
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
        $ACLList = Get-NTFSAccess -Path $dir | Where-Object {$_.Account -like "$Domain\*"} | select AccessRights, Account
            foreach($ID in $ACLList)
                {
					$UID = $ID.Account.AccountName -replace "$Domain\\"
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
                    $GrName  = Get-ADNestedGroupMembers -GroupName $UID
                    foreach($item in $GrName){
					if($item.type -eq "user"){
					$data     = @()
					$list = New-Object PSCustomObject
					$list | Add-Member -type NoteProperty -Name Path -value $dir
					$list | Add-Member -type NoteProperty -Name Account -value $Account
					$list | Add-Member -type NoteProperty -Name AccessRight -value $AccessRight
					$list | Add-Member -type NoteProperty -Name User -value $item.Name
					$data += $list
					$ObjectList += $data
					}
					}
							}else{
					$token = Get-ADGroup -Filter {name -eq $UID -and GroupScope -eq "DomainLocal"}
					if($token)
					{
                    $GrName  = Get-ADNestedGroupMembers -GroupName $UID
                    foreach($item in $GrName){
					if($item.type -eq "user"){
					$data     = @()
					$list = New-Object PSCustomObject
					$list | Add-Member -type NoteProperty -Name Path -value $dir
					$list | Add-Member -type NoteProperty -Name Account -value $Account
					$list | Add-Member -type NoteProperty -Name AccessRight -value $AccessRight
					$list | Add-Member -type NoteProperty -Name User -value $item.Name
					$data += $list
					$ObjectList += $data
					}
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



$xlfile = "\\SOMESERVER\SHARE\Effective_Permissions_$Pathfinder.xlsx"
Remove-Item $xlfile -ErrorAction SilentlyContinue

#
$ObjectList  | Export-Excel $xlfile -AutoSize -StartRow 1 -TableName NTFSReport
