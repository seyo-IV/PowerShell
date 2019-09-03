#requires -version 3 -module ActiveDirectory
<#
.SYNOPSIS
  Generate a EXCEL report with removed or added groups of all user for x days.
  
.DESCRIPTION
  Show removed or added groups for all users in x days.
  
.PARAMETER Days
  Days to scan.
    
.INPUTS
  None.
  
.OUTPUTS
  "\\SERVER\Logs\Recent-Group-Changes.xlsx"
  
.NOTES
  Version:        1.0
  Author:         Sergiy Ivanov
  Creation Date:  03.09.2019
  Purpose/Change: Initial script development
  
.EXAMPLE
  Get-AD-Recent-Changes-HTML.ps1 -Days 10
#>
[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[string]$Days
	)
$ErrorActionPreferance = "SilentlyContinue"
import-module ImportExcel
$PPath                 = "\\egvfs02\it$\Scriptrepository\Logs\"
$file                  = $PPath + "Recent_Group-Changes.xlsx"
$tpFile = Test-Path $file
if($tpFile){
Remove-item $file
}
$ObjectList =  @()
Write-Host -ForegroundColor Yellow "This may take some time..."
# Get domain controllers list
$DCs = Get-ADDomainController -Filter *
 
# Define timeframe for report (default is 1 day)
$startDate = (get-date).AddDays(-$days)
$x = 0
# Store group membership changes events from the security event logs in an array.
foreach ($DC in $DCs){

Write-Progress -Id 1 -Activity “Scanning DCs” -Status “On $DC” -PercentComplete ($x / $DCs.count*100) 
$events = Get-Eventlog -LogName Security -ComputerName $DC.Hostname -after $startDate | where {$_.eventID -eq 4728 -or $_.eventID -eq 4729}
$x++
}
 
# Loop through each stored event; print all changes to security global group members with when, who, what details.
 $i = 0
  foreach ($e in $events){
	Write-Progress -ParentId 1 -Activity “Scanning Events” -Status “On $e” -PercentComplete ($i / $events.count*100) 

 # Member Added to Group
 
    if (($e.EventID -eq 4728 )){
      
	  $Group = $e.ReplacementStrings[2] | Out-String
	  $When = $e.TimeGenerated | Out-String
	  $Who = $e.ReplacementStrings[6] | Out-String
	  try{$Account = (Get-ADUser -Identity $e.ReplacementStrings[0]).Name | Out-String}catch{$Account = "User not found!" | Out-String}
	  
	$data     = @()
	$list = New-Object PSCustomObject
	$list | Add-Member -type NoteProperty -Name Group -value $Group
	$list | Add-Member -type NoteProperty -Name Action -value "Added"
	$list | Add-Member -type NoteProperty -Name When -value $When
	$list | Add-Member -type NoteProperty -Name Who -value $Who
	$list | Add-Member -type NoteProperty -Name Account -value $Account
	$data += $list
	$ObjectList += $data
    }
    # Member Removed from Group
    if (($e.EventID -eq 4729 )) {
      
	  $Group = $e.ReplacementStrings[2] | Out-String
	  $When = $e.TimeGenerated | Out-String
	  $Who = $e.ReplacementStrings[6] | Out-String
	  try{$Account = (Get-ADUser -Identity $e.ReplacementStrings[0]).Name | Out-String}catch{$Account = "User not found!" | Out-String}
	  
	$data     = @()
	$list = New-Object PSCustomObject
	$list | Add-Member -type NoteProperty -Name Group -value $Group
	$list | Add-Member -type NoteProperty -Name Action -value "Removed"
	$list | Add-Member -type NoteProperty -Name When -value $When
	$list | Add-Member -type NoteProperty -Name Who -value $Who
	$list | Add-Member -type NoteProperty -Name Account -value $Account
	$data += $list
	$ObjectList += $data
    }
	$i++
	}

$xlfile = $file
Remove-Item $xlfile -ErrorAction SilentlyContinue

#
$ObjectList | Export-Excel $xlfile -AutoSize -StartRow 1

# SIG # Begin signature block
# MIIFlQYJKoZIhvcNAQcCoIIFhjCCBYICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCyuCR79NKMtihYUZ1JRvQsQF
# JZmgggMtMIIDKTCCAhGgAwIBAgIQWviwIlKt/7RD/9IU14pH1DANBgkqhkiG9w0B
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
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFNmeN71PIm8sSq6S8HrF
# uZAcDrNtMA0GCSqGSIb3DQEBAQUABIIBAEYt/jakpye0JRfXulEzcMG5Xma5wJAn
# p8nx3fPfMuDVcTC1zCnmBIX6dRGwk3+cs3zdrXTSS9ioyZg7ZqL6KeakD9aQYr2n
# WwzePALWnIm0QLSu/AMdvV8FuPsy1eiCCawjE6UPZ9AO0+aTiUwT0gwmzSSMxyDc
# FR+L9ThEdun074hqTFXhdSyFOUJI9TYsyOW8BnjzB+vXFTqkly6TdYPpZZvl39xE
# P14sNxbugpZ23QS5/IDxgHrlhy//cJAlZDeG3jYsfJw0sm6QzIDkc2tNNdQDDFYO
# zorP3u8mpSDkUOKphrDuCXZKnRIBMXwx5On8+82Aq9ktvKsnKZtH9wI=
# SIG # End signature block
