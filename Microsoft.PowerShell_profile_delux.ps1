# Rename the Profile to 'Microsoft.PowerShell_profile.ps1'
# and place it at 'C:\Users\%username%\Documents\WindowsPowerShell' .
Try 
{ 
  Import-Module Activedirectory -ErrorAction Stop
} 
Catch 
{ 
  Write-Host "[ERROR]`t  Module couldn't be loaded. Script will stop! $($_.Exception.Message)" 
  Exit 1 
} 
"Welcome 	[" + $env:Username + "]"
	
### Finder function USER
Function ufind-PowerShell {  
param ( [string]$find)
Get-ADUser -Filter "cn -like '*$find*'" -Properties DisplayName | ft SamAccountName, displayName
}

Set-Alias -Name 'ufind' -Value 'ufind-PowerShell'

### Finder function GROUP
Function gfind-PowerShell {
param ( [string]$find)  

$getuser = Get-ADGroup -Filter "CN -like '*$find*'" -Properties cn | ft SamAccountName
If($getuser -eq ""){Get-ADGroup -Filter "SamAccountName -like '*$find*'" -Properties cn | ft SamAccountName}else{$getuser}
}

Set-Alias -Name 'gfind' -Value 'gfind-PowerShell'

### Passwort-Generator
Function pwgenerator-PowerShell {
$passwd = Read-Host "Options Passwordlenght`
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
param ( [string]$Path)
$ErrorActionPreference = "SilentlyContinue"
$Domain = $env:UserDomain
$Folders = $Path -Split "\\"
$Plist	 = $Folders | % { $i = 0 } { $Folders[0..$i] -Join "\" -Replace ":$", ":\"; $i++ } 

$FList   = foreach($dir in $Plist)
	{
    Resolve-Path -Path $dir
	Get-Item $dir | select FullName
	Get-Acl -Path $dir -Filter Access | Select-Object -ExpandProperty Access | Where-Object {$_.IdentityReference -like "$Domain\*"} | Select-Object IdentityReference, FileSystemRights
    }
	
$Flist | ft FullName, IdentityReference, FileSystemRights
}

Set-Alias -Name 'perm' -Value 'NTFSPerm-PowerShell'

Function sfind-PowerShell {  
param ( [string]$find)
Get-ChildItem -recurse | Select-String -pattern $find | group path | select name
}

Set-Alias -Name 'sfind' -Value 'sfind-PowerShell'
