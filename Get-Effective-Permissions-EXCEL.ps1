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

$ErrorActionPreference = "SilentlyContinue"
$plist                 = @()
$Pathfinder			   = $Path -split "\\"
$Pathfinder 		   = $Pathfinder | Select-Object -Last 1
$Folders               = $Path -Split "\\"
$PathList	           = $Folders | % { $i = 0 } { $Folders[0..$i] -Join "\" -Replace ":$", ":\"; $i++ }
$Plist 				  += $Pathlist
$Domain = $env:UserDomain
$tpPath = Test-Path $Path
if(!$tpPath){return "Path does not exist"
exit
}
$list 	= Get-Childitem -Path $Path -Recurse -Depth 3 | ?{ $_.PSIsContainer } | Select-Object FullName
$list 	= $list.fullname
$Plist += $list

$Plist = $plist | select -Skip 2

#------------------------------------------------------------------------ 
# Foreach Loop 
#------------------------------------------------------------------------
foreach($Dir in $PList)
    {
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
}



$xlfile = "\\SERVER\LOGS\Effective_Permissions_$Pathfinder.xlsx"
Remove-Item $xlfile -ErrorAction SilentlyContinue

#
$ObjectList  | Export-Excel $xlfile -AutoSize -StartRow 1 -TableName NTFS-Report

# SIG # Begin signature block
# MIIFlQYJKoZIhvcNAQcCoIIFhjCCBYICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUg1e+z/2ex5VMUsY/08o96xQm
# FZqgggMtMIIDKTCCAhGgAwIBAgIQWviwIlKt/7RD/9IU14pH1DANBgkqhkiG9w0B
# AQsFADAdMRswGQYDVQQDDBJzZXlvQHNleW8taXYuc3BhY2UwHhcNMTkwODI3MTIy
# ODAxWhcNMjAwODI3MTI0ODAxWjAdMRswGQYDVQQDDBJzZXlvQHNleW8taXYuc3Bh
# Y2UwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC0M9S8iRqj9zGV9oOf
# emPZpNi4m9aXdufPGuyxJ5B2rC69enarHqq5w42AISSrm0KxH2oVW0b9d8e9DPpr
# 9ZiwbXsCBVquCX/RwiqE4JO/e9EV9HisCPtnJ94vWPO/QV0AsStlT+NbcvJmH82y
# O6L33kpEHZSHtmtJAQ5yZSOdAcHR42hxgSIM/98LKJFb9yfDw2iv0bhn8LhJQJGJ
# 2nSQNnNxe5e0hZni09aoY4CfGXaGLioDodSO5YE1f3AUmc25Hkn43EICw0XQtwW9
# E6Im0LuT8Sdfs+Hw5whV22b7Uh1itgrUmxGX7/dgVKSCoDBbLCIQbTHoGJlZ/KuD
# r1TVAgMBAAGjZTBjMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcD
# AzAdBgNVHREEFjAUghJzZXlvQHNleW8taXYuc3BhY2UwHQYDVR0OBBYEFNslvuyG
# XgWh8jmjHd+I5NWZ6DTdMA0GCSqGSIb3DQEBCwUAA4IBAQBvUDHUGG5UDRxqpO68
# ZJCyY24onM5GafluYJXFBLt8lhnISjF2eYJsxuQb1YyTiD1LXI+aSTnfwC3oXtnw
# SY1j/y6QLNA65Zzg96/kRSoCiI0+5ywrRqtEcWL9xJxXyLSVLqW9fIOleQ/gCCE1
# 6jY84Mf/2fz3S+hwURaYOWuouoBu2dAPQOmtZ1UThwCTTkUQRIH3P1ijTVPgDUaD
# lvEoI0dFlw97bL6lUH9Ei3Fm4hI3DBH88sXRdD1LnqMP5k+ugnX1RBLktPbM6Hzn
# EPfo6MLPbjhVJZ9un/j0mjr3j04o07cJAuU3FgIuCCentbkz1d+YVuVmuB8sgLXh
# vmNiMYIB0jCCAc4CAQEwMTAdMRswGQYDVQQDDBJzZXlvQHNleW8taXYuc3BhY2UC
# EFr4sCJSrf+0Q//SFNeKR9QwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAI
# oAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIB
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFBM95XXmAw9C6juIKrXg
# uo+T1eaRMA0GCSqGSIb3DQEBAQUABIIBAE9Kzp4cG2/JscTqpmCQniHbs3MSdDrs
# +B6tyBQFAof/OCVaFQJShEyzPk2LpAOBK+IY8lwXjmtVFjfCRJTynTkds10VZVHM
# ybOrYbTu2UvZBWqiUKo9mkFVGF2F+pRyGAmKVmq2K5OZjTPSZVpA66asR2LUwU4x
# ZAkyo06kT3GWTrBuv0d5a/JiL9jiMJxix+7WRavDzzqdvzYieklxXnnwoHYVAnKN
# qj3ldz6iPfdf1uuQieq72U+CQx88ki+6jImABPcuCZUGeyB6RdZaqPfikHKaX3oz
# 10pSE4SIDc70sxR9oQ0OgGLI5CUp0gDGyeMP5GznMTcSnmTTfXTWJb0=
# SIG # End signature block
