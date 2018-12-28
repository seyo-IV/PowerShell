#------------------------------------------------------------------------ 
# Author: Sergej Ivanov (Im Auftrag der ECKD Service GmbH) 
# Verwendungszweck: Dieses Script verursacht Unsinn. 
# Datum: 07.11.2018 
#------------------------------------------------------------------------ 
# Errors  : Der Fehler bestand in? 
# 
# Changes : Folgendes wurde verändert 
# 
#------------------------------------------------------------------------ 
# Clear console and set colors
#------------------------------------------------------------------------
cls
[console]::ForegroundColor = "Green"
[console]::BackgroundColor = "black"

do{
# IF is yes clear console
if($swap -eq "Y"){cls}
$URDC = "YOURDC01" #change this to your domain controller
"`
 Wellcome 	[" + $env:Username + "]"
"        ___           ___           ___          _____             
        /  /\         /  /\         /__/|        /  /::\            
       /  /:/_       /  /:/        |  |:|       /  /:/\:\           
      /  /:/ /\     /  /:/         |  |:|      /  /:/  \:\          
     /  /:/ /:/_   /  /:/  ___   __|  |:|     /__/:/ \__\:|         
    /__/:/ /:/ /\ /__/:/  /  /\ /__/\_|:|____ \  \:\ /  /:/         
    \  \:\/:/ /:/ \  \:\ /  /:/ \  \:\/:::::/  \  \:\  /:/          
     \  \::/ /:/   \  \:\  /:/   \  \::/~~~~    \  \:\/:/           
      \  \:\/:/     \  \:\/:/     \  \:\         \  \::/            
       \  \::/       \  \::/       \  \:\         \__\/             
        \__\/         \__\/         \__\/                       `n"
write-host "Options `n
[1] Get-ADUser Properties`n
[2] Set-ADUser Properties`n
[3] Filesystem`n
[4] Export`n
[5] Tools`n
[6] End" -ForegroundColor Yellow
$switch = Read-host "Choose Option"

if($switch -ge 7 ){write-host "[##### Please enter  a valid number #####]" -ForegroundColor Red }
if($switch -eq "1")
{
do{# Query SAMAccountName with Errorhandling
$ErrorActionPreference = "SilentlyContinue"
$sam = read-host "SAMAccountName"
IF($sam -eq ""){Write-warning -Message "Please enter a valid Username"}
$exists = Get-ADUser -Filter {sAMAccountName -eq $sam}
IF($exists -eq $Null){Write-warning -message "User doesn't exist"}
}while(($exists -eq $Null) -or ($sam -eq ""))
do{
#------------------------------------------------------------------------ 
# Presenting Options 
#------------------------------------------------------------------------
    write-host "Options `n
    [1] Get-Member of`n
    [2] Get Profile Paths`n
    [3] Get-Subinfos`n
    [4] End" -ForegroundColor Yellow
    $switch1 = Read-host "Choose Option"
    if($switch1 -eq "1")
        {
#------------------------------------------------------------------------ 
# Setting up Variables 
#------------------------------------------------------------------------
	$ADUser	= Get-ADUser -Identity $sam -Properties memberof | Select-Object -ExpandProperty memberof
	$Count	= $ADUser.count
	Write-Output "Totalcount $Count"
	Write-Output "$sam is member of"
	Write-Output "----------------------------------------------------"
	foreach ($Group in $ADUser)
		{
#------------------------------------------------------------------------ 
# Getting the AD-Groups 
#------------------------------------------------------------------------
		$Gr			= Get-ADGroup -identity $Group
		$GrNa		= $Gr.Name
		Write-Output "$GrNa"
		}
        }
    if($switch1 -eq "2")
        {
		 
#------------------------------------------------------------------------ 
# Collecting Profile and Homedirectory paths 
#------------------------------------------------------------------------
             $dn = (Get-ADUser -Server $URDC -Identity $sam).DistinguishedName 
              $ADSIUserObject = [ADSI]"LDAP://$dn"              
              Get-aduser -Identity $sam -Properties * | select ProfilePath | ft
              $ADSIUserObject.InvokeGet('TerminalServicesProfilePath')
              Get-aduser -Identity $sam -Properties * | select HomeDirectory |ft
              $ADSIUserObject.InvokeGet('TerminalServicesHomeDirectory')
sleep -sec 2
        }
    if($switch1 -eq "3")
        {

#------------------------------------------------------------------------ 
# Get AD-User Properties 
#------------------------------------------------------------------------
        Get-ADUser -Identity $sam -Properties * | select Mail, extensionattribute15, Company, Office, Manager, Department, OfficePhone
		sleep -sec 2
        }
if($switch1 -ge 5 ){write-host "[##### Please enter  a valid number #####]" -ForegroundColor Red }
}until($switch1 -eq "4")
}
if($sam -eq $false){clear-variable sam}
if($switch -eq "2")
{
do{# Query SAMAccountName with Errorhandling
$ErrorActionPreference = "SilentlyContinue"
$sam = read-host "SAMAccountName"
# If sAMAccountName is empty return an error
IF($sam -eq ""){Write-warning -Message "Please enter a valid Username"}
$exists = Get-ADUser -Filter {sAMAccountName -eq $sam}
# If user doesent exist return error
IF($exists -eq $Null){Write-warning -Message "User doesn't exist"}
}while(($exists -eq $Null) -or ($sam -eq ""))
do{
#------------------------------------------------------------------------ 
# Presenting Options
#------------------------------------------------------------------------
    write-host "Options `n
    [1] Change users OU`n
    [2] Set Profile and Home Paths`n
    [3] Set Subinfos`n
    [4] End" -ForegroundColor Yellow
    $switch2 = Read-host "Choose Option"
    if($switch2 -eq "1")
        {
        do{ 
#------------------------------------------------------------------------ 
# Getting the right OU 
#------------------------------------------------------------------------
            $nameou = read-host "Ziel OU eingeben"
			# Searching for OU based on DistinguishedName
            $sou  = (Get-ADOrganizationalUnit -LDAPFilter "(name=$nameou*)" -SearchBase 'OU=User,DC=ad,DC=erzbistum-koeln,DC=de').DistinguishedName
            write-host "[INFO] `t [$sou] was found." -ForegroundColor Yellow # -NoNewline;
			# Confirm of the right OU
            $test = read-host "Bestätigen sie die richtigkeit der angezeichgten OU mit 'Y'`n $"
            If($test -eq "y"){$end = $true}else{$end = $false}
            }until($end -eq $true)
			
