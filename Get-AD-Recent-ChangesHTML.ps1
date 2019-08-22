#requires -version 3 -module ActiveDirectory
 <#
 .SYNOPSIS
 Shows recent AD-Group changes and generates a HTML report.

 .PARAMETER Path
 Days past scan.

 .EXAMPLE
 .\Get-AD-Recent-Changes.ps1 -Days 3
 #>
[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[string]$Days
	)

$head = "<style>
td {font-family:candara;width:100px; max-width:300px; background-color:white;}
table {width:100%;}
th {font-family:candara;font-size:14pt;background-color:#9e1981;}
h1 {font-family:candara;font-size:18pt}
p1 {font-family:candara;font-size:9pt}
</style>"
$PPath                 = "\\SERVER\Logs"
$file                  = $PPath + "Recent-Group-Changes.html"
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
$StopWatch=[system.diagnostics.stopwatch]::startNew()
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
      #write-host "Group: "$e.ReplacementStrings[2] "`tAction: Member added `tWhen: "$e.TimeGenerated "`tWho: "$e.ReplacementStrings[6] "`tAccount added: "$e.ReplacementStrings[0]
	  $Group = $e.ReplacementStrings[2] | Out-String
	  $When = $e.TimeGenerated | Out-String
	  $Who = $e.ReplacementStrings[6] | Out-String
	  try{$Account = (Get-ADUser -filter * -SearchBase $e.ReplacementStrings[0]).Name | Out-String}
	  catch{$Account = "User not found"}
	  
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
      #write-host "Group: "$e.ReplacementStrings[2] "`tAction: Member removed `tWhen: "$e.TimeGenerated "`tWho: "$e.ReplacementStrings[6] "`tAccount removed: "$e.ReplacementStrings[0]
	  $Group = $e.ReplacementStrings[2] | Out-String
	  $When = $e.TimeGenerated | Out-String
	  $Who = $e.ReplacementStrings[6] | Out-String
	  try{$Account = (Get-ADUser -filter * -SearchBase $e.ReplacementStrings[0]).Name | Out-String}
	  catch{$Account = "User not found"}
	  
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

$ObjectList | ConvertTo-Html -As table -Head $head -PreContent "<h1>Recent Group Changes</h1>" | Out-File $file
Write-Host "Report generated at $file"