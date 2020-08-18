#requires -version 3 -module ActiveDirectory
<#
.SYNOPSIS
  This script exports Active directory User or Groups to a logfile.
  
.DESCRIPTION
  Export user membership, group membership or group member ot a .log file.
  
.PARAMETER sAMAccountName
  SamAccountName of User or Group.
  
 .PARAMETER Path
 Path to the logs direcotory, without the log file.
    
.INPUTS
  None.
  
.OUTPUTS
  Creates the CSV in the current directory.
  
.NOTES
  Version:        1.0
  Author:         Sergiy Ivanov
  Creation Date:  03.09.2019
  Purpose/Change: Initial script development
  
.EXAMPLE
  Export_GroupList.ps1 -SamAccountName "Perter.Parker" -Path "C:\logs"
#>
 
 [CmdletBinding()]
param(
	[Parameter(Mandatory=$True,
	ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
	[string]$sAMAccountName,
	[Parameter(Mandatory=$True)]
	[string]$Path
	)
$ErrorActionpreference = "SilentlyContinue"
Import-Module ActiveDirectory -ErrorAction Stop

$exist = Get-ADObject -LDAPFilter "(sAMAccountName=$sAMAccountName)"
if(!$exist){
Write-Warning "AD-Object doesen't exist!"
exit
}
If($exist.ObjectClass -eq "user"){
$UOG = "u"
Write-Host "AD-Object is a user (づ￣ ³￣)づ" -ForegroundColor Green
sleep -sec 1
}else{
$Title = "[INFO] Export from"
$Info = "Group=G or GroupMembership=M"
 
$Options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Group", "&Membership")
[int]$DefaultChoice = 0
$Opt =  $host.UI.PromptForChoice($Title , $Info, $Options, $DefaultChoice)

switch($Opt)
{
	
	0 { 
		Write-Host "Group (~˘▾˘)~" -ForegroundColor Green
		sleep -sec 1
		$UOG = "g"
	}

	1 { 
		Write-Host "GroupMembership ~(˘▾˘~)" -ForegroundColor Green 
		sleep -sec 1
		$UOG = "gm"
	}
}
}
 
$Source = $sAMAccountName
$log    = $path + $Source + ".log"


$ErrorActionpreference = "Continue"
		If ($UOG -eq "u")
	{
	$ADUser	= Get-ADUser -Identity $Source -Properties memberof | Select-Object -ExpandProperty memberof
	$Count	= $ADUser.count
	Write-Output "Totalcount $Count" | Out-File $log -append
	Write-Output "$Source is member of" | Out-File $log -append
	$result = $source.length + 13
	$test 	= "-"*$result
	$test | Out-File $Log -Append
	foreach ($Group in $ADUser)
		{
		$Gr			= Get-ADGroup -identity $Group
		$GrNa		= $Gr.samaccountname
		Write-Output "$GrNa" | Out-File $log -append
		}
	}
		If ($UOG -eq "g")
	{
	$ADGroup	= Get-ADGroup -Identity $Source -Properties member | Select-Object -ExpandProperty member
	$Count	= $ADGroup.count
	Write-Output "Totalcount $Count" | Out-File $log -append
	Write-Output "The following user/groups are member of $Source" | Out-File $log -append
	$result = $source.length + 40
	$test 	= "-"*$result
	$test | Out-File $Log -Append

	foreach ($Obj in $ADGroup)
		{
		$error.clear()
		$Gr0		= Get-ADUser -identity $Obj
		if($error -ne "")
			{
			$Gr0	= Get-ADGroup -identity $Obj
			}
		$GrNa0		= $Gr0.samaccountname
		Write-Output "$GrNa0" | Out-File $log -append
		} 
	
	}
		If ($UOG -eq "gm")
	{
	$ADGroupMemo= Get-ADGroup -Identity $Source -Properties memberof | Select-Object -ExpandProperty memberof
	$Count	= $ADGroupMemo.count
	Write-Output "Totalcount $Count" | Out-File $log -append
	Write-Output "$Source is member of" | Out-File $log -append
	$result = $source.length + 13
	$test 	= "-"*$result
	$test | Out-File $Log -Append
	foreach ($Groups in $ADGroupMemo)
		{
		$Gr01		= Get-ADGroup -identity $Groups
		$GrNa01		= $Gr01.samaccountname
		Write-Output "$GrNa01" | Out-File $log -append
		} 
	}
	"[INFO] Export to $log"


	
