 [CmdletBinding ()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$ServerName,
	[string]$Directory
	)
$Directory = (get-item $PSScriptRoot).parent.FullName
$ReDNS = '[^A-Za-z0-9]+'
if($ServerName -notmatch $ReDNS)
{

#$ErrorActionPreference = "SilentlyContinue"
$test = (Test-NetConnection -ComputerName $ServerName).PingSucceeded
if($Test -eq $true){$PingOK = $true}

"`n`n`n`n"

if($PingOK -eq $true)
{	
	if((Test-Path -Path "\\$ServerName\C$\temp") -eq $false){New-Item -Type Directory -Name temp -Path "\\$ServerName\C$"}
    $Error.Clear()
	Write-Host -foregroundColor Green "[OK]   Host is online."
	Write-Host -foregroundColor Yellow "[INFO]   Copy-Job started at $(Get-Date -Format "MM/dd/yyyy HH:mm")."
	Copy-Item -Exclude "Copy_Tool.*" -Path $Directory -Destination "\\$ServerName\C$\temp\" -Force -Recurse
	if($Error.count -le 0)
	{
	Write-Host -foregroundColor Green "[OK]   Copy-Job was successfull."
	Write-Output -InputObject "Press any key to continue..."
	[void]$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	}
	else
	{
	Write-Host -foregroundColor Red "[WARNING]   Copy-Job failed."
	Write-Output -InputObject "Press any key to continue..."
	[void]$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	}
}
else
{
Write-Host -foregroundColor Red "[WARNING]   Host unreachable."
Write-Output -InputObject "Press any key to continue..."
[void]$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
}
else
{
Write-Host -ForegroundColor Red "[WARNING]   Hostname invalid."
Write-Output -InputObject "Press any key to continue..."
	[void]$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}