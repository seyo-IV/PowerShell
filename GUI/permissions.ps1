Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form = New-Object system.Windows.Forms.Form
$Form.ClientSize = '692,401'
$Form.text = "NTFS-Permissions"
$Form.TopMost = $false

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "by Sergiy Ivanov"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(400,25)
$Label1.Font                     = 'Microsoft Sans Serif,10'

$FilePath = New-Object system.Windows.Forms.TextBox
$FilePath.multiline = $false
$FilePath.width = 100
$FilePath.height = 20
$FilePath.location = New-Object System.Drawing.Point(20,30)
$FilePath.Font = 'Microsoft Sans Serif,10'
$FilePath.Add_KeyDown({
    If($_.KeyCode -eq 'Enter')  {
        $_.SuppressKeyPress = $true
        $Search.PerformClick()
    }
})


$Search = New-Object system.Windows.Forms.Button
$Search.text = "Search"
$Search.width = 60
$Search.height = 30
$Search.location = New-Object System.Drawing.Point(143,30)
$Search.Font = 'Microsoft Sans Serif,10'
$Search.Add_Click({
	import-module ActiveDirectory
	Import-Module NTFSSecurity
    $Path = $FilePath.Text
	$Results = @()
	if($Path){
	$Folders = $Path -Split "\\"
	$Plist	 = $Folders | % { $i = 0 } { $Folders[0..$i] -Join "\" -Replace ":$", ":\"; $i++ }
	foreach($Dir in $PList)
    {
	if($dir -ne "\"){
		$tpDir = Test-Path $dir
		if($tpDir){
        $ACLList = Get-NTFSAccess -Path $dir | Where-Object {$_.Account -like "EBK\*"} | select AccessRights, Account
            foreach($ID in $ACLList)
                {
					$UID = $ID.Account.AccountName -replace 'EBK\\'
					$Account = $ID.Account.AccountName
					$AccessRight = $ID.AccessRights
					$Account = $Account | Out-String
					$AccessRight = $AccessRight | Out-String
					$list = New-Object PSCustomObject
					$list | Add-Member -type NoteProperty -Name Path -value $dir
					$list | Add-Member -type NoteProperty -Name Account -value $Account
					$list | Add-Member -type NoteProperty -Name AccessRight -value $AccessRight
					$Results += $list
					
	}
	}else{
					$Dir = "__INVALID__" | Out-String
					$Account = "__N/A__" | Out-String
					$AccessRight = "__N/A__" | Out-String
					$list = New-Object PSCustomObject
					$list | Add-Member -type NoteProperty -Name Path -value $Dir
					$list | Add-Member -type NoteProperty -Name Account -value $Account
					$list | Add-Member -type NoteProperty -Name AccessRight -value $AccessRight
					$Results += $list
	}
	}
	
	}
    $DataGridView1.Rows.Clear()
    $Results | ForEach-Object { $DataGridView1.Rows.Add($_.Path, $_.Account, $_.AccessRight) }
    $DataGridView1.Refresh()
	Clear-Variable Results
	}

	})

$DataGridView1 = New-Object system.Windows.Forms.DataGridView
$DataGridView1.width = 675
$DataGridView1.height = 250
$DataGridView1.location = New-Object System.Drawing.Point(9,135)
$DataGridView1.AllowUserToAddRows = $false
$DataGridView1.ColumnCount = 3
$DataGridView1.Columns[0].Name = "Path"
$DataGridView1.Columns[1].Name = "Account"
$DataGridView1.Columns[2].Name = "AccessRight"
$DataGridView1.Columns[0].AutoSizeMode = "Fill"
$DataGridView1.Columns[1].AutoSizeMode = "Fill"
$DataGridView1.Columns[2].AutoSizeMode = "Fill"

$Form.controls.AddRange(@($FilePath,$Search,$DataGridView1,$Label1))
$Form.ShowDialog()