#------------------------------------------------------------------------ 
# Setting new OU 
#------------------------------------------------------------------------
            $gou  = (Get-ADUser -Identity $sam).DistinguishedName
			# Move AD-User to new OU
            $mou  = Move-ADObject -Identity $gou -TargetPath $sou
            write-host "Benutzer $sam wurde in die OU $sou verschoben"
        }
    if($switch2 -eq "2")
        {
            
#------------------------------------------------------------------------ 
# Setting Variables for new ProfilePAth and Homedirectory 
#------------------------------------------------------------------------
			# Query for Profilepaths
			$homedrive 		= "H:"
            $homedirectory 	= ((Read-Host "Homedirectory") + $sam)
            $profilepath 	= ((Read-host "Profilepath") + $sam)
			$TSProfilePath  = ((Read-Host "TSProfilepath") + $sam)
			
#------------------------------------------------------------------------ 
# Setting new directory Paths 
#------------------------------------------------------------------------
            Set-ADUser -Identity $sam -replace @{homedirectory=$homedirectory}
            Set-ADUser -Identity $sam -replace @{profilepath=$Profilepath}
            # Setting TS Variables
            $TSHomeDirectory= $homedirectory
            $TSHomeDrive    = $homedrive
            $dn = (Get-ADUser -Server $URDC -Identity $sam).DistinguishedName 
              $ADSIUserObject = [ADSI]"LDAP://$dn"
			# Setting new Paths
              $ADSIUserObject.InvokeSet('TerminalServicesProfilePath',$TSProfilePath)
              $ADSIUserObject.InvokeSet('TerminalServicesHomeDirectory',$TSHomeDirectory)
              $ADSIUserObject.InvokeSet('TerminalServicesHomeDrive',$TSHomeDrive)
              Try   { $ADSIUserObject.SetInfo() }
              Catch { Write-Host "[ERROR]`t Couldn't set the TSProfile & Home Directory Path: $($_.Exception.Message)" }
        }
    if($switch2 -eq "3")
        {
		
#------------------------------------------------------------------------ 
# Setting up variables 
#------------------------------------------------------------------------
		$status         = switch(Read-Host "Zu änderndes Attribut auswählen: `
    1 Raum NR `
    2 Telefon NR `
    3 Manager `
    4 Abteilung
    5 Firma `
    6 Extension Attriute15 `
    7 Vorname `
    8 Nachname `
    9 Anzeigename `
    Mit der entsprechenden Zahl auswählen und mit ENTER bestätigen") 
    {
	
#------------------------------------------------------------------------ 
# Setting new Properties 
#------------------------------------------------------------------------
    1 {$Office = Read-Host "Office"
        Set-ADUser -Identity $sam -Office $Office 
        }
    2 {$phone = Read-Host "Telefon NR"
        Set-ADUser -Identity $sam -OfficePhone $phone
        }
    3 { $manager = Read-Host "Manager"
        Set-ADUser -Identity $sam -manager $manager
        }
    4 { $department = Read-Host "Abteilung"
        Set-ADUser -Identity $sam -Department $department
        }
    5 { $company = Read-Host "Firma"
        Set-ADUser -Identity $sam -Company $company
        }
    6 { $ExAttr = Read-Host "ExtnsionAttribute 15"
        Set-ADUser -Identity $sam -Clear ExtensionAttribute15
		Set-ADUser -Identity $sam -replace @{ExtensionAttribute15=$ExAttr}
        }
    7 { $surname = Read-Host "Vorname"
        Set-ADUser -Identity $sam -Surname $surname
        }
    8 { $givenname = Read-Host "Nachname"
        Set-ADUser -Identity $sam -Givenname $givenname
        }
    9 { $displayname = Read-Host "Anzeigename"
        Set-ADUser -Identity $sam -replace @{DisplayName=$displayname}
        }
    }
        if($switch2 -ge 5 ){write-host "[##### Please enter  a valid number #####]" -ForegroundColor Red }
		}
}until($switch2 -eq "4")
}
if($sam -eq $false){clear-variable sam}
if($switch -eq "3")
{
do{
#------------------------------------------------------------------------ 
# Presenting Options 
#------------------------------------------------------------------------
    write-host "Options `n
    [1] Set-ACL`n
    [2] Get-ACLs on Path`n
    [3] Copy with ACL`n
    [4] End" -ForegroundColor Yellow
    $switch3 = Read-host "Choose Option"
    if($switch3 -eq "1")
        {
#------------------------------------------------------------------------ 
# Setting up Variables
#------------------------------------------------------------------------
        # Query for starting dir and rights
		$StartingDir=Read-Host "What directory do you want to start at?"
        $Right=Read-Host "What ACL right do you want to grant? Valid choices are`
        D	- Delete access
        F	- Full access (Edit_Permissions+Create+Delete+Read+Write)
        N	- No access
        M	- Modify access (Create+Delete+Read+Write)
        RX	- Read and eXecute access
        R	- Read-only access
        W	- Write-only access`
        "
        Switch ($Right) {
          "D" {$Null}
          "F" {$Null}
          "N" {$Null}
          "M" {$Null}
          "RX" {$Null}
          "R" {$Null}
          "W" {$Null}
          default {
            Write-Host -foregroundcolor "Red" `
            `n $Right.ToUpper() " is an invalid choice. Please Try again."`n
            exit
                  }
}
		# Enter user to grant permission
        $Principal=Read-Host "What security principal do you want to grant?" `
        "ACL right"$Right.ToUpper()"to?" `n `
        "Use format domain\username or domain\group"

        write-Host `n "You are about to change permissions on all" `
        "files starting at"$StartingDir.ToUpper() `n "for security"`
        "principal"$Principal.ToUpper() `
        "with new right of"$Right.ToUpper()"."`n ` -ForegroundColor RED
