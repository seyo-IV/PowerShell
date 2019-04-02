#------------------------------------------------------------------------ 
# Author: Sergiy Ivanov (Im Auftrag der ECKD Service GmbH) 
# Verwendungszweck:  This script generates effective permissions report and exports to html.
# Datum: 20.03.2019 
#------------------------------------------------------------------------ 
# Errors  : Der Fehler bestand in? 
# 
# Changes : Folgendes wurde verändert 
# 
#------------------------------------------------------------------------ 
# Variables 
#------------------------------------------------------------------------ 

$head = "<style>
td {font-family:candara;width:100px; max-width:300px; background-color:white;}
table {width:100%;}
th {font-family:candara;font-size:14pt;background-color:magenta;}
h1 {font-family:candara;font-size:18pt}
p1 {font-family:candara;font-size:9pt}
</style>

<title>Effective Permissions</title>"
import-module ActiveDirectory
$i = 0
$ErrorActionPreference = "SilentlyContinue"
$Path   = "\\Server\Logs\"
$file    = $Path + "Effective_PermissionsV2" + ".html"
$PPath = Read-Host "Enter Path to scan"
$PList = @()
$PList += $PPath
Write-Progress -Activity “Scaning Directory” -Status “Scanning” -PercentComplete 50
try{$plist = Get-Childitem -Path $PPath -Recurse | ?{ $_.PSIsContainer } | Select-Object FullName}
catch {Write-Warning "Enter a correct path"}
Write-Progress -Activity “Scaning Directory” -Status “Complete” -PercentComplete 100


foreach($Dir in $PList)
    {
        

        
        $Dir = $Dir -replace "@{FullName=", "" -replace "}"

        

        Resolve-Path -Path $Dir
        Write-Output "`n" 
        Write-Output "#######################################################################"
        Get-Item $Dir | select FullName
        $AclList = Get-Acl -Path $Dir -Filter Access | Select-Object -ExpandProperty Access | Where-Object {$_.IdentityReference -like "Domain\*"} | Select-Object IdentityReference
        $ACLFile = Get-Acl -Path $dir -Filter Access | Select-Object -ExpandProperty Access | Where-Object {$_.IdentityReference -like "Domain\*"} | Select-Object IdentityReference, FileSystemRights
        
        $ACLGroup = $ACLFile | Group-Object IdentityReference
        $Singles = $ACLGroup.where({$_.count -eq 1}).group
        $Duplicates = $ACLGroup.where({$_.count -gt 1})
        $ItemizedDuplicates = $Duplicates | foreach {
        [pscustomobject][ordered]@{"IdentityReference"=$_.Group.IdentityReference[0]; "FileSystemRights" = $_.Group.FileSystemRights -join ", "}
            }
        $acl = @($ItemizedDuplicates,$Singles)
        



            foreach($Id in $AclList.IdentityReference.Value -replace 'Domain\\')
                {
                    $UserList = @()
                    $idcheck = get-aduser $Id
                    if($IDcheck -eq $true)
                        {
                        
                        }

                    else
                        {
                        if($id -Like "*Local_Group_Prefix*")
                        {
                    
                    $GrName = (Get-ADGroup $id -Properties member | Select-Object -ExpandProperty member | %{Get-ADGroup $_}).name | Select-Object -first 1
                    $ADGroup = Get-ADGroup $GrName -Properties member | Select-Object -ExpandProperty member
                   
                   
                   
                    
                    $UserL += Write-Output "Mitglieder von $Id :"

                    foreach ($Object in $ADGroup)
		                {
		                    $GetName		= Get-ADUser -filter * -SearchBase "$Object"
		                    if($GetName -ne $null)
                                {

                                    $Name	= $GetName.samaccountname
		                            $UserL += $Name + " "
                                    $x++

                                }
                                
                                
		                }

                        }else{

                    $error.clear()
                    $ADGroup = Get-ADGroup $Id -Properties member | Select-Object -ExpandProperty member
                    if($error -ne $null)
                    {
                    $ADUser = (Get-ADUser -identity $id).samaccountname
                    $UserL += $ADUser
                    }
                    else{                

                    $UserL += Write-Output "
                    Mitglieder von $Id :
                    "
 
                    foreach ($Object in $ADGroup)
		                {
		                    
                            $GetName		= Get-ADUser -filter * -SearchBase "$Object"
		                    if($GetName -ne $null)
                                {
                                    
                                    $Name	= $GetName.samaccountname
		                            $UserL += $Name + " "

                                }
                                
                                
		                }
                        }

                           }
                        }


 $userlist += $userl                        
                
                }

$dir = $dir | out-string

Clear-Variable userl
$userlist = $UserList | Out-String
$acl      = $acl | Out-String
$acl      = $acl.Replace("-----------------","")
$acl      = $acl.Replace("----------------","")
$acl      = $acl.Replace("IdentityReference","")
$acl      = $acl.Replace("FileSystemRights","")

$data     = @()
$row      = New-Object PSObject
$row | Add-Member -MemberType NoteProperty -Name "Path" -Value $Dir
$row | Add-Member -MemberType NoteProperty -Name "ACL" -Value $acl
$row | Add-Member -MemberType NoteProperty -Name "User" -Value $userlist
$data    += $row
$alldata += $data 
 
  Write-Progress -Activity “Scaning folders” -Status “On $dir” -PercentComplete ($i / $plist.count*100)
  $i++
   }
Write-host "[INFO]    Exporting List to $file" -ForegroundColor yellow
$alldata | select path, acl, user | ConvertTo-Html -Head $head -PreContent "<h1>Effective Permissions</h1>" | Out-File $file

