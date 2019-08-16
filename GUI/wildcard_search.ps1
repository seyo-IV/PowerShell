Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form = New-Object system.Windows.Forms.Form
$Form.ClientSize = '692,401'
$Form.text = "AD Query"
$Form.TopMost = $false

$PictureBox1                     = New-Object system.Windows.Forms.PictureBox
$PictureBox1.width               = 156
$PictureBox1.height              = 133
$PictureBox1.location            = New-Object System.Drawing.Point(530,0)
$PictureBox1.imageLocation       = "\\egvfs02\it$\ScriptRepository\GUI\source\data\posh.png"
$PictureBox1.SizeMode            = [System.Windows.Forms.PictureBoxSizeMode]::zoom
$Form.controls.AddRange(@($PictureBox1))

$SamAccountName = New-Object system.Windows.Forms.TextBox
$SamAccountName.multiline = $false
$SamAccountName.width = 100
$SamAccountName.height = 20
$SamAccountName.location = New-Object System.Drawing.Point(20,30)
$SamAccountName.Font = 'Microsoft Sans Serif,10'
$SamAccountName.Add_KeyDown({
    If($_.KeyCode -eq 'Enter')  {
        $_.SuppressKeyPress = $true
        $Search.PerformClick()
    }
})

$List = New-Object system.Windows.Forms.ComboBox
$List.width = 100
$List.height = 50
$List.Items.Add("User")
$List.Items.Add("Group")
$List.DropDownStyle = "DropDownList"
$List.location = New-Object System.Drawing.Point(21,83)
$List.SelectedIndex = 0

$Search = New-Object system.Windows.Forms.Button
$Search.text = "Search"
$Search.width = 60
$Search.height = 30
$Search.location = New-Object System.Drawing.Point(143,30)
$Search.Font = 'Microsoft Sans Serif,10'
$Search.Add_Click({
    $SearchType = $List.Text
    $find = $SamAccountName.Text
    If($SearchType -eq "User") {
        $Results = Get-ADUser -Filter "CN -like '*$find*' -or DisplayName -Like '*$find*' -or Description -Like '*$find*' -or SamAccountName -Like '*$find*' -or Mail -Like '*$find*'" -Properties *
    }
    Else {
        $Results = Get-ADGroup -Filter "SamAccountName -like '*$find*'" -Properties *
    }
    $DataGridView1.Rows.Clear()
    $Results | ForEach-Object { $DataGridView1.Rows.Add($_.SamAccountName, $_.DisplayName, $_.Description) }
    $DataGridView1.Refresh()
})

$DataGridView1 = New-Object system.Windows.Forms.DataGridView
$DataGridView1.width = 675
$DataGridView1.height = 250
$DataGridView1.location = New-Object System.Drawing.Point(9,135)
$DataGridView1.AllowUserToAddRows = $false
$DataGridView1.ColumnCount = 3
$DataGridView1.Columns[0].Name = "SamAccountName"
$DataGridView1.Columns[1].Name = "DisplayName"
$DataGridView1.Columns[2].Name = "Description"
$DataGridView1.Columns[0].AutoSizeMode = "Fill"
$DataGridView1.Columns[1].AutoSizeMode = "Fill"
$DataGridView1.Columns[2].AutoSizeMode = "Fill"

$Form.controls.AddRange(@($SamAccountName,$List,$Search,$ProgressBar1,$DataGridView1))
$Form.ShowDialog()