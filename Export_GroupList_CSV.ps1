#requires -version 3 -module ActiveDirectory
<#
.SYNOPSIS
  This script exports Active directory User or Groups to a CSV.
  
.DESCRIPTION
  Export user membership, group membership or group member ot a .CSV file.
  
.PARAMETER LogName
  Name for the CSV file.
  
 .PARAMETER Path
 Path to textfile with the group names.
    
.INPUTS
  None.
  
.OUTPUTS
  \\SERVER\$logname.csv
  
.NOTES
  Version:        1.0
  Author:         Sergiy Ivanov
  Creation Date:  03.09.2019
  Purpose/Change: Initial script development
  
.EXAMPLE
  Export_GroupList.ps1 -LogName "Export_groups" -Path "C:\logs\groups.txt"
#>
[CmdletBinding()]
param(
	[Parameter(Mandatory=$True,
	ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
	[string]$LogName,
	[Parameter(Mandatory=$True)]
	[string]$Path
	)
	
	$statuses = @()
	
    $groups = cat $Path
    $splitter = [regex]"\s+"

    foreach ($group in $groups)
    {
    
	$ADGroup	= Get-ADGroup -Identity $group -Properties member | Select-Object -ExpandProperty member

	foreach ($Obj in $ADGroup)
		{
		
		$GroupObject		= Get-ADUser -identity $Obj
		if($error -ne "")
			{
			$GroupObject	= Get-ADGroup -identity $Obj
			}
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



    $statuses | Export-Csv \\SERVER\$logname.csv -NoTypeInformation -Delimiter ';' -Encoding UTF8
