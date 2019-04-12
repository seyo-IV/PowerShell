#------------------------------------------------------------------------ 
# Author: Sergiy Ivanov (Im Auftrag der ECKD Service GmbH) 
# Verwendungszweck: Dieses Script generiert Listen mit effecktiven berechtigungen. 
# Datum: 20.03.2019 
#------------------------------------------------------------------------ 
# Errors  : Verschachtelte Gruppen wurde nicht berücksichtigt. 
# 
# Changes : Verschachtelte Gruppen werden jetzt auch ausgelessen.
# 
#------------------------------------------------------------------------ 
# Variables 
#------------------------------------------------------------------------ 

import-module ActiveDirectory
$i					   = 0
$ErrorActionPreference = "SilentlyContinue"
$PPath                 = Read-Host "Enter Path to scan"
$TestPath			   = Test-Path $PPath
$plist                 = @()
$pathfinder			   = $PPath -split "\\"
$pathfinder 		   = $pathfinder | Select-Object -Last 1
$Folders               = $PPath -Split "\\"
$PathList	           = $Folders | % { $i = 0 } { $Folders[0..$i] -Join "\" -Replace ":$", ":\"; $i++ }
$Plist 				  += $pathlist
$Path                  = "\\SERVER\PATH\Logs\"
$log                   = $Path + "Effective_PermissionsV3_" + $Pathfinder + ".log"
if($TestPath -eq $false)
{
Write-Warning "Path doesen't exist!"
exit
}
Write-Progress -Activity “Scanning Directory” -Status “Scanning” -PercentComplete 50
try
{
$list 	= Get-Childitem -Path $PPath -Recurse | ?{ $_.PSIsContainer } | Select-Object FullName
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

        Resolve-Path -Path $Dir
        Write-Output "`n" | Out-File $log -append
        Write-Output "[#######################################################################]" | Out-File $Log -append
        Get-Item $Dir | select FullName | Out-File $Log -append
#------------------------------------------------------------------------ 
# Collecting ACLs
#------------------------------------------------------------------------
        $AclList 			= Get-Acl -Path $Dir -Filter Access | Select-Object -ExpandProperty Access | Where-Object {$_.IdentityReference -like "Domainprefix\*"} | Select-Object IdentityReference
        Clear-Variable ACLFile
        $ACLFile			= Get-Acl -Path $dir -Filter Access | Select-Object -ExpandProperty Access | Where-Object {$_.IdentityReference -like "Domainprefix\*"} | Select-Object IdentityReference, FileSystemRights
        $ACLGroup 			= $ACLFile | Group-Object IdentityReference
        $Singles 			= $ACLGroup.where({$_.count -eq 1}).group
        $Duplicates 		= $ACLGroup.where({$_.count -gt 1})
        $ItemizedDuplicates = $Duplicates | foreach {
        [pscustomobject][ordered]@{"IdentityReference"=$_.Group.IdentityReference[0]; "FileSystemRights" = $_.Group.FileSystemRights -join ", "}
            }
        @($ItemizedDuplicates,$Singles) | Out-File $log -append
            foreach($Id in $AclList.IdentityReference.Value -replace 'Domainprefix\\')
                {	
				try{$idcheck = get-aduser -identity $id}catch{$idcheck = get-adgroup -identity $id}
				sleep -sec 1
                    if($idcheck.ObjectClass -eq "user")
                        {
                        
                        }
                    else
{
                        if($id -Like "*LocalGroupPrefix*")
                                                    {
                    $GrName  = (Get-ADGroup $id -Properties member | Select-Object -ExpandProperty member | Select -first 1 | %{Get-ADGroup $_}).name
                    $ADGroup = Get-ADGroup $GrName -Properties member | Select-Object -ExpandProperty member
                    Write-Output "`n" | Out-File $Log -append
                   
                   
                    
					Write-Host "`n" | Out-File $log -append
                    Write-Output "Member of $Id : `n" | Out-File $log -append
					$result = $id.length + 12
					$test 	= "-"*$result
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
					$token = Get-ADGroup -Filter {name -eq $id -and GroupScope -eq "DomainLocal"}
					if($token)
					{

					$nestedgroups = Get-ADGroupMember $id | ?{$_.ObjectClass -eq "Group"} | %{Get-ADGroupMember $_ | ?{$_.ObjectClass -eq "Group"}| Select-Object Name}
					foreach($group in $nestedgroups)
					{
                    $check = Get-ADUser -Identity $group
                    $group = $group -replace "@{name=", "" -replace "}"
 
                    #if($check -eq $true){
                    $ADGroup = Get-ADGroup $group -Properties member | Select-Object -ExpandProperty member

                    
                    Write-Host "`n" | Out-File $log -append
                    Write-Output "Member of $group : `n" | Out-File $log -append
					$result = $group.length + 12
					$test 	= "-"*$result
					$test | Out-File $Log -Append
                    foreach ($Object in $ADGroup)
		                {
		                    
                            $GetName	  = Get-ADUser -filter * -SearchBase "$Object"
		                    if($GetName -ne $null)
                                {
                                    
									$Name = $GetName.SamaccountName
									Write-Output $name | Out-File $log -append
                                    

                                }
                                
                                
		                }
                           #}
                           else{}
                           }
						   }
						   else
							{
					$ADGroup = Get-ADGroup $Id -Properties member | Select-Object -ExpandProperty member

                   
                    Write-Host "`n" | Out-File $log -append
                    Write-Output "Member of $Id : `n" | Out-File $log -append
					$result = $id.length + 12
					$test 	= "-"*$result
					$test | Out-File $Log -Append
                    foreach ($Object in $ADGroup)
		                {
		                    
                            $GetName	  = Get-ADUser -filter * -SearchBase "$Object"
		                    if($GetName -ne $null)
                                {
                                    
									$Name = $GetName.SamaccountName
									Write-Output $name | Out-File $log -append
                                    

                                }
                                
                                
		                }
							}
						   }
                        } 
                }

$i++

    }
