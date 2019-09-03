#requires -version 3 -module ActiveDirectory, ImportExcel
<#
.SYNOPSIS
  This script exports Active directory User or Groups to a EXCEL file.
  
.DESCRIPTION
  Export user membership, group membership or group member ot a .xlsx file.
  
.PARAMETER LogName
  Name for the EXCEL file.
  
 .PARAMETER ListPath
 Path to textfile with the group names. Default is current directory.
    
.INPUTS
  None.
  
.OUTPUTS
  \\SERVER\$logname.xlsx
  
.NOTES
  Version:        1.0
  Author:         Sergiy Ivanov
  Creation Date:  03.09.2019
  Purpose/Change: Initial script development
  
.EXAMPLE
  Export_GroupList.ps1 -LogName "Export_groups" -ListPath "C:\logs\groups.txt"
#>

[CmdletBinding()]
param(

	[Parameter(Mandatory=$True,
	ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
	[string]$ListPath = $PWD,
	[Parameter(Mandatory=$True,
	ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
	[string]$LogName
	)
	
	$statuses = @()
	
	$groups = Get-Content $ListPath
    

    foreach ($group in $groups)
    {
    
	$ADGroup	= Get-ADGroup -Identity $group -Properties member | Select-Object -ExpandProperty member

	foreach ($Obj in $ADGroup)
		{
		$error.Clear()
		try{$GroupObject	= Get-ADUser -Filter * -SearchBase $Obj -Properties *}
        catch{$GroupObject	= Get-ADGroup -Filter * -SearchBase $Obj -Properties *}
			
		$GrName		= Get-ADUser -Identity $GroupObject.samaccountname -Properties *
		
		$sam = $GrName.SamAccountname
        $DN  = $GrName.DisplayName
            
            
                $status = New-Object PSCustomObject -Property @{
                "GroupName"=$group;
                "SamAccountName"=$sam;
                "DisplayName"=$DN;}

                $statuses += $status

    	}
        
        
                
            
        
    }

$xlfile = "\\SERVER\Logs\Export\$LogName.xlsx"
Remove-Item $xlfile -ErrorAction SilentlyContinue

# 
$Statuses | Export-Excel $xlfile -AutoSize -StartRow 2 -TableName ReportProcess
# SIG # Begin signature block
# MIIFlQYJKoZIhvcNAQcCoIIFhjCCBYICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3dIrr1FjwG0WZEMlJ4bw6xeU
# D4igggMtMIIDKTCCAhGgAwIBAgIQWviwIlKt/7RD/9IU14pH1DANBgkqhkiG9w0B
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
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFJbXmeR0J8OLC6TdJUL3
# L3smhYMXMA0GCSqGSIb3DQEBAQUABIIBADzyTlrFvFdm7+t5uvXL2lvLUZkjHrvW
# DTHdP+wIv255KAmOSQMqbc3x9WKoNLRUPJ3FYwJG97Kz/jdqXI5ll/IhYkt+hDf4
# gFbPkk9/7zIlZYdc4fyvDui5LYM9riPT7PnUuuCtuLQsF+fz2WulQ22iX4A27IVo
# nTNOCU9A8HS8tJlhC4L7U+rhw6W7mCp2kxfZjGwmbn9W0J9QvuXhW3rLvmz5n3e7
# lrbuW44eKXXnVUznVwWFMaayi5Cnwi8JoCbzmCY5jo53EB+TwqRTDQORCpyUNXha
# AOqGUOMxEKKQ1knBkTUntES427GbveoUchyP6gZdUB5K1I4Wvla9ZSM=
# SIG # End signature block
