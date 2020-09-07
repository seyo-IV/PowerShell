$ErrorActionPreference = "SilentlyContinue"
$user = $env:USERNAME
$date = Get-Date -Format ddMMyyyy
$i = 0

function ProcessingAnimation($scriptBlock) {
    $cursorTop = [Console]::CursorTop
    
    try {
        [Console]::CursorVisible = $false
        
        $counter = 0
        $frames = 'Start in: 5', 'Start in: 4', 'Start in: 3', 'Start in: 2', 'Start in: 1' 
        $jobName = Start-Job -ScriptBlock $scriptBlock
    
        while($jobName.JobStateInfo.State -eq "Running") {
            $frame = $frames[$counter % $frames.Length]
            
            Write-Host "$frame" -NoNewLine
            [Console]::SetCursorPosition(0, $cursorTop)
            
            $counter += 1
            Start-Sleep -seconds 1
        }
        
        # Only needed if you use a multiline frames
        Write-Host ($frames[0] -replace '[^\s+]', ' ')
    }
    finally {
        [Console]::SetCursorPosition(0, $cursorTop)
        [Console]::CursorVisible = $true
    }
}

if(Get-Module -ListAvailable -Name ImportExcel){
    Write-Host "[OK]`t  ImportExcel module is not installed or imported." -ForegroundColor Green
    }
else{
    Write-Host "[ERROR]`t  ImportExcel Module not installed!" -ForegroundColor Red

$Title = "Info"
$Info = "Install ImportExcel?"
 
$Options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Ja", "&Nein")
[int]$DefaultChoice = 0
$Opt =  $host.UI.PromptForChoice($Title , $Info, $Options, $DefaultChoice)

switch($Opt)
{
	0 { 
		Write-Verbose -Message "Yes"
        Install-Module -Name ImportExcel -Scope CurrentUser -Confirm:$false
	}
	
	1 { 
		Write-Verbose -Message "No"
        exit 
	}
}
Write-Host "[INFO]`t  ImportExcel is installed." -ForegroundColor Cyan

try{Write-Host "[INFO]`t  Importing ImportExcel module." -ForegroundColor Cyan; Import-Module ImportExcel}catch{Write-Host "[ERROR]`t  Couldnt import module." -ForegroundColor Red; exit}

    }

if($global:defaultviserver -eq $null)
    {
    Write-Host "[WARNUNG]`t  Need connection to VIServer." -ForegroundColor Yellow
    $VIS = Read-Host "Enter VIServer name"
    Connect-VIServer $VIS
    if($global:defaultviserver -ne $null)
        {
        Write-Host "[OK]`t  Connection to VIServer successful." -ForegroundColor Green
        }
    else
        {
        Write-Host "[ERROR]`t  Connection to VIServer failed." -ForegroundColor Red
        Write-Host "[INFO]`t  Script will stop!" -ForegroundColor Cyan
        Write-Output -InputObject "Press any key to continue..."
        [void]$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
        }
    }
else
    {
Write-Host "[INFO]`t  Already connected to VIServer." -ForegroundColor Cyan
    }
Write-Host "[INFO]`t  starting export." -ForegroundColor Cyan
ProcessingAnimation {sleep -sec 4}
  $report = Get-View -viewtype virtualmachine -Property Name,Guest,
  'Runtime.PowerState',
  'Guest.GuestFullName',
  'Guest.IpAddress',
  'Config.Hardware.NumCPU',
  'Config.Hardware.MemoryMB',
  'Summary.Storage.Committed',
  'Summary.Storage.Uncommitted' |
      Select-Object Name,
          @{ n = 'State'; e = { $PSItem.Runtime.PowerState }},
          @{ n = 'OS'; e = { $PSItem.Guest.GuestFullName }},
          @{ n = 'IPV4'; e = { $PSItem.Guest.IpAddress }},
          @{ n = 'Cores'; e = { $PSItem.Config.Hardware.NumCPU }},
          @{ n = 'RAM'; e = { '{0:N0} GB' -f ($PSItem.Config.Hardware.MemoryMB/1024) }},
          @{ n = 'Space_Avaliable'; e = { '{0:N0} GB' -f  (($PSItem.Summary.Storage.Committed + $PSItem.Summary.Storage.Uncommitted)/1gb)  }},
          @{ n = 'Space_Used'; e = { '{0:N0} GB' -f  ($PSItem.Summary.Storage.Committed/1gb)  }}
    $xlfile = "C:\Users\$user\Documents\VMWareReport_$($VIS)_$date.xlsx"
    $report | select-Object Name, State, OS, IPv4, Cores, RAM, Space_Avaliable, Space_Used | Export-Excel $xlfile -AutoSize -StartRow 1 -TableName VMWare

    Write-Host "[INFO]`t  Excelfile exported to [$xlfile]" -ForegroundColor Cyan
    Start-Sleep -sec 6
