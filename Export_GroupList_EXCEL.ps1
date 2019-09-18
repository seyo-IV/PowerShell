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
$Statuses | Export-Excel $xlfile -AutoSize -StartRow 1
