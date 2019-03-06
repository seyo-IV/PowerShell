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
        Get-Acl -Path $dir -Filter Access | Select-Object -ExpandProperty Access | Where-Object {$_.IdentityReference -like "Domain\*"} | Out-File $Log -append
            foreach($Id in $AclList.IdentityReference.Value -replace 'Domain\\')
                {
                    $ADGroup = Get-ADGroup $Id -Properties member | Select-Object -ExpandProperty member
                    Write-Output "`n" | Out-File $Log -append
                    Write-Output "Member of $Id `n
---------------------------------" | Out-File $Log -append
                    foreach ($Object in $ADGroup)
                        {
                            $Group      = Get-ADUser -filter * -SearchBase "$Object"
                            if($Group -ne $null)
                                {
                                    $GrName     = $Group.Name
                                    Write-Output "$GrName" | Out-File $Log -append
                                }
                        } 
                }
Clear-Variable Obj, Object, Group, ADGroup, ACLList, GRName, Id
    }
