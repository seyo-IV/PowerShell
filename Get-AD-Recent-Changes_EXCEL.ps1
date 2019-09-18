#requires -version 3 -module ActiveDirectory
<#
.SYNOPSIS
  Generate a EXCEL report with recent group changes.
  
.DESCRIPTION
  Show recent groupo changes (Added/Removed).
  
.PARAMETER Path
  Path to scan to.
    
.INPUTS
  None.
  
.OUTPUTS
  "\\SERVER\Logs\Recent_Group-Changes.xlsx"
  
.NOTES
  Version:        1.0
  Author:         Sergiy Ivanov
  Creation Date:  03.09.2019
  Purpose/Change: Initial script development
  
.EXAMPLE
  Get-AD-Recent-Changes_EXCEL.ps1 -Days 5
#>
[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[string]$Days
	)
$ErrorActionPreferance = "SilentlyContinue"
import-module ImportExcel
$PPath                 = "\\SERVER\Share\Logs\"
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

