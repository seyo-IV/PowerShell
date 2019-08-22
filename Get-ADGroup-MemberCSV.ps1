
[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[string]$ListFile,
	[Parameter(Mandatory=$True)]
	[string]$CSVPath
	)
$groups = Get-Content $ListFile
$ObjectList =  @()
foreach($group in $groups){
$Groupname = $group
$GroupMember = Get-ADGroup -Identity $group -Properties member | Select-Object -ExpandProperty member
$data = @()
	foreach ($Member in $GroupMember)
		{
		$GMember	= Get-ADUser -Filter * -SearchBase $Member -Properties *
		$Name = $GMember.Name
		$Username = $GMember.SamAccountName
		$Email = $GMember.mail
		$Address = $GMember.PhysicalDeliveryOfficeName
		$Location = $GMember.DistinguishedName
		$Enabled = $GMember.Enabled
$list = New-Object PSCustomObject
$list | Add-Member -type NoteProperty -Name "Group" -value $Groupname
$list | Add-Member -type NoteProperty -Name "Name" -value $Name
$list | Add-Member -type NoteProperty -Name "SamAccountName" -value $Username
$list | Add-Member -type NoteProperty -Name "Email" -value $Email
$list | Add-Member -type NoteProperty -Name "Address" -value $Address
$list | Add-Member -type NoteProperty -Name "Location" -value $Location
$list | Add-Member -type NoteProperty -Name "Enabled" -value $Enabled
$data += $list
$ObjectList += $data
		}

}
$ObjectList | Export-Csv $CSVPAth -NoTypeInformation -Encoding UTF8
