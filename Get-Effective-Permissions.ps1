$ErrorActionPreference = "SilentlyContinue"
$Path   = "\\Server\Share\Logs\"
$Log    = $Path + "Effective_Permissions" + ".log"
$PPath = Read-Host "Enter Path to scan"
$plist = Get-Childitem -Path $PPath -Recurse | ?{ $_.PSIsContainer } | Select-Object FullName


foreach($Dir in $PList)
    {
        $Dir = $Dir -replace "@{FullName=", "" -replace "}"
        Resolve-Path -Path $Dir
        Write-Output "`n" | Out-File $log -append
        Write-Output "#######################################################################" | Out-File $Log -append
        Get-Item $Dir | select FullName | Out-File $Log -append
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
                    if($ID -Like "*eckdadm*")
                        {
                        
                        }
                    else
                        {
                    $ADGroup = Get-ADGroup $Id -Properties member | Select-Object -ExpandProperty member
                    Write-Output "`n" | Out-File $Log -append
                    Write-Output "Member of $Id `n
---------------------------------" | Out-File $Log -append
                    foreach ($Object in $ADGroup)
		                {
		                    $Group		= Get-ADUser -filter * -SearchBase "$Object"
		                    if($Group -ne $null)
                                {
                                    $GrName		= $Group.Name
		                            Write-Output "$GrName" | Out-File $Log -append
                                }
		                }
                        } 
                }
Clear-Variable Object, Group, ADGroup, ACLList, GRName, Id
