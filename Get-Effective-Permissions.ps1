#------------------------------------------------------------------------ 
# Author: Sergiy Ivanov (Im Auftrag der ECKD Service GmbH) 
# Verwendungszweck: This script generaes an effectie permissions report. 
# Datum: 20.03.2019 
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
$Path                  = "\\Server\Logs\"
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
    try{
        Resolve-Path -Path $Dir
        Write-Output "`n" | Out-File $log -append
        Write-Output "#######################################################################" | Out-File $Log -append
        Get-Item $Dir | select FullName | Out-File $Log -append
#------------------------------------------------------------------------ 
# Collecting ACLs
#------------------------------------------------------------------------
        $AclList = Get-Acl -Path $Dir -Filter Access | Select-Object -ExpandProperty Access | Where-Object {$_.IdentityReference -like "Domain\*"} | Select-Object IdentityReference
        Clear-Variable ACLFile
        $ACLFile = Get-Acl -Path $dir -Filter Access | Select-Object -ExpandProperty Access | Where-Object {$_.IdentityReference -like "Domain\*"} | Select-Object IdentityReference, FileSystemRights
        $ACLGroup = $ACLFile | Group-Object IdentityReference
        $Singles = $ACLGroup.where({$_.count -eq 1}).group
        $Duplicates = $ACLGroup.where({$_.count -gt 1})
        $ItemizedDuplicates = $Duplicates | foreach {
        [pscustomobject][ordered]@{"IdentityReference"=$_.Group.IdentityReference[0]; "FileSystemRights" = $_.Group.FileSystemRights -join ", "}
            }
        @($ItemizedDuplicates,$Singles) | Out-File $log -append
            foreach($Id in $AclList.IdentityReference.Value -replace 'Domain\\')
                {
                    if($ID -Like "*adminprefix*" -or $ID -like "*excluded_service_user*")
                        {
                        
                        }
                    else
{
                        if($id -Like "*Local_Group_Prefix*")
                                                    {
                     $GrName = (Get-ADGroup $id -Properties member | Select-Object -ExpandProperty member | Select -first 1 | %{Get-ADGroup $_}).name
                    $ADGroup = Get-ADGroup $GrName -Properties member | Select-Object -ExpandProperty member
                    Write-Output "`n" | Out-File $Log -append
                   
                   
                    
					Write-Host "`n" | Out-File $log -append
                    Write-Output "Mitglieder von $Id : `n" | Out-File $log -append
					$result = $id.length + 17
					$test = "-"*$result
					$test | Out-File $Log -Append
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
                    Write-Output "Mitglieder von $Id : `n" | Out-File $log -append
					$result = $id.length + 17
					$test = "-"*$result
					$test | Out-File $Log -Append
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
Write-Progress -Activity “Scaning folders” -Status “On $dir” -PercentComplete ($i / $plist.count*100)
$i++
    }catch{$i++}
    }
