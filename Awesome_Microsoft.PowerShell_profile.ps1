"Welcome 	[" + $env:Username + "]"
### Finder function USER
Function ufind-PowerShell {
 
 [CmdletBinding()]
param(
	[Parameter(Mandatory=$True,
	ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
	[string]$Find
	)
Get-ADUser -Filter "CN -like '*$find*' -or DisplayName -Like '*$find*' -or Description -Like '*$find*' -or DistinguishedName -Like '*$find*' -or Mail -Like '*$find*'" -Properties * | Sort-Object | Format-Table SamAccountName, displayName
}

Set-Alias -Name 'ufind' -Value 'ufind-PowerShell'

### Finder function GROUP
Function gfind-PowerShell {

[CmdletBinding()]
param(
	[Parameter(Mandatory=$True,
	ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
	[string]$Find
	)  

Get-ADGroup -Filter "SamAccountName -like '*$find*'" -Properties * | Sort-Object | Format-Table SamAccountName, Description
}

Set-Alias -Name 'gfind' -Value 'gfind-PowerShell'

### Passwort-Generator
Function pwgenerator-PowerShell {
$passwd = Read-Host "Options Password lenght`
	[1] = Lenght 08
	[2] = Lenght 16
	[3] = Lenght 24"

Function Start-Commands 
{ 
  Get-RandomAlphanumericString 
} 

Function Get-RandomAlphanumericString 
{
	
	[CmdletBinding()]
	Param (
        [int] $length = 8
	)

	Begin{
	}

	Process{
        Write-Output ( -join ((0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count $length | % {[char]$_}) )
	}	
}

If ($passwd -eq "1")
	{
	Write-Host "Generated password: "(Get-RandomAlphanumericString | Tee-Object -variable teeTime )
	}
If ($passwd -eq "2")
	{
	Write-Host "Generated password: "(Get-RandomAlphanumericString -length 16 | Tee-Object -variable teeTime )
	}
If ($passwd -eq "3")
	{
	Write-Host "Generated password: "(Get-RandomAlphanumericString -length 24 | Tee-Object -variable teeTime )
	}
}

Set-Alias -Name 'pwgen' -Value 'pwgenerator-PowerShell'

### NTFS query function
Function NTFSPerm-PowerShell {
 [CmdletBinding()]
param(
	[Parameter(Mandatory=$True,
	ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
	[string]$Path
	)
$Domain = $env:USERDOMAIN
$ErrorActionPreference = "SilentlyContinue"
$Folders = $Path -Split "\\"
$Plist	 = $Folders | % { $i = 0 } { $Folders[0..$i] -Join "\" -Replace ":$", ":\"; $i++ } 

$FList   = foreach($dir in $Plist)
	{
    Resolve-Path -Path $dir
	Get-Item $dir | Select-Object FullName
	Get-Acl -Path $dir -Filter Access | Select-Object -ExpandProperty Access | Where-Object {$_.IdentityReference -like "$Domain\*"} | Select-Object IdentityReference, FileSystemRights
    }
	
$Flist | ft FullName, IdentityReference, FileSystemRights
}

Set-Alias -Name 'perm' -Value 'NTFSPerm-PowerShell'



### Finder function STRING in FILE
Function stringfind-PowerShell {
#$find		= Read-Host "Find"  
 [CmdletBinding()]
param(
	[Parameter(Mandatory=$True,
	ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
	[string]$Find
	)
Get-ChildItem -recurse | Select-String -pattern $find | Group-Object path | Select-Object name
}

Set-Alias -Name 'sfind' -Value 'stringfind-PowerShell'

## This is a modified version of the netwrix script. Original script https://www.netwrix.com/how_to_collect_server_inventory.html
Function sinfo-PowerShell {
 
 [CmdletBinding()]
param(
	[Parameter(Mandatory=$True,
	ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
	[string]$Server
	)
 
$CPUInfo = Get-WmiObject -ComputerName $server Win32_Processor
$OSInfo = Get-WmiObject -ComputerName $server Win32_OperatingSystem

$infoObject = New-Object PSObject -Property {
#The following add data to the infoObjects. 
ServerName = $CPUInfo.SystemName 
CPU_Name = $CPUInfo.Name 
CPU_Description = $CPUInfo.Description 
CPU_Manufacturer = $CPUInfo.Manufacturer 
CPU_NumberOfCores = $CPUInfo.NumberOfCores 
CPU_L2CacheSize = $CPUInfo.L2CacheSize 
CPU_L3CacheSize = $CPUInfo.L3CacheSize 
CPU_SocketDesignation = $CPUInfo.SocketDesignation 
OS_Name = $OSInfo.Caption 
OS_Version = $OSInfo.Version 
TotalPhysical_Memory_GB = Get-WmiObject -ComputerName $server CIM_PhysicalMemory | Measure-Object -Property capacity -Sum | % {[math]::round(($_.sum / 1GB),2)} 
TotalVirtual_Memory_MB = [math]::round($OSInfo.TotalVirtualMemorySize / 1MB, 2) 
TotalVisable_Memory_MB = [math]::round(($OSInfo.TotalVisibleMemorySize  / 1MB), 2)
}
$info = $infoObject | Select-Object * -ExcludeProperty PSComputerName, RunspaceId, PSShowComputerName 
return $info

}

Set-Alias -Name 'sinfo' -Value 'sinfo-PowerShell'