$Title = "Info"
$Info = "Would you like to continue?"
 
$Options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
[int]$DefaultChoice = 0
$Opt =  $host.UI.PromptForChoice($Title , $Info, $Options, $DefaultChoice)

switch($Opt)
{
	0 { 
		Write-Verbose -Message "Yes"
		$Verify = "Y"
	}
	
	1 { 
		Write-Verbose -Message "No"
		$Verify = "N"
	}
}

        if ($Verify -eq "Y") {
#------------------------------------------------------------------------ 
# Setting new ACLs
#------------------------------------------------------------------------
        foreach ($file in $(Get-ChildItem $StartingDir -recurse))
        {
            #display filename and old permissions
            write-Host -foregroundcolor Yellow $file.FullName
            iCACLS $file.FullName
        
            #ADD new permission with CACLS
            iCACLS $file.FullName /grant "${Principal}:${Right}"  >$NULL
  
            #display new permissions
            Write-Host -foregroundcolor Green "New Permissions"
            iCACLS $file.FullName
        }
        }
        }
    if($switch3 -eq "2")
        {
		
#------------------------------------------------------------------------ 
# setting up variables 
#------------------------------------------------------------------------
        $Path = read-host "Enter UNC-Path"
#------------------------------------------------------------------------ 
# Locating directory path 
#------------------------------------------------------------------------

$ErrorActionPreference = "SilentlyContinue"
$Folders = $Path -Split "\\"
$Plist	 = $Folders | % { $i = 0 } { $Folders[0..$i] -Join "\" -Replace ":$", ":\"; $i++ } 
# Searching for ACLs for each directory
$FList   = foreach($dir in $Plist)
	{
    Resolve-Path -Path $dir
	Get-Item $dir | select FullName
	Get-Acl -Path $dir -Filter Access | Select-Object -ExpandProperty Access | Where-Object {$_.IdentityReference -like "EBK\*"} | Select-Object IdentityReference
    }
	
$Flist | ft FullName, IdentityReference
        }
    if($switch3 -eq "3")
        {
#------------------------------------------------------------------------ 
# Setting up Variables
#------------------------------------------------------------------------		
        $path1 			= Read-Host "Source"
		$path2 			= Read-Host "Destination"
		$Ask			= Read-Host "[INFO]
			Want to exclude files etc?
			Type [Y/N]"
			
#------------------------------------------------------------------------ 
# Mirroring source to destination 
#------------------------------------------------------------------------

	If($Ask -eq "y")
		{
		# Copy files except the excluded one
		$Exclude		= Read-Host "Exclude Filename [Name only!]"
		robocopy $path1 $path2 /COPYALL /S /E /R:1 /W:5 /XD $Exclude
		}
		else
		{
		# Copy files
		robocopy $path1 $path2 /COPYALL /S /E /R:1 /W:5
		}
        }
		if($switch3 -ge 5 ){write-host "[##### Please enter  a valid number #####]" -ForegroundColor Red }
}until($switch3 -eq "4")
}
if($switch -eq "4")
{
do{
#------------------------------------------------------------------------ 
# Presenting Options
#------------------------------------------------------------------------
    write-host "Options `n
    [1] Export grouplist (User or Group)`n
    [2] Export groupmember Mail`n
    [3] Export groupmember Displayname`n
    [4] End" -ForegroundColor Yellow
    $switch4 = Read-host "Choose Option"
    if($switch4 -eq "1")
        {
#------------------------------------------------------------------------ 
# Setting up variables
#------------------------------------------------------------------------
        Import-Module ActiveDirectory -ErrorAction Stop 
$error.clear()
$Source = Read-Host "Name eingeben"
$UOG	= Read-Host "User[u], Gruppe[g] oder Gruppe(MemeberOf)[gm] `
[Choose option]"
$Path   = "\\EGVFS02\IT$\ScriptRepository\Logs\Export\"
$log    = $path + $Source + ".log"
$ErrorActionpreference = "SilentlyContinue"

#------------------------------------------------------------------------ 
# Exporting grouplist 
#------------------------------------------------------------------------

		If ($UOG -eq "u")
	{
	# Getting users groupmembership
	$ADUser	= Get-ADUser -Identity $Source -Properties memberof | Select-Object -ExpandProperty memberof
	$Count	= $ADUser.count
	Write-Output "Totalcount $Count" | Out-File $log -append
	Write-Output "$Source is member of" | Out-File $log -append
	Write-Output "----------------------------------------------------"	| Out-File $log -append
	foreach ($Group in $ADUser)
		{
		# Printing the groups name
		$Gr			= Get-ADGroup -identity $Group
		$GrNa		= $Gr.Name
		Write-Output "$GrNa" | Out-File $log -append
		}
	}
		If ($UOG -eq "g")
	{
	# Getting group groupmembers
	$ADGroup	= Get-ADGroup -Identity $Source -Properties member | Select-Object -ExpandProperty member
	$Count	= $ADGroup.count
	Write-Output "Totalcount $Count" | Out-File $log -append
	Write-Output "The following user/groups are member of $Source" | Out-File $log -append
	Write-Output "----------------------------------------------------" | Out-File $log -append
	foreach ($Obj in $ADGroup)
		{
		# Printing the user names
		$error.clear()
		$Gr0		= Get-ADUser -identity $Obj
		if($error -ne "")
			{
			$Gr0	= Get-ADGroup -identity $Obj
			}
		$GrNa0		= $Gr0.Name
		Write-Output "$GrNa0" | Out-File $log -append
		} 
	
	}
		If ($UOG -eq "gm")
	{
	# Getting group groupmembership
	$ADGroupMemo= Get-ADGroup -Identity $Source -Properties memberof | Select-Object -ExpandProperty memberof
	$Count	= $ADGroupMemo.count
	Write-Output "Totalcount $Count" | Out-File $log -append
	Write-Output "The following groups are member of $Source" | Out-File $log -append
	Write-Output "----------------------------------------------------" | Out-File $log -append
	foreach ($Groups in $ADGroupMemo)
		{
		# Printing the group names
		$Gr01		= Get-ADGroup -identity $Groups
		$GrNa01		= $Gr01.Name
		Write-Output "$GrNa01" | Out-File $log -append
		} 
	}
	$Err0r	= $error.count
	"[INFO] Export to $log"
	"Errors:	$Err0r"

        }
    if($switch4 -eq "2")
        {
		
#------------------------------------------------------------------------ 
# Setting up Variables
#------------------------------------------------------------------------

        $source = Read-Host "Source"
$Path   = "\\EGVFS02\IT$\ScriptRepository\Logs\Export\"
$log    = $path + $Source + ".log"
$ErrorActionpreference = "SilentlyContinue"

#------------------------------------------------------------------------ 
# Exporting list
#------------------------------------------------------------------------
# Getting AD-Group member
	$ADGroup	= Get-ADGroup -Identity $Source -Properties member | Select-Object -ExpandProperty member
	$Count	= $ADGroup.count
	Write-Output "Totalcount $Count" | Out-File $log -append
	Write-Output "The following user/groups are member of $Source" | Out-File $log -append
	Write-Output "----------------------------------------------------" | Out-File $log -append
	foreach ($Obj in $ADGroup)
		{
		# Printing AD-Group members E-Mail
		$error.clear()
		$Gr0		= Get-ADUser -identity $Obj -Properties *
		if($error -ne "")
			{
			$Gr0	= Get-ADGroup -identity $Obj -Properties *
			}
		$GrNa0		= $Gr0.Mail
		Write-Output "$GrNa0" | Out-File $log -append
		}
	$Err0r	= $error.count
	"[INFO] Export to $log"
	"Errors:	$Err0r" 
        }
    if($switch4 -eq "3")
        {
		
#------------------------------------------------------------------------ 
# Setting up Variables
#------------------------------------------------------------------------

        $source = Read-Host "Source"
$Path   = "\\EGVFS02\IT$\ScriptRepository\Logs\Export\"
$log    = $path + $Source + ".log"
$ErrorActionpreference = "SilentlyContinue"

#------------------------------------------------------------------------ 
# Exporting list
#------------------------------------------------------------------------
	# Getting AD-Group member
	$ADGroup	= Get-ADGroup -Identity $Source -Properties member | Select-Object -ExpandProperty member
	$Count	= $ADGroup.count
	Write-Output "Totalcount $Count" | Out-File $log -append
	Write-Output "The following user/groups are member of $Source" | Out-File $log -append
	Write-Output "----------------------------------------------------" | Out-File $log -append
	foreach ($Obj in $ADGroup)
		{
		# Printing AD-Group member DisplayNames
		$error.clear()
		$Gr0		= Get-ADUser -identity $Obj -Properties *
		if($error -ne "")
			{
			$Gr0	= Get-ADGroup -identity $Obj -Properties *
			}
		$GrNa0		= $Gr0.Displayname
		Write-Output "$GrNa0" | Out-File $log -append
		} 
	$Err0r	= $error.count
	"[INFO] Export to $log"
	"Errors:	$Err0r"
        }
		if($switch4 -ge 5 ){write-host "[##### Please enter  a valid number #####]" -ForegroundColor Red }
}until($switch4 -eq "4")
}
if($switch -eq "5")
{

do{
    write-host "Options `n
    [1] Passwordgenerator`n
    [2] Port Scanner`n
    [3] Get-Serverinfo`n
    [4] End" -ForegroundColor Yellow
    $switch5 = Read-host "Choose Option"
    if($switch5 -eq "1")
        {

#------------------------------------------------------------------------ 
# Setting up Variables
#------------------------------------------------------------------------
		
	$passwd = Read-Host "Options Passwordlenght`
	[1] = Lenght 08
	[2] = Lenght 16
	[3] = Lenght 24"
	
#------------------------------------------------------------------------ 
# Creating Function
#------------------------------------------------------------------------

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

#------------------------------------------------------------------------ 
# Generating new Password
#------------------------------------------------------------------------

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
    if($switch5 -eq "2")
        {

#------------------------------------------------------------------------ 
# Setting up Variables
#------------------------------------------------------------------------

function Test-Port
{$computer=Read-Host "Computername | IP Address?"
 $port=Read-Host "Port Numbers? Separate them by comma"
 
#------------------------------------------------------------------------ 
# Executing portscan
#------------------------------------------------------------------------

 $port.split(',') | Foreach-Object -Process {If (($a=Test-NetConnection $computer -Port $_ -WarningAction SilentlyContinue).tcpTestSucceeded -eq $true) {Write-Host $a.Computername $a.RemotePort -ForegroundColor Green -Separator " open "} else {Write-Host $a.Computername $a.RemotePort -Separator " closed " -ForegroundColor Red}}
 }
 test-Port
		}
    if($switch5 -eq "3")
        {
		$error.clear()
		$ErrorActionPreference = "SilentlyContinue"

#------------------------------------------------------------------------ 
# Setting up Variables
#------------------------------------------------------------------------

$Servers = @()
do {
 $input = (Read-Host "Please enter the computer name")
 if ($input -ne '') {$Servers += $input}
}
until ($input -eq '')
#------------------------------------------------------------------------ 
# Run the commands for each server in the list
#------------------------------------------------------------------------

$infoColl = @()
Foreach ($s in $servers)
{
	$CPUInfo = Get-WmiObject Win32_Processor -ComputerName $s #Get CPU Information
	$OSInfo = Get-WmiObject Win32_OperatingSystem -ComputerName $s #Get OS Information
	#Get Memory Information. The data will be shown in a table as MB, rounded to the nearest second decimal.
	$OSTotalVirtualMemory = [math]::round($OSInfo.TotalVirtualMemorySize / 1MB, 2)
	$OSTotalVisibleMemory = [math]::round(($OSInfo.TotalVisibleMemorySize / 1MB), 2)
	$PhysicalMemory = Get-WmiObject CIM_PhysicalMemory -ComputerName $s | Measure-Object -Property capacity -Sum | % { [Math]::Round(($_.sum / 1GB), 2) }
	If($error -ne ""){$s + " couldn't be scanned"}
	Foreach ($CPU in $CPUInfo)
	{
		$infoObject = New-Object PSObject
		#The following add data to the infoObjects.	
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "ServerName" -value $CPU.SystemName
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Processor" -value $CPU.Name
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Model" -value $CPU.Description
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Manufacturer" -value $CPU.Manufacturer
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "PhysicalCores" -value $CPU.NumberOfCores
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "CPU_L2CacheSize" -value $CPU.L2CacheSize
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "CPU_L3CacheSize" -value $CPU.L3CacheSize
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Sockets" -value $CPU.SocketDesignation
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "LogicalCores" -value $CPU.NumberOfLogicalProcessors
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "OS_Name" -value $OSInfo.Caption
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "OS_Version" -value $OSInfo.Version
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalPhysical_Memory_GB" -value $PhysicalMemory
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalVirtual_Memory_MB" -value $OSTotalVirtualMemory
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalVisable_Memory_MB" -value $OSTotalVisibleMemory
		$infoObject #Output to the screen for a visual feedback.
		$infoColl += $infoObject
	}
	}

        }
		if($switch5 -ge 5 ){write-host "[##### Please enter  a valid number #####]" -ForegroundColor Red }
}until($switch5 -eq "4")
}





if($switch -ne "6")
{
$Title = "Info"
$Info = "Are you done?"
 
$Options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
[int]$DefaultChoice = 0
$Opt =  $host.UI.PromptForChoice($Title , $Info, $Options, $DefaultChoice)

switch($Opt)
{
	0 { 
		Write-Verbose -Message "Yes"
        $swap = "Y"
	}
	
	1 { 
		Write-Verbose -Message "No" 
        $swap = "N"
	}
}

}
}until($switch -eq "6")
