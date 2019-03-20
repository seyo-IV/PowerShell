#------------------------------------------------------------------------ 
# Author: Sergiy Ivanov (Im Auftrag der ECKD Service GmbH) 
# Verwendungszweck: Dieses Script generiert Listen mit effecktiven berechtigungen. 
# Datum: 20.03.20189 
#------------------------------------------------------------------------ 
# Errors  : Der Fehler bestand in? 
# 
# Changes : Folgendes wurde verändert 
# 
#------------------------------------------------------------------------ 
# Variables 
#------------------------------------------------------------------------ 

import-module ActiveDirectory
$i = 0
$ErrorActionPreference = "SilentlyContinue"
$Path                  = "\\SERVER\Logs\"
$log                  = $Path + "Effective_PermissionsV2" + ".log"
$PPath                 = Read-Host "Enter Path to scan"

$plist                 = @()
$Folders               = $PPath -Split "\\"
$PathList	           = $Folders | % { $i = 0 } { $Folders[0..$i] -Join "\" -Replace ":$", ":\"; $i++ }
$Plist += $pathlist
Write-Progress -Activity “Scaning Directory” -Status “Scanning” -PercentComplete 50
try
{
$list = Get-Childitem -Path $PPath -Recurse | ?{ $_.PSIsContainer } | Select-Object FullName
$list = $list.fullname
$Plist += $list
}
catch {Write-Warning "Enter a correct path"}
Write-Progress -Activity “Scaning Directory” -Status “Complete” -PercentComplete 100






#------------------------------------------------------------------------ 
# Foreach Loop 
#------------------------------------------------------------------------
foreach($Dir in $PList)
    {
    $UserList = @()
    try{
        #$Dir = $Dir -replace "@{FullName=", "" -replace "}"
        Resolve-Path -Path $Dir
        Write-Output "`n" | Out-File $log -append
        Write-Output "#######################################################################" | Out-File $Log -append
        Get-Item $Dir | select FullName | Out-File $Log -append
#------------------------------------------------------------------------ 
# Collecting ACLs
#------------------------------------------------------------------------
        $AclList = Get-Acl -Path $Dir -Filter Access | Select-Object -ExpandProperty Access | Where-Object {$_.IdentityReference -like "DOMAINPREFIX\*"} | Select-Object IdentityReference
        Clear-Variable ACLFile
        $ACLFile = Get-Acl -Path $dir -Filter Access | Select-Object -ExpandProperty Access | Where-Object {$_.IdentityReference -like "DOMAINPREFIX\*"} | Select-Object IdentityReference, FileSystemRights
        $ACLGroup = $ACLFile | Group-Object IdentityReference
        $Singles = $ACLGroup.where({$_.count -eq 1}).group
        $Duplicates = $ACLGroup.where({$_.count -gt 1})
        $ItemizedDuplicates = $Duplicates | foreach {
        [pscustomobject][ordered]@{"IdentityReference"=$_.Group.IdentityReference[0]; "FileSystemRights" = $_.Group.FileSystemRights -join ", "}
            }
        @($ItemizedDuplicates,$Singles) | Out-File $log -append
            foreach($Id in $AclList.IdentityReference.Value -replace 'DOMAINPREFIX\\')
                {
                    $idcheck = get-aduser $Id #ignore all users
                    if($IDcheck -eq $true)
                        {
                        
                        }
                    else
{
                        if($id -Like "*Local_Group_prefix*")
                                                    {
                    $GrName = (Get-ADGroup $id -Properties member | Select-Object -ExpandProperty member | %{Get-ADGroup $_}).name
                    $ADGroup = Get-ADGroup $GrName -Properties member | Select-Object -ExpandProperty member
                    Write-Output "`n" | Out-File $Log -append
                   
                   
                    
					Write-Host "`n" | Out-File $log -append
                    Write-Output "Member of $Id : `n
-----------------------------"
                    foreach ($Object in $ADGroup)
		                {
		                    $GetName		= Get-ADUser -filter * -SearchBase "$Object"
		                    if($GetName -ne $null)
                                {
									$Name = $GetName.SamaccountName
									Write-Output $name | Out-File $log -append
                                }
                                
                                
		                }
                        }else{


                    $ADGroup = Get-ADGroup $Id -Properties member | Select-Object -ExpandProperty member

                   
                    Write-Host "`n" | Out-File $log -append
                    Write-Output "Member of $Id : `n
-----------------------------" | Out-File $log -append
                    foreach ($Object in $ADGroup)
		                {
		                    
                            $GetName		= Get-ADUser -filter * -SearchBase "$Object"
		                    if($GetName -ne $null)
                                {
                                    
									$Name = $GetName.SamaccountName
									Write-Output $name | Out-File $log -append
                                    

                                }
                                
                                
		                }
                           }
                        } 
                }
#Clear-Variable Object, Group, ADGroup, ACLList, ACLFile, ACLGroup, Name, Id
$i++
Write-Progress -Activity “Scaning folders” -Status “On $dir” -PercentComplete ($i / $plist.count*100)
    }catch{$i++}
    }
