#requires -module ActiveDirectory
 <#
 .SYNOPSIS
 Generates a usermembership list and exports as csv.

 .PARAMETER LogName
 Specify a log for the export.

 .PARAMETER Path
 Specify a file which containes the group names.


 .EXAMPLE
 .\Export_GroupList_CSV.ps1 -LogName NAME -Path C:\groups.txt
 
 #>
[CmdletBinding()]
param(
	[Parameter(Mandatory=$True,
	ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
	[string]$LogName,
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



    $statuses | Export-Csv \\egvfs02\it$\ScriptRepository\Logs\Export\$logname.csv -NoTypeInformation -Delimiter ';' -Encoding UTF8
