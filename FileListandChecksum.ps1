[CmdletBinding()]
param(
	[Parameter(Mandatory=$True,
	ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
	[string]$Path
    )
if(Test-Path $Path)
{
	$Alldata = @()
	$Files = Get-ChildItem $Path -Recurse
	foreach($File in $Files)
	{
		$hash = Get-FileHash -Path $File.FullName -Algorithm SHA256
		$data = New-Object PSCustomObject -Property @{
			"File"=$File.Name
			"Path"=$File.FullName
			"Hash"=$hash.Hash
		}
		$Alldata += $data
	}
	$Alldata | Export-Csv C:\temp\MyFiles.csv -NoTypeInformation -Delimiter ';' -Encoding UTF8
}
else
{
    Write-Warning -Message "Path is invalid."    
}