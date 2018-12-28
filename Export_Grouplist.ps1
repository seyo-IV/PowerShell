
Import-Module ActiveDirectory -ErrorAction Stop 
$error.clear()
$Source = Read-Host "SamAccountName"
$UOG	= Read-Host "User[u], Group[g] oder Group(MemeberOf)[gm] `
[Choose option]"
$Path   = "\\your\log\path\"
$log    = $path + $Source + ".log"
$ErrorActionpreference = "SilentlyContinue"
		If ($UOG -eq "u")
	{
	$ADUser	= Get-ADUser -Identity $Source -Properties memberof | Select-Object -ExpandProperty memberof
	$Count	= $ADUser.count
	Write-Output "Totalcount $Count" | Out-File $log -append
	Write-Output "$Source is member of" | Out-File $log -append
	Write-Output "----------------------------------------------------"	| Out-File $log -append
	foreach ($Group in $ADUser)
		{
		$Gr			= Get-ADGroup -identity $Group
		$GrNa		= $Gr.Name # alter this to get another user attribute
		Write-Output "$GrNa" | Out-File $log -append
		}
	}
		If ($UOG -eq "g")
	{
	$ADGroup	= Get-ADGroup -Identity $Source -Properties member | Select-Object -ExpandProperty member
	$Count	= $ADGroup.count
	Write-Output "Totalcount $Count" | Out-File $log -append
	Write-Output "The following user/groups are member of $Source" | Out-File $log -append
	Write-Output "----------------------------------------------------" | Out-File $log -append
	foreach ($Obj in $ADGroup)
		{
		$error.clear()
		$Gr0		= Get-ADUser -identity $Obj
		if($error -ne "")
			{
			$Gr0	= Get-ADGroup -identity $Obj
			}
		$GrNa0		= $Gr0.Name # alter this to get another user attribute
		Write-Output "$GrNa0" | Out-File $log -append
		} 
	
	}
		If ($UOG -eq "gm")
	{
	$ADGroupMemo= Get-ADGroup -Identity $Source -Properties memberof | Select-Object -ExpandProperty memberof
	$Count	= $ADGroupMemo.count
	Write-Output "Totalcount $Count" | Out-File $log -append
	Write-Output "The following groups are member of $Source" | Out-File $log -append
	Write-Output "----------------------------------------------------" | Out-File $log -append
	foreach ($Groups in $ADGroupMemo)
		{
		$Gr01		= Get-ADGroup -identity $Groups
		$GrNa01		= $Gr01.Name # alter this to get another user attribute
		Write-Output "$GrNa01" | Out-File $log -append
		} 
	}
	$Err0r	= $error.count
	"[INFO] Export to $log"
	"Errors:	$Err0r"

	