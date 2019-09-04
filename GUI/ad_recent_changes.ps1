Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form = New-Object system.Windows.Forms.Form
$Form.ClientSize = '1000,700'
$Form.text = "AD recent changes"
$Form.TopMost = $false

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "by Sergiy Ivanov"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(750,25)
$Label1.Font                     = 'Microsoft Sans Serif,10'

$ProgressBar1                    = New-Object system.Windows.Forms.ProgressBar
$ProgressBar1.width              = 200
$ProgressBar1.height             = 60
$ProgressBar1.location           = New-Object System.Drawing.Point(300,23)
$ProgressBar1.Minimum = 1
$ProgressBar1.Step = 1

$Days = New-Object system.Windows.Forms.TextBox
$Days.multiline = $false
$Days.Text = "Days"
$Days.width = 100
$Days.height = 20
$Days.location = New-Object System.Drawing.Point(20,30)
$Days.Font = 'Microsoft Sans Serif,10'
$Days.Add_Click({$Days.Clear()})
$Days.Add_KeyDown({
    If($_.KeyCode -eq 'Enter')  {
        $_.SuppressKeyPress = $true
        $Search.PerformClick()
    }
})


$Search = New-Object system.Windows.Forms.Button
$Search.text = "Run"
$Search.width = 60
$Search.height = 30
$Search.location = New-Object System.Drawing.Point(143,30)
$Search.Font = 'Microsoft Sans Serif,10'
$Search.Add_Click({
$Day = $Days.Text
if($Day -ne "" -or $Day -ne "Days"){
$ObjectList =  @()
# Get domain controllers list
$DCs = Get-ADDomainController -Filter *
 
# Define timeframe for report (default is 1 day)
$startDate = (get-date).AddDays(-$day)
# Store group membership changes events from the security event logs in an array.
foreach ($DC in $DCs){

$events = Get-Eventlog -LogName Security -ComputerName $DC.Hostname -after $startDate | where {$_.eventID -eq 4728 -or $_.eventID -eq 4729}

}
 
# Loop through each stored event; print all changes to security global group members with when, who, what details.
 $i = 0
  foreach ($e in $events){ 
  $ProgressBar1.Maximum = $events.count
 # Member Added to Group
 
    if (($e.EventID -eq 4728 )){
      #write-host "Group: "$e.ReplacementStrings[2] "`tAction: Member added `tWhen: "$e.TimeGenerated "`tWho: "$e.ReplacementStrings[6] "`tAccount added: "$e.ReplacementStrings[0]
	  $Group = $e.ReplacementStrings[2] | Out-String
	  $When = $e.TimeGenerated | Out-String
	  $Who = $e.ReplacementStrings[6] | Out-String
	  try{$Account = (Get-ADUser -filter * -SearchBase $e.ReplacementStrings[0]).Name | Out-String}
	  catch{$Account = "User not found"}
	  
	$data     = @()
	$list = New-Object PSCustomObject
	$list | Add-Member -type NoteProperty -Name Group -value $Group
	$list | Add-Member -type NoteProperty -Name Action -value "Added"
	$list | Add-Member -type NoteProperty -Name When -value $When
	$list | Add-Member -type NoteProperty -Name Who -value $Who
	$list | Add-Member -type NoteProperty -Name Account -value $Account
	$data += $list
	$ObjectList += $data
    }
    # Member Removed from Group
    if (($e.EventID -eq 4729 )) {
      #write-host "Group: "$e.ReplacementStrings[2] "`tAction: Member removed `tWhen: "$e.TimeGenerated "`tWho: "$e.ReplacementStrings[6] "`tAccount removed: "$e.ReplacementStrings[0]
	  $Group = $e.ReplacementStrings[2] | Out-String
	  $When = $e.TimeGenerated | Out-String
	  $Who = $e.ReplacementStrings[6] | Out-String
	  try{$Account = (Get-ADUser -filter * -SearchBase $e.ReplacementStrings[0]).Name | Out-String}
	  catch{$Account = "User not found"}
	  
	  
	$data     = @()
	$list = New-Object PSCustomObject
	$list | Add-Member -type NoteProperty -Name Group -value $Group
	$list | Add-Member -type NoteProperty -Name Action -value "Removed"
	$list | Add-Member -type NoteProperty -Name When -value $When
	$list | Add-Member -type NoteProperty -Name Who -value $Who
	$list | Add-Member -type NoteProperty -Name Account -value $Account
	$data += $list
	$ObjectList += $data
    }
    $ProgressBar1.Value += 1
	}
    $ProgressBar1.Clear()
    $DataGridView1.Rows.Clear()
    $ObjectList | ForEach-Object { $DataGridView1.Rows.Add($_.Group, $_.Action, $_.When,$_.Who, $_.Account) }
    $DataGridView1.Refresh()
}

})

$DataGridView1 = New-Object system.Windows.Forms.DataGridView
$DataGridView1.width = 980
$DataGridView1.height = 555
$DataGridView1.location = New-Object System.Drawing.Point(9,135)
$DataGridView1.AllowUserToAddRows = $false
$DataGridView1.ColumnCount = 5
$DataGridView1.Columns[0].Name = "Group"
$DataGridView1.Columns[1].Name = "Action"
$DataGridView1.Columns[2].Name = "When"
$DataGridView1.Columns[3].Name = "Who"
$DataGridView1.Columns[4].Name = "Account"
$DataGridView1.Columns[0].AutoSizeMode = "Fill"
$DataGridView1.Columns[1].AutoSizeMode = "Fill"
$DataGridView1.Columns[2].AutoSizeMode = "Fill"
$DataGridView1.Columns[3].AutoSizeMode = "Fill"
$DataGridView1.Columns[4].AutoSizeMode = "Fill"

$Form.controls.AddRange(@($Days,$Search,$DataGridView1,$Label1,$ProgressBar1))
$Form.ShowDialog()
