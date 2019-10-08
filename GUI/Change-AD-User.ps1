###################################################################################################
################################### Initialisations ###############################################
###################################################################################################

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

###################################################################################################
##################################### Functions ###################################################
###################################################################################################

function Get-User-Object {
$User = Get-ADUser -Identity $sAMAccountName_TB.Text
    if($User){
    $global:Sam = $User
    $ListBox1.Items.Add("
`r`n $($sAMAccountName_TB.Text) is selected!")
    }
    else{
    $ListBox1.Items.Add("
`r`n $($sAMAccountName_TB.Text) not found!")
    }
}

function Get-User-Properties {
$ADUserObject = Get-ADUser -Identity $Sam.sAMAccountName -Properties DisplayName, Company, HomeDrive, HomeDirectory, Title, Mail, CanonicalName, physicalDeliveryOfficeName, ProfilePath, Department
$Department = $ADUserObject.Department
$ProfilePath = $ADUserObject.ProfilePath
$DisplayName = $ADUserObject.DisplayName
$Title = $ADUserObject.Title
$Mail = $ADUserObject.Mail
$Company = $ADUserObject.Company
$Name = $ADUserObject.Name
$Enabled = $ADUserObject.Enabled
$ObjectGUID = $ADUserObject.ObjectGUID
$SID = $ADUserObject.SID
$HomeDirectory = $ADUserObject.HomeDirectory
$HomeDrive = $ADUserObject.HomeDrive
$CN = $ADUserObject.CanonicalName
$Office = $ADUserObject.physicalDeliveryOfficeName
$TSProfile = get-aduser -Identity $Sam.sAMAccountName | %{Add-Member -InputObject $_ -Name TerminalServicesProfilePath -Force -Membertype NoteProperty -Value (([ADSI]"LDAP://$($_.DistinguishedName)").TerminalServicesProfilePath) -PassThru} | Select-Object TerminalServicesProfilePath
$TSProfile = $TSProfile -replace "@{TerminalServicesProfilePath=", "" -replace "}"
$TSHomeDrive = get-aduser -Identity $Sam.sAMAccountName | %{Add-Member -InputObject $_ -Name TerminalServicesHomeDrive -Force -Membertype NoteProperty -Value (([ADSI]"LDAP://$($_.DistinguishedName)").TerminalServicesHomeDrive) -PassThru} | Select-Object TerminalServicesHomeDrive
$TSHomeDrive = $TSHomeDrive -replace "@{TerminalServicesHomeDrive=", "" -replace "}"
$TsHomeDirectory = get-aduser -Identity $Sam.sAMAccountName | %{Add-Member -InputObject $_ -Name TerminalServicesHomeDirectory -Force -Membertype NoteProperty -Value (([ADSI]"LDAP://$($_.DistinguishedName)").TerminalServicesHomeDirectory) -PassThru} | Select-Object TerminalServicesHomeDirectory
$TsHomeDirectory = $TsHomeDirectory -replace "@{TerminalServicesHomeDirectory=", "" -replace "}"
$ListBox1.Items.Clear()
$ListBox1.Items.Add("
`r`n Name: $Name")
$ListBox1.Items.Add("
`r`n DisplayName: $DisplayName")
$ListBox1.Items.Add("
`r`n Mail: $Mail")
$ListBox1.Items.Add("
`r`n Title: $Title")
$ListBox1.Items.Add("
`r`n Office: $Office")
$ListBox1.Items.Add("
`r`n Company: $Company")
$ListBox1.Items.Add("
`r`n Department: $Department")
$ListBox1.Items.Add("
`r`n Enabled: $Enabled")
$ListBox1.Items.Add("
`r`n ObjectGUID: $ObjectGUID")
$ListBox1.Items.Add("
`r`n SID: $SID")
$ListBox1.Items.Add("
`r`n Location: $CN")
$ListBox1.Items.Add("
`r`n Profile Path: $ProfilePath")
$ListBox1.Items.Add("
`r`n Homedirectory: $HomeDirectory")
$ListBox1.Items.Add("
`r`n HomeDrive: $HomeDrive") 
$ListBox1.Items.Add("
`r`n TSProfile: $TSProfile")
$ListBox1.Items.Add("
`r`n TSHomeDrive: $TSHomeDrive")
$ListBox1.Items.Add("
`r`n TSHomeDirectory: $TsHomeDirectory")
}

Function Set-Permissions {
    if($Reference_CB.Text -eq "" -or $Reference_CB -eq $null){
    $ListBox1.Items.Add("
`r`n Reference is null or empty!")
    }
    elseif($Reference_CB.Text -eq "CUSTOM"){
    $Groups = Get-ADUser -Identity $Reference_TB.Text -Properties memberof | Select-Object -ExpandProperty memberof
        foreach ($Group in $Groups) {
        Add-ADGroupMember -Identity $Group -Members $Sam.sAMAccountName
        $Grp = (Get-ADGroup -Identity $Group).sAMAccountName
        $ListBox1.Items.Add("
`r`n $($sam.sAMAccountName) added group $Grp")
        }
    }
    elseif($Reference_CB.Text -eq "REFUSER1"){
    $Groups = Get-ADUser -Identity $Reference_CB.Text -Properties memberof | Select-Object -ExpandProperty memberof
        foreach ($Group in $Groups) {
        Add-ADGroupMember -Identity $Group -Members $Sam.sAMAccountName
        $Grp = (Get-ADGroup -Identity $Group).sAMAccountName
        $ListBox1.Items.Add("
`r`n $($sam.sAMAccountName) added group $Grp")
        }
    }
    elseif($Reference_CB.Text -eq "REFUSER2"){
    $Groups = Get-ADUser -Identity $Reference_CB.Text -Properties memberof | Select-Object -ExpandProperty memberof
        foreach ($Group in $Groups) {
        Add-ADGroupMember -Identity $Group -Members $Sam.sAMAccountName
        $Grp = (Get-ADGroup -Identity $Group).sAMAccountName
        $ListBox1.Items.Add("
`r`n $($sam.sAMAccountName) added group $Grp")
        }
    }
    elseif($Reference_CB.Text -eq "REFUSER3"){
    $Groups = Get-ADUser -Identity $Reference_CB.Text -Properties memberof | Select-Object -ExpandProperty memberof
        foreach ($Group in $Groups) {
        Add-ADGroupMember -Identity $Group -Members $Sam.sAMAccountName
        $Grp = (Get-ADGroup -Identity $Group).sAMAccountName
        $ListBox1.Items.Add("
`r`n $($sam.sAMAccountName) added group $Grp")
        }
    }
    elseif($Reference_CB.Text -eq "REFUSER4"){
    $Groups = Get-ADUser -Identity $Reference_CB.Text -Properties memberof | Select-Object -ExpandProperty memberof
        foreach ($Group in $Groups) {
        Add-ADGroupMember -Identity $Group -Members $Sam.sAMAccountName
        $Grp = (Get-ADGroup -Identity $Group).sAMAccountName
        $ListBox1.Items.Add("
`r`n $($sam.sAMAccountName) added group $Grp")
        }
    }
    elseif($Reference_CB.Text -eq "REFUSER5"){
    $Groups = Get-ADUser -Identity $Reference_CB.Text -Properties memberof | Select-Object -ExpandProperty memberof
        foreach ($Group in $Groups) {
        Add-ADGroupMember -Identity $Group -Members $Sam.sAMAccountName
        $Grp = (Get-ADGroup -Identity $Group).sAMAccountName
        $ListBox1.Items.Add("
`r`n $($sam.sAMAccountName) added group $Grp")
        }
    }
}


###################################################################################################
##################################### Form begins #################################################
###################################################################################################


$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '605,691'
$Form.text                       = "Change-AD-User"
$Form.TopMost                    = $false

$sAMAccountName_TB               = New-Object system.Windows.Forms.TextBox
$sAMAccountName_TB.multiline     = $false
$sAMAccountName_TB.width         = 100
$sAMAccountName_TB.height        = 20
$sAMAccountName_TB.location      = New-Object System.Drawing.Point(19,44)
$sAMAccountName_TB.Font          = 'Microsoft Sans Serif,9'
$sAMAccountName_TB.Add_KeyDown({
    If($_.KeyCode -eq 'Enter')  {
        $_.SuppressKeyPress = $true
        $GetUser_BT.PerformClick()
    }
})

$GetUser_BT                      = New-Object system.Windows.Forms.Button
$GetUser_BT.text                 = "Select"
$GetUser_BT.width                = 60
$GetUser_BT.height               = 30
$GetUser_BT.location             = New-Object System.Drawing.Point(481,40)
$GetUser_BT.Font                 = 'Microsoft Sans Serif,9'
$GetUser_BT.Add_Click({
Get-User-Object
})

$SetPermissions_GB               = New-Object system.Windows.Forms.Groupbox
$SetPermissions_GB.height        = 100
$SetPermissions_GB.width         = 240
$SetPermissions_GB.text          = "Set-Permissions"
$SetPermissions_GB.location      = New-Object System.Drawing.Point(12,306)

$CopyPermisions_BT               = New-Object system.Windows.Forms.Button
$CopyPermisions_BT.text          = "Set"
$CopyPermisions_BT.width         = 80
$CopyPermisions_BT.height        = 30
$CopyPermisions_BT.location      = New-Object System.Drawing.Point(149,55)
$CopyPermisions_BT.Font          = 'Microsoft Sans Serif,9'
$CopyPermisions_BT.Add_Click({
Set-Permissions
})

$Reference_TB                    = New-Object system.Windows.Forms.TextBox
$Reference_TB.multiline          = $false
$Reference_TB.width              = 100
$Reference_TB.height             = 20
$Reference_TB.location           = New-Object System.Drawing.Point(131,18)
$Reference_TB.Font               = 'Microsoft Sans Serif,9'

$Reference_CB                    = New-Object system.Windows.Forms.ComboBox
$Reference_CB.width              = 100
$Reference_CB.height             = 20
$Reference_CB.location           = New-Object System.Drawing.Point(6,19)
$Reference_CB.Font               = 'Microsoft Sans Serif,9'
$Reference_CB.DropDownStyle       = "DropDownList"
$Reference_CB.Items.Add("")
$Reference_CB.Items.Add("CUSTOM")
$Reference_CB.Items.Add("REFUSER1")
$Reference_CB.Items.Add("REFUSER2")
$Reference_CB.Items.Add("REFUSER3")
$Reference_CB.Items.Add("REFUSER4")
$Reference_CB.Items.Add("REFUSER5")
$Reference_CB.SelectedIndex = 0

$ChangeOU_BT                     = New-Object system.Windows.Forms.Button
$ChangeOU_BT.text                = "Change Location"
$ChangeOU_BT.width               = 120
$ChangeOU_BT.height              = 30
$ChangeOU_BT.location            = New-Object System.Drawing.Point(290,14)
$ChangeOU_BT.Font                = 'Microsoft Sans Serif,9'
$ChangeOU_BT.Add_Click({

###################################################################################################
##################################### Functions ###################################################
###################################################################################################

function Get-UserOU {
$SOU  = (Get-ADOrganizationalUnit -LDAPFilter "(name=$($OUName.Text)*)" -SearchBase 'OU=User,DC=domain,DC=com').DistinguishedName
    if($SOU){
    $Global:TargetOU = $SOU
    if($SOU.Count -gt 1){
    $OUListBox1.Clear()
    $OUListBox1.AppendText("
`r`n More than one OU was Found! Please be more specific!")}
    else{
    $OUListBox1.Clear()
    $OUsName = $SOU -split "," | Select-Object -First 1
    $OUListBox1.AppendText("
`r`n $OUsName was Found!")
    }
    }
}

function Move-UserOU {
$ERROR.Clear()
$GOU  = (Get-ADUser -Identity $sam.sAMAccountName).DistinguishedName
try{
Move-ADObject -Identity $GOU -TargetPath $TargetOU
}catch{
$ERRORForm                            = New-Object system.Windows.Forms.Form
$ERRORForm.ClientSize                 = '197,130'
$ERRORForm.text                       = "ERROR"
$ERRORForm.TopMost                    = $false

$Label_ERROR                     = New-Object system.Windows.Forms.Label
$Label_ERROR.text                = "An ERROR occured!"
$Label_ERROR.AutoSize            = $true
$Label_ERROR.width               = 25
$Label_ERROR.height              = 10
$Label_ERROR.location            = New-Object System.Drawing.Point(40,45)
$Label_ERROR.Font                = 'Microsoft Sans Serif,10,style=Bold'

$ErrorOK_BT                           = New-Object system.Windows.Forms.Button
$ErrorOK_BT.text                      = "OK"
$ErrorOK_BT.width                     = 60
$ErrorOK_BT.height                    = 30
$ErrorOK_BT.location                  = New-Object System.Drawing.Point(64,85)
$ErrorOK_BT.Font                      = 'Microsoft Sans Serif,10'
$ErrorOK_BT.Add_Click({ $ERRORForm.Tag = $null; $ERRORForm.Close() })

$ERRORForm.controls.AddRange(@($Label_ERROR,$ErrorOK_BT))
$ERRORForm.ShowDialog()
$OUListBox1.AppendText("
`r`n $($_.Exception.Message)")
}
	if($ERROR -eq $null -or $ERRO -eq ""){
	$OUListBox1.AppendText("
`r`n User moved to OU: $SOU.")
	}
}

###################################################################################################
##################################### Form begins #################################################
###################################################################################################

$FormOU                            = New-Object system.Windows.Forms.Form
$FormOU.ClientSize                 = '400,400'
$FormOU.text                       = "Change Location"
$FormOU.TopMost                    = $false

$OUName                          = New-Object system.Windows.Forms.TextBox
$OUName.multiline                = $false
$OUName.width                    = 100
$OUName.height                   = 20
$OUName.location                 = New-Object System.Drawing.Point(21,52)
$OUName.Font                     = 'Microsoft Sans Serif,10'
$OUName.Add_KeyDown({
    If($_.KeyCode -eq 'Enter')  {
        $_.SuppressKeyPress = $true
        $OUSearch_BT.PerformClick()
    }
})

$Label_OU                        = New-Object system.Windows.Forms.Label
$Label_OU.text                   = "OU-Name"
$Label_OU.AutoSize               = $true
$Label_OU.width                  = 25
$Label_OU.height                 = 10
$Label_OU.location               = New-Object System.Drawing.Point(34,28)
$Label_OU.Font                   = 'Microsoft Sans Serif,10'

$OUSearch_BT                     = New-Object system.Windows.Forms.Button
$OUSearch_BT.text                = "Search"
$OUSearch_BT.width               = 60
$OUSearch_BT.height              = 30
$OUSearch_BT.location            = New-Object System.Drawing.Point(267,25)
$OUSearch_BT.Font                = 'Microsoft Sans Serif,10'
$OUSearch_BT.Add_Click({
Get-UserOU
})

$OUCancle_BT                     = New-Object system.Windows.Forms.Button
$OUCancle_BT.text                = "Cancle"
$OUCancle_BT.width               = 60
$OUCancle_BT.height              = 30
$OUCancle_BT.location            = New-Object System.Drawing.Point(267,76)
$OUCancle_BT.Font                = 'Microsoft Sans Serif,10'
$OUCancle_BT.Add_Click({ $FormOU.Tag = $null; $FormOU.Close() })

$OUListBox1                        = New-Object system.Windows.Forms.TextBox
$OUListBox1.width                  = 377
$OUListBox1.height                 = 167
$OUListBox1.location               = New-Object System.Drawing.Point(11,223)
$OUListBox1.Multiline              = $true

$Groupbox1                       = New-Object system.Windows.Forms.Groupbox
$Groupbox1.height                = 113
$Groupbox1.width                 = 381
$Groupbox1.text                  = "Search OU"
$Groupbox1.location              = New-Object System.Drawing.Point(9,11)

$ChangeOU_BT                     = New-Object system.Windows.Forms.Button
$ChangeOU_BT.text                = "Move User"
$ChangeOU_BT.width               = 80
$ChangeOU_BT.height              = 30
$ChangeOU_BT.location            = New-Object System.Drawing.Point(157,155)
$ChangeOU_BT.Font                = 'Microsoft Sans Serif,10'
$ChangeOU_BT.Add_Click({
Move-UserOU
})

$FormOU.controls.AddRange(@($OUName,$Label_OU,$OUSearch_BT,$OUCancle_BT,$OUListBox1,$Groupbox1,$ChangeOU_BT))


$FormOU.ShowDialog()

})

$SetAdUserProperties_BT          = New-Object system.Windows.Forms.Button
$SetAdUserProperties_BT.text     = "Set-User"
$SetAdUserProperties_BT.width    = 70
$SetAdUserProperties_BT.height   = 30
$SetAdUserProperties_BT.location  = New-Object System.Drawing.Point(114,182)
$SetAdUserProperties_BT.Font     = 'Microsoft Sans Serif,9'
$SetAdUserProperties_BT.Add_Click({
###################################################################################################
####################################### Functions #################################################
###################################################################################################

Function Disable-User {
Disable-ADAccount -Identity $sam.SamAccountName
}

Function Enable-User {
Enable-ADAccount -Identity $sam.SamAccountName
}

###################################################################################################
##################################### Form begins #################################################
###################################################################################################


$AtrForm                            = New-Object system.Windows.Forms.Form
$AtrForm.ClientSize                 = '177,280'
$AtrForm.text                       = "AtrForm"
$AtrForm.TopMost                    = $false

$CommonAtr_BT                    = New-Object system.Windows.Forms.Button
$CommonAtr_BT.text               = "Common Attributes"
$CommonAtr_BT.width              = 130
$CommonAtr_BT.height             = 30
$CommonAtr_BT.location           = New-Object System.Drawing.Point(24,19)
$CommonAtr_BT.Font               = 'Microsoft Sans Serif,8'
$CommonAtr_BT.Add_Click({
###################################################################################################
####################################### Functions #################################################
###################################################################################################

Function Change-Common-Atr {
    if($Givenname_TB.Text -ne ""){
    Set-ADUser -Identity $sam.SamAccountName -GivenName $Givenname_TB.Text
    }
    if($SurName_TB.Text -ne ""){
    Set-ADUser -Identity $sam.SamAccountName -Surname $SurName_TB.Text
    }
    if($Name_TB.Text -ne ""){
    Set-ADUser -Identity $sam.SamAccountName -Add @{Name=$Name_TB.Text}
    }
    if($DisplayName_TB.Text -ne ""){
    Set-ADUser -Identity $sam.SamAccountName -DisplayName $DisplayName_TB.Text
    }
    
}

Function Change-Other-Atr {
try{
    if($Mail_TB.Text -ne ""){
    Set-ADUser -Identity $sam.SamAccountName -Mail $Mail_TB.Text
    }
    if($OfficePhone_TB.Text -ne ""){
    Set-ADUser -Identity $sam.SamAccountName -OfficePhone $OfficePhone_TB.Text
    }
    if($Description_TB.Text -ne ""){
    Set-ADUser -Identity $sam.SamAccountName -Description $Description_TB.Text
    }
 }catch{
$ERRORForm                            = New-Object system.Windows.Forms.Form
$ERRORForm.ClientSize                 = '197,130'
$ERRORForm.text                       = "ERROR"
$ERRORForm.TopMost                    = $false

$Label_ERROR                     = New-Object system.Windows.Forms.Label
$Label_ERROR.text                = "An ERROR occured!"
$Label_ERROR.AutoSize            = $true
$Label_ERROR.width               = 25
$Label_ERROR.height              = 10
$Label_ERROR.location            = New-Object System.Drawing.Point(40,45)
$Label_ERROR.Font                = 'Microsoft Sans Serif,10,style=Bold'

$OK_BT                           = New-Object system.Windows.Forms.Button
$OK_BT.text                      = "OK"
$OK_BT.width                     = 60
$OK_BT.height                    = 30
$OK_BT.location                  = New-Object System.Drawing.Point(64,85)
$OK_BT.Font                      = 'Microsoft Sans Serif,10'
$OK_BT.Add_Click({ $ERRORForm.Tag = $null; $ERRORForm.Close() })

$ERRORForm.controls.AddRange(@($Label_ERROR,$OK_BT))
$ERRORForm.ShowDialog()
 }
}

###################################################################################################
##################################### Form begins #################################################
###################################################################################################


$CommonForm                            = New-Object system.Windows.Forms.Form
$CommonForm.ClientSize                 = '400,473'
$CommonForm.text                       = "Common Attributes"
$CommonForm.TopMost                    = $false

$CommonRun_BT                    = New-Object system.Windows.Forms.Button
$CommonRun_BT.text               = "Run"
$CommonRun_BT.width              = 60
$CommonRun_BT.height             = 30
$CommonRun_BT.location           = New-Object System.Drawing.Point(293,39)
$CommonRun_BT.Font               = 'Microsoft Sans Serif,10'
$CommonRun_BT.Add_Click({ Change-Common-Atr })

$CommonRun2_BT                   = New-Object system.Windows.Forms.Button
$CommonRun2_BT.text              = "Run"
$CommonRun2_BT.width             = 60
$CommonRun2_BT.height            = 30
$CommonRun2_BT.location          = New-Object System.Drawing.Point(293,270)
$CommonRun2_BT.Font              = 'Microsoft Sans Serif,10'
$CommonRun2_BT.Add_Click({ Change-Other-Atr })

$Other_GB                        = New-Object system.Windows.Forms.Groupbox
$Other_GB.height                 = 171
$Other_GB.width                  = 363
$Other_GB.text                   = "Other"
$Other_GB.location               = New-Object System.Drawing.Point(7,249)

$Givenname_TB                    = New-Object system.Windows.Forms.TextBox
$Givenname_TB.multiline          = $false
$Givenname_TB.width              = 100
$Givenname_TB.height             = 20
$Givenname_TB.location           = New-Object System.Drawing.Point(26,60)
$Givenname_TB.Font               = 'Microsoft Sans Serif,10'

$Label_GivenName                 = New-Object system.Windows.Forms.Label
$Label_GivenName.text            = "Givenname"
$Label_GivenName.AutoSize        = $true
$Label_GivenName.width           = 25
$Label_GivenName.height          = 10
$Label_GivenName.location        = New-Object System.Drawing.Point(31,35)
$Label_GivenName.Font            = 'Microsoft Sans Serif,10'

$Label_Surname                   = New-Object system.Windows.Forms.Label
$Label_Surname.text              = "Surname"
$Label_Surname.AutoSize          = $true
$Label_Surname.width             = 25
$Label_Surname.height            = 10
$Label_Surname.location          = New-Object System.Drawing.Point(31,88)
$Label_Surname.Font              = 'Microsoft Sans Serif,10'

$SurName_TB                      = New-Object system.Windows.Forms.TextBox
$SurName_TB.multiline            = $false
$SurName_TB.width                = 100
$SurName_TB.height               = 20
$SurName_TB.location             = New-Object System.Drawing.Point(26,113)
$SurName_TB.Font                 = 'Microsoft Sans Serif,10'

$Label_Name                      = New-Object system.Windows.Forms.Label
$Label_Name.text                 = "Name"
$Label_Name.AutoSize             = $true
$Label_Name.width                = 25
$Label_Name.height               = 10
$Label_Name.location             = New-Object System.Drawing.Point(31,142)
$Label_Name.Font                 = 'Microsoft Sans Serif,10'

$Name_TB                         = New-Object system.Windows.Forms.TextBox
$Name_TB.multiline               = $false
$Name_TB.width                   = 100
$Name_TB.height                  = 20
$Name_TB.location                = New-Object System.Drawing.Point(26,167)
$Name_TB.Font                    = 'Microsoft Sans Serif,10'

$Label_DisplayName               = New-Object system.Windows.Forms.Label
$Label_DisplayName.text          = "DisplayName"
$Label_DisplayName.AutoSize      = $true
$Label_DisplayName.width         = 25
$Label_DisplayName.height        = 10
$Label_DisplayName.location      = New-Object System.Drawing.Point(30,195)
$Label_DisplayName.Font          = 'Microsoft Sans Serif,10'

$DisplayName_TB                  = New-Object system.Windows.Forms.TextBox
$DisplayName_TB.multiline        = $false
$DisplayName_TB.width            = 100
$DisplayName_TB.height           = 20
$DisplayName_TB.location         = New-Object System.Drawing.Point(26,219)
$DisplayName_TB.Font             = 'Microsoft Sans Serif,10'

$Label_Mail                      = New-Object system.Windows.Forms.Label
$Label_Mail.text                 = "Mail"
$Label_Mail.AutoSize             = $true
$Label_Mail.width                = 25
$Label_Mail.height               = 10
$Label_Mail.location             = New-Object System.Drawing.Point(23,16)
$Label_Mail.Font                 = 'Microsoft Sans Serif,10'

$Mail_TB                         = New-Object system.Windows.Forms.TextBox
$Mail_TB.multiline               = $false
$Mail_TB.width                   = 100
$Mail_TB.height                  = 20
$Mail_TB.location                = New-Object System.Drawing.Point(18,40)
$Mail_TB.Font                    = 'Microsoft Sans Serif,10'

$Label_OfficePhone               = New-Object system.Windows.Forms.Label
$Label_OfficePhone.text          = "Phone"
$Label_OfficePhone.AutoSize      = $true
$Label_OfficePhone.width         = 25
$Label_OfficePhone.height        = 10
$Label_OfficePhone.location      = New-Object System.Drawing.Point(24,66)
$Label_OfficePhone.Font          = 'Microsoft Sans Serif,10'

$OfficePhone_TB                  = New-Object system.Windows.Forms.TextBox
$OfficePhone_TB.multiline        = $false
$OfficePhone_TB.width            = 100
$OfficePhone_TB.height           = 20
$OfficePhone_TB.location         = New-Object System.Drawing.Point(18,92)
$OfficePhone_TB.Font             = 'Microsoft Sans Serif,10'

$Common_Cancle_BT                = New-Object system.Windows.Forms.Button
$Common_Cancle_BT.text           = "Cancle"
$Common_Cancle_BT.width          = 60
$Common_Cancle_BT.height         = 30
$Common_Cancle_BT.location       = New-Object System.Drawing.Point(162,434)
$Common_Cancle_BT.Font           = 'Microsoft Sans Serif,10'
$Common_Cancle_BT.Add_Click({ $CommonForm.Tag = $null; $CommonForm.Close() })

$Label_Description               = New-Object system.Windows.Forms.Label
$Label_Description.text          = "Description"
$Label_Description.AutoSize      = $true
$Label_Description.width         = 25
$Label_Description.height        = 10
$Label_Description.location      = New-Object System.Drawing.Point(24,118)
$Label_Description.Font          = 'Microsoft Sans Serif,10'

$Description_TB                  = New-Object system.Windows.Forms.TextBox
$Description_TB.multiline        = $false
$Description_TB.width            = 100
$Description_TB.height           = 20
$Description_TB.location         = New-Object System.Drawing.Point(19,143)
$Description_TB.Font             = 'Microsoft Sans Serif,10'

$Name_GB                         = New-Object system.Windows.Forms.Groupbox
$Name_GB.height                  = 229
$Name_GB.width                   = 363
$Name_GB.text                    = "Name"
$Name_GB.location                = New-Object System.Drawing.Point(7,20)

$CommonForm.controls.AddRange(@($CommonRun_BT,$CommonRun2_BT))
$CommonForm.controls.AddRange(@($Other_GB,$Givenname_TB,$Label_GivenName,$Label_Surname,$SurName_TB,$Label_Name,$Name_TB,$Label_DisplayName,$DisplayName_TB,$Common_Cancle_BT,$Name_GB))
$Other_GB.controls.AddRange(@($Label_Mail,$Mail_TB,$Label_OfficePhone,$OfficePhone_TB,$Label_Description,$Description_TB))




$CommonForm.ShowDialog()
})

$OganisationAtr_BT               = New-Object system.Windows.Forms.Button
$OganisationAtr_BT.text          = "Organisation Attributes"
$OganisationAtr_BT.width         = 130
$OganisationAtr_BT.height        = 30
$OganisationAtr_BT.location      = New-Object System.Drawing.Point(24,65)
$OganisationAtr_BT.Font          = 'Microsoft Sans Serif,8'
$OganisationAtr_BT.Add_Click({
###################################################################################################
####################################### Functions #################################################
###################################################################################################
Function Change-Organisation_Atr {
try{
    if($Title_TB.Text -ne ""){
    Set-ADUser -Identity $sam.SamAccountName -Title $Title_TB.Text
    }
    if($Office_TB.Text -ne ""){
    Set-ADUser -Identity $sam.SamAccountName -Office $Office_TB.Text
    }
    if($Company_TB.Text -ne ""){
    Set-ADUser -Identity $sam.SamAccountName -Company $Company_TB.Text
    }
    if($Department_TB.Text -ne ""){
    Set-ADUser -Identity $sam.SamAccountName -Department $Department_TB.Text
    }
 }catch{
$ERRORForm                            = New-Object system.Windows.Forms.Form
$ERRORForm.ClientSize                 = '197,130'
$ERRORForm.text                       = "ERROR"
$ERRORForm.TopMost                    = $false

$Label_ERROR                     = New-Object system.Windows.Forms.Label
$Label_ERROR.text                = "An ERROR occured!"
$Label_ERROR.AutoSize            = $true
$Label_ERROR.width               = 25
$Label_ERROR.height              = 10
$Label_ERROR.location            = New-Object System.Drawing.Point(40,45)
$Label_ERROR.Font                = 'Microsoft Sans Serif,10,style=Bold'

$OK_BT                           = New-Object system.Windows.Forms.Button
$OK_BT.text                      = "OK"
$OK_BT.width                     = 60
$OK_BT.height                    = 30
$OK_BT.location                  = New-Object System.Drawing.Point(64,85)
$OK_BT.Font                      = 'Microsoft Sans Serif,10'
$OK_BT.Add_Click({ $ERRORForm.Tag = $null; $ERRORForm.Close() })

$ERRORForm.controls.AddRange(@($Label_ERROR,$OK_BT))
$ERRORForm.ShowDialog()
 }
}


###################################################################################################
##################################### Form begins #################################################
###################################################################################################


$OrganisationForm                            = New-Object system.Windows.Forms.Form
$OrganisationForm.ClientSize                 = '400,290'
$OrganisationForm.text                       = "Organisation"
$OrganisationForm.TopMost                    = $false

$OrganisationRun_BT              = New-Object system.Windows.Forms.Button
$OrganisationRun_BT.text         = "Run"
$OrganisationRun_BT.width        = 60
$OrganisationRun_BT.height       = 30
$OrganisationRun_BT.location     = New-Object System.Drawing.Point(293,39)
$OrganisationRun_BT.Font         = 'Microsoft Sans Serif,10'
$OrganisationRun_BT.Add_Click({ Change-Organisation_Atr })

$OrganisationCancle_BT           = New-Object system.Windows.Forms.Button
$OrganisationCancle_BT.text      = "Cancle"
$OrganisationCancle_BT.width     = 60
$OrganisationCancle_BT.height    = 30
$OrganisationCancle_BT.location  = New-Object System.Drawing.Point(293,87)
$OrganisationCancle_BT.Font      = 'Microsoft Sans Serif,10'
$OrganisationCancle_BT.Add_Click({ $OrganisationForm.Tag = $null; $OrganisationForm.Close() })

$Title_TB                        = New-Object system.Windows.Forms.TextBox
$Title_TB.multiline              = $false
$Title_TB.width                  = 100
$Title_TB.height                 = 20
$Title_TB.location               = New-Object System.Drawing.Point(13,49)
$Title_TB.Font                   = 'Microsoft Sans Serif,10'

$Label_Title                     = New-Object system.Windows.Forms.Label
$Label_Title.text                = "Title"
$Label_Title.AutoSize            = $true
$Label_Title.width               = 25
$Label_Title.height              = 10
$Label_Title.location            = New-Object System.Drawing.Point(18,25)
$Label_Title.Font                = 'Microsoft Sans Serif,10'

$Label_Office                    = New-Object system.Windows.Forms.Label
$Label_Office.text               = "Office"
$Label_Office.AutoSize           = $true
$Label_Office.width              = 25
$Label_Office.height             = 10
$Label_Office.location           = New-Object System.Drawing.Point(18,75)
$Label_Office.Font               = 'Microsoft Sans Serif,10'

$Office_TB                       = New-Object system.Windows.Forms.TextBox
$Office_TB.multiline             = $false
$Office_TB.width                 = 100
$Office_TB.height                = 20
$Office_TB.location              = New-Object System.Drawing.Point(13,100)
$Office_TB.Font                  = 'Microsoft Sans Serif,10'

$LabelCompany                    = New-Object system.Windows.Forms.Label
$LabelCompany.text               = "Company"
$LabelCompany.AutoSize           = $true
$LabelCompany.width              = 25
$LabelCompany.height             = 10
$LabelCompany.location           = New-Object System.Drawing.Point(18,126)
$LabelCompany.Font               = 'Microsoft Sans Serif,10'

$Company_TB                      = New-Object system.Windows.Forms.TextBox
$Company_TB.multiline            = $false
$Company_TB.width                = 100
$Company_TB.height               = 20
$Company_TB.location             = New-Object System.Drawing.Point(13,152)
$Company_TB.Font                 = 'Microsoft Sans Serif,10'

$Label_Department                = New-Object system.Windows.Forms.Label
$Label_Department.text           = "Department"
$Label_Department.AutoSize       = $true
$Label_Department.width          = 25
$Label_Department.height         = 10
$Label_Department.location       = New-Object System.Drawing.Point(18,178)
$Label_Department.Font           = 'Microsoft Sans Serif,10'

$Department_TB                   = New-Object system.Windows.Forms.TextBox
$Department_TB.multiline         = $false
$Department_TB.width             = 100
$Department_TB.height            = 20
$Department_TB.location          = New-Object System.Drawing.Point(13,204)
$Department_TB.Font              = 'Microsoft Sans Serif,10'

$Label_Manager                   = New-Object system.Windows.Forms.Label
$Label_Manager.text              = "Manager"
$Label_Manager.AutoSize          = $true
$Label_Manager.width             = 25
$Label_Manager.height            = 10
$Label_Manager.location          = New-Object System.Drawing.Point(18,230)
$Label_Manager.Font              = 'Microsoft Sans Serif,10'

$Manager_TB                      = New-Object system.Windows.Forms.TextBox
$Manager_TB.multiline            = $false
$Manager_TB.width                = 100
$Manager_TB.height               = 20
$Manager_TB.location             = New-Object System.Drawing.Point(13,254)
$Manager_TB.Font                 = 'Microsoft Sans Serif,10'

$OrganisationForm.controls.AddRange(@($OrganisationRun_BT,$Organisationcancle_BT,$Title_TB,$Label_Title,$Label_Office,$Office_TB,$LabelCompany,$Company_TB,$Label_Department,$Department_TB,$Label_Manager,$Manager_TB))


$OrganisationForm.ShowDialog()
})

$ProfilePath_BT                  = New-Object system.Windows.Forms.Button
$ProfilePath_BT.text             = "Profile Paths"
$ProfilePath_BT.width            = 130
$ProfilePath_BT.height           = 30
$ProfilePath_BT.location         = New-Object System.Drawing.Point(24,110)
$ProfilePath_BT.Font             = 'Microsoft Sans Serif,8'
$ProfilePath_BT.Add_Click({
###################################################################################################
####################################### Functions #################################################
###################################################################################################

Function change-ProfilePaths {
try{
    if($ProfilePath_TB.Text -ne ""){
    Set-ADUser -Identity $sam.SamAccountName -ProfilePath $ProfilePath_TB.Text
    }
    if($HomeDrive_TB.Text -ne ""){
    Set-ADUser -Identity $sam.SamAccountName -HomeDrive $HomeDrive_TB.Text
    }
    if($HomeDirectory_TB.Text -ne ""){
    Set-ADUser -Identity $sam.SamAccountName -HomeDirectory $HomeDirectory_TB.Text
    }
 }catch{
$ERRORForm                            = New-Object system.Windows.Forms.Form
$ERRORForm.ClientSize                 = '197,130'
$ERRORForm.text                       = "ERROR"
$ERRORForm.TopMost                    = $false

$Label_ERROR                     = New-Object system.Windows.Forms.Label
$Label_ERROR.text                = "An ERROR occured!"
$Label_ERROR.AutoSize            = $true
$Label_ERROR.width               = 25
$Label_ERROR.height              = 10
$Label_ERROR.location            = New-Object System.Drawing.Point(40,45)
$Label_ERROR.Font                = 'Microsoft Sans Serif,10,style=Bold'

$OK_BT                           = New-Object system.Windows.Forms.Button
$OK_BT.text                      = "OK"
$OK_BT.width                     = 60
$OK_BT.height                    = 30
$OK_BT.location                  = New-Object System.Drawing.Point(64,85)
$OK_BT.Font                      = 'Microsoft Sans Serif,10'
$OK_BT.Add_Click({ $ERRORForm.Tag = $null; $ERRORForm.Close() })

$ERRORForm.controls.AddRange(@($Label_ERROR,$OK_BT))
$ERRORForm.ShowDialog()
 }
}

###################################################################################################
##################################### Form begins #################################################
###################################################################################################


$ProfilePathForm                            = New-Object system.Windows.Forms.Form
$ProfilePathForm.ClientSize                 = '400,209'
$ProfilePathForm.text                       = "Profile Paths"
$ProfilePathForm.TopMost                    = $false

$Label_ProfilePath               = New-Object system.Windows.Forms.Label
$Label_ProfilePath.text          = "ProfilePath"
$Label_ProfilePath.AutoSize      = $true
$Label_ProfilePath.width         = 25
$Label_ProfilePath.height        = 10
$Label_ProfilePath.location      = New-Object System.Drawing.Point(23,26)
$Label_ProfilePath.Font          = 'Microsoft Sans Serif,10'

$ProfilePath_TB                  = New-Object system.Windows.Forms.TextBox
$ProfilePath_TB.multiline        = $false
$ProfilePath_TB.width            = 100
$ProfilePath_TB.height           = 20
$ProfilePath_TB.location         = New-Object System.Drawing.Point(17,53)
$ProfilePath_TB.Font             = 'Microsoft Sans Serif,10'

$Label_HomeDrive                 = New-Object system.Windows.Forms.Label
$Label_HomeDrive.text            = "HomeDrive"
$Label_HomeDrive.AutoSize        = $true
$Label_HomeDrive.width           = 25
$Label_HomeDrive.height          = 10
$Label_HomeDrive.location        = New-Object System.Drawing.Point(23,79)
$Label_HomeDrive.Font            = 'Microsoft Sans Serif,10'

$HomeDrive_TB                    = New-Object system.Windows.Forms.TextBox
$HomeDrive_TB.multiline          = $false
$HomeDrive_TB.width              = 100
$HomeDrive_TB.height             = 20
$HomeDrive_TB.location           = New-Object System.Drawing.Point(17,106)
$HomeDrive_TB.Font               = 'Microsoft Sans Serif,10'

$Label_HomeDirectory             = New-Object system.Windows.Forms.Label
$Label_HomeDirectory.text        = "HomeDirectory"
$Label_HomeDirectory.AutoSize    = $true
$Label_HomeDirectory.width       = 25
$Label_HomeDirectory.height      = 10
$Label_HomeDirectory.location    = New-Object System.Drawing.Point(22,133)
$Label_HomeDirectory.Font        = 'Microsoft Sans Serif,10'

$HomeDirectory_TB                = New-Object system.Windows.Forms.TextBox
$HomeDirectory_TB.multiline      = $false
$HomeDirectory_TB.width          = 100
$HomeDirectory_TB.height         = 20
$HomeDirectory_TB.location       = New-Object System.Drawing.Point(17,158)
$HomeDirectory_TB.Font           = 'Microsoft Sans Serif,10'

$ProfilePathsRun_BT              = New-Object system.Windows.Forms.Button
$ProfilePathsRun_BT.text         = "Run"
$ProfilePathsRun_BT.width        = 60
$ProfilePathsRun_BT.height       = 30
$ProfilePathsRun_BT.location     = New-Object System.Drawing.Point(280,32)
$ProfilePathsRun_BT.Font         = 'Microsoft Sans Serif,10'
$ProfilePathsRun_BT.Add_Click({ change-ProfilePaths })

$ProfilePathsCancle_BT            = New-Object system.Windows.Forms.Button
$ProfilePathsCancle_BT.text       = "Cancle"
$ProfilePathsCancle_BT.width      = 60
$ProfilePathsCancle_BT.height     = 30
$ProfilePathsCancle_BT.location   = New-Object System.Drawing.Point(280,84)
$ProfilePathsCancle_BT.Font       = 'Microsoft Sans Serif,10'
$ProfilePathsCancle_BT.Add_Click({ $ProfilePathForm.Tag = $null; $ProfilePathForm.Close() })

$ProfilePathForm.controls.AddRange(@($Label_ProfilePath,$ProfilePath_TB,$Label_HomeDrive,$HomeDrive_TB,$Label_HomeDirectory,$HomeDirectory_TB,$ProfilePathsRun_BT,$ProfilePathsCancle_BT))

$ProfilePathForm.ShowDialog()


})

$Enable_BT                  = New-Object system.Windows.Forms.Button
$Enable_BT.text             = "Enable User"
$Enable_BT.width            = 130
$Enable_BT.height           = 30
$Enable_BT.location         = New-Object System.Drawing.Point(24,155)
$Enable_BT.Font             = 'Microsoft Sans Serif,8'
$Enable_BT.Add_Click({ Enable-User })

$Disable_BT                  = New-Object system.Windows.Forms.Button
$Disable_BT.text             = "Disable User"
$Disable_BT.width            = 130
$Disable_BT.height           = 30
$Disable_BT.location         = New-Object System.Drawing.Point(24,200)
$Disable_BT.Font             = 'Microsoft Sans Serif,8'
$Disable_BT.Add_Click({ Disable-User })

$AtrCancle_BT                    = New-Object system.Windows.Forms.Button
$AtrCancle_BT.text               = "Cancle"
$AtrCancle_BT.width              = 60
$AtrCancle_BT.height             = 30
$AtrCancle_BT.location           = New-Object System.Drawing.Point(56,240)
$AtrCancle_BT.Font               = 'Microsoft Sans Serif,8'
$AtrCancle_BT.Add_Click({ $AtrForm.Tag = $null; $AtrForm.Close() })

$AtrForm.controls.AddRange(@($CommonAtr_BT,$Enable_BT,$Disable_BT,$OganisationAtr_BT,$ProfilePath_BT,$AtrCancle_BT))


$AtrForm.ShowDialog()
})

$Change_TS_BT                    = New-Object system.Windows.Forms.Button
$Change_TS_BT.text               = "TS-Profile"
$Change_TS_BT.width              = 70
$Change_TS_BT.height             = 30
$Change_TS_BT.location           = New-Object System.Drawing.Point(114,235)
$Change_TS_BT.Font               = 'Microsoft Sans Serif,9'
$Change_TS_BT.Add_Click({

function Set-TSPro-and-Home {
$TSProfilePath = $TSHome_TB.Text
$TSHomeDirectory = $TSProfile_TB.Text
$TSHomeDrive = "H:" 
$dn = (Get-ADUser -Server EGVDC04 -Identity $sam).DistinguishedName 
$ADSIUserObject = [ADSI]"LDAP://$dn"              
$ADSIUserObject.InvokeSet('TerminalServicesProfilePath',$TSProfilePath)
$ADSIUserObject.InvokeSet('TerminalServicesHomeDirectory',$TSHomeDirectory)
$ADSIUserObject.InvokeSet('TerminalServicesHomeDrive',$TSHomeDrive)
try{
    $ADSIUserObject.SetInfo()}catch{

$ERRORForm                            = New-Object system.Windows.Forms.Form
$ERRORForm.ClientSize                 = '197,130'
$ERRORForm.text                       = "ERROR"
$ERRORForm.TopMost                    = $false

$Label_ERROR                     = New-Object system.Windows.Forms.Label
$Label_ERROR.text                = "An ERROR occured!"
$Label_ERROR.AutoSize            = $true
$Label_ERROR.width               = 25
$Label_ERROR.height              = 10
$Label_ERROR.location            = New-Object System.Drawing.Point(40,45)
$Label_ERROR.Font                = 'Microsoft Sans Serif,10,style=Bold'

$OK_BT                           = New-Object system.Windows.Forms.Button
$OK_BT.text                      = "OK"
$OK_BT.width                     = 60
$OK_BT.height                    = 30
$OK_BT.location                  = New-Object System.Drawing.Point(64,85)
$OK_BT.Font                      = 'Microsoft Sans Serif,10'
$OK_BT.Add_Click({ $ERRORForm.Tag = $null; $ERRORForm.Close() })

$ERRORForm.controls.AddRange(@($Label_ERROR,$OK_BT))
$ERRORForm.ShowDialog()
    }
}


$TSForm                            = New-Object system.Windows.Forms.Form
$TSForm.ClientSize                 = '400,166'
$TSForm.text                       = "TS-Profile and Homedirectory"
$TSForm.TopMost                    = $false

$TSRun_BT                        = New-Object system.Windows.Forms.Button
$TSRun_BT.text                   = "Run"
$TSRun_BT.width                  = 60
$TSRun_BT.height                 = 30
$TSRun_BT.location               = New-Object System.Drawing.Point(291,40)
$TSRun_BT.Font                   = 'Microsoft Sans Serif,10'
$TSRun_BT.Add_Click({
Set-TSPro-and-Home
})

$TsCancle_BT                     = New-Object system.Windows.Forms.Button
$TsCancle_BT.text                = "Cancle"
$TsCancle_BT.width               = 60
$TsCancle_BT.height              = 30
$TsCancle_BT.location            = New-Object System.Drawing.Point(291,101)
$TsCancle_BT.Font                = 'Microsoft Sans Serif,10'
$TsCancle_BT.Add_Click({ $TSForm.Tag = $null; $TSForm.Close() })

$TSProfile_TB                    = New-Object system.Windows.Forms.TextBox
$TSProfile_TB.multiline          = $false
$TSProfile_TB.width              = 100
$TSProfile_TB.height             = 20
$TSProfile_TB.location           = New-Object System.Drawing.Point(35,55)
$TSProfile_TB.Font               = 'Microsoft Sans Serif,10'

$Label_TSProfile                 = New-Object system.Windows.Forms.Label
$Label_TSProfile.text            = "TS-Profile"
$Label_TSProfile.AutoSize        = $true
$Label_TSProfile.width           = 25
$Label_TSProfile.height          = 10
$Label_TSProfile.location        = New-Object System.Drawing.Point(41,30)
$Label_TSProfile.Font            = 'Microsoft Sans Serif,10'

$TSHome_TB                       = New-Object system.Windows.Forms.TextBox
$TSHome_TB.multiline             = $false
$TSHome_TB.width                 = 100
$TSHome_TB.height                = 20
$TSHome_TB.location              = New-Object System.Drawing.Point(35,105)
$TSHome_TB.Font                  = 'Microsoft Sans Serif,10'

$Label_Homedirecotry             = New-Object system.Windows.Forms.Label
$Label_Homedirecotry.text        = "Home Directory"
$Label_Homedirecotry.AutoSize    = $true
$Label_Homedirecotry.width       = 25
$Label_Homedirecotry.height      = 10
$Label_Homedirecotry.location    = New-Object System.Drawing.Point(41,81)
$Label_Homedirecotry.Font        = 'Microsoft Sans Serif,10'

$TSForm.controls.AddRange(@($TSRun_BT,$TsCancle_BT,$TSProfile_TB,$Label_TSProfile,$TSHome_TB,$Label_Homedirecotry))


$TSForm.ShowDialog()

})

$GetUserProperties_BT            = New-Object system.Windows.Forms.Button
$GetUserProperties_BT.text       = "Get-User"
$GetUserProperties_BT.width      = 70
$GetUserProperties_BT.height     = 30
$GetUserProperties_BT.location   = New-Object System.Drawing.Point(19,182)
$GetUserProperties_BT.Font       = 'Microsoft Sans Serif,9'
$GetUserProperties_BT.Add_Click({Get-User-Properties})

$Label_Sam                       = New-Object system.Windows.Forms.Label
$Label_Sam.text                  = "sAMAccountName"
$Label_Sam.AutoSize              = $true
$Label_Sam.width                 = 25
$Label_Sam.height                = 10
$Label_Sam.location              = New-Object System.Drawing.Point(18,20)
$Label_Sam.Font                  = 'Microsoft Sans Serif,9'

$Cancle_BT                       = New-Object system.Windows.Forms.Button
$Cancle_BT.text                  = "Cancle"
$Cancle_BT.width                 = 60
$Cancle_BT.height                = 30
$Cancle_BT.location              = New-Object System.Drawing.Point(481,88)
$Cancle_BT.Font                  = 'Microsoft Sans Serif,9'
$Cancle_BT.Add_Click({ $Form.Tag = $null; $Form.Close() })

$Change_Properties_GB            = New-Object system.Windows.Forms.Groupbox
$Change_Properties_GB.height     = 111
$Change_Properties_GB.width      = 415
$Change_Properties_GB.text       = "Object-Properties"
$Change_Properties_GB.location   = New-Object System.Drawing.Point(11,167)

$GetADUser_GB                    = New-Object system.Windows.Forms.Groupbox
$GetADUser_GB.height             = 126
$GetADUser_GB.width              = 589
$GetADUser_GB.text               = "Get-AD-User"
$GetADUser_GB.location           = New-Object System.Drawing.Point(8,18)

$Clear_BT                        = New-Object system.Windows.Forms.Button
$Clear_BT.text                   = "Clear"
$Clear_BT.width                  = 60
$Clear_BT.height                 = 30
$Clear_BT.location               = New-Object System.Drawing.Point(525,410)
$Clear_BT.Font                   = 'Microsoft Sans Serif,9'
$Clear_BT.Add_Click({$ListBox1.Items.Clear() })

$ListBox1 = New-Object System.Windows.Forms.ListBox 
$ListBox1.Width = 570
$ListBox1.Height = 230
$ListBox1.location = new-object system.drawing.point(15,450)
$ListBox1.Font = "Microsoft Sans Serif,8"
$ListBox1.ScrollAlwaysVisible = $true

$Form.controls.AddRange(@($SetPermissions_GB,$SetAdUserProperties_BT,$Change_TS_BT,$GetUserProperties_BT,$GetUser_BT,$Cancle_BT,$Change_Properties_GB,$GetADUser_GB,$Clear_BT,$ListBox1))
$GetADUser_GB.controls.AddRange(@($sAMAccountName_TB,$Label_Sam))
$Change_Properties_GB.controls.AddRange(@($ChangeOU_BT))
$SetPermissions_GB.controls.AddRange(@($CopyPermisions_BT,$Reference_TB,$Reference_CB))

$Form.ShowDialog()