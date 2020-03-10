## Read initial username
$InitialName = $env:USERNAME
$LogDate = Get-Date -format ddMMyyyy

try{Import-Module ActiveDirectory}
catch{[System.Windows.Forms.MessageBox]::Show('Module couldnt be loaded', 'Error', 'Ok', 'Error')
try{$Dir = (get-item $PSScriptRoot).parent.FullName;  ; Import-Module "$Dir\0_data\ActiveDirectory" -Force}
catch{[System.Windows.Forms.MessageBox]::Show('Local module couldnt be loaded', 'Error', 'Ok', 'Error')
}
}

try{Import-Module PSReadline}
catch{[System.Windows.Forms.MessageBox]::Show('Module couldnt be loaded', 'Error', 'Ok', 'Error')
try{$Dir = (get-item $PSScriptRoot).parent.FullName;  ; Import-Module "$Dir\0_data\PSReadline" -Force}
catch{[System.Windows.Forms.MessageBox]::Show('Local module couldnt be loaded', 'Error', 'Ok', 'Error')
}
}

$LogPath = \\SERVER\SHARE ## Change this!!

Function GD {

return (get-date)

}

Function PS-Log {
Param
(
[Parameter(Mandatory=$true)]
    [string]$Permission
)
 if($UN -eq $null)
    {
    $user = $env:USERNAME
    $HostName = hostname

    $date = $LogDate
	
    Write-Output "User: $user; Host: $HostName; Permission: $Permission; Log: History `n" | Out-File "$LogPath\PS-Log_$date.log" -Append
    Write-Output $PSHistory | Out-File "$LogPath\PS-Log_$date.log" -Append
    }
else
    {
    $user = $UN
    $HostName = hostname
    $date = $LogDate
	
    Write-Output "User: $user; Host: $HostName; Permission: $Permission; Log: History `n" | Out-File "$LogPath\PS-Log_$date.log" -Append
    Write-Output $PSHistory | Out-File "$LogPath\PS-Log_$date.log" -Append    }
}

Function CMD-Log {
Param
(
[Parameter(Mandatory=$true)]
    [string]$Permission
)
 if($UN -eq $null)
    {
    $user = $env:USERNAME
    $HostName = hostname

    $date = $LogDate
	
    Write-Output "User: $user; Host: $HostName; Permission: $Permission; Log: History `n" | Out-File "$LogPath\CMD-Log_$date.log" -Append
    Write-Output $CMDHistory | Out-File "$LogPath\CMD-Log_$date.log" -Append
    }
else
    {
    $user = $UN
    $HostName = hostname
    $date = $LogDate
	
    Write-Output "User: $user; Host: $HostName; Permission: $Permission; Log: History `n" | Out-File "$LogPath\CMD-Log_$date.log" -Append
    Write-Output $CMDHistory | Out-File "$LogPath\CMD-Log_$date.log" -Append
    }
}

 Function Tool-Log {
 Param
(
[Parameter(Mandatory=$true)]
    [string]$Permission
)
 if($UN -eq $null)
    {
    $user = $env:USERNAME
    $HostName = hostname
    $date = $LogDate
    Write-Output "User: $user; Host: $HostName; Permission: $Permission; Log: Tool `n $Tool" | Out-File "$LogPath\Tool-Log_$date.log" -Append
    }
else
    {
    $user = $UN
    $HostName = hostname
    $date = $LogDate
    Write-Output "User: $user; Host: $HostName; Permission: $Permission; Log: Tool `n $Tool" | Out-File "$LogPath\Tool-Log_$date.log" -Append
    }
}


 Function Permission-Log {
 Param
(
[Parameter(Mandatory=$true)]
    [string]$Permission,
	[string]$ADUser
)
 if($UN -eq $null)
    {
    $user = $env:USERNAME
    $HostName = hostname
    $date = $LogDate
    Write-Output "User: $user; Host: $HostName; Permission: $Permission; Log: Permission `n Lokale Admin Rechte vergeben für $ADUser" | Out-File "$LogPath\Permission-Log_$date.log" -Append
    }
else
    {
    $user = $UN
    $HostName = hostname
    $date = $LogDate
    Write-Output "User: $user; Host: $HostName; Permission: $Permission; Log: Permission `n Lokale Admin Rechte vergeben $ADUser" | Out-File "$LogPath\Permission-Log_$date.log" -Append
    }
}

Function File-Log {
Param
(
[Parameter(Mandatory=$true)]
    [string]$Permission,
	[string]$User
)

 if($UN -eq $null)
    {
    $user = $env:USERNAME
    $HostName = hostname
    $date = $LogDate
    Write-Output "User: $user; Host: $HostName; Permission: $Permission; Log: File `n Datei wurde geöffnet: $($File.FileName)" | Out-File "$LogPath\File-Log_$date.log" -Append
    }
else
    {
    $user = $UN
    $HostName = hostname
    $date = $LogDate
    Write-Output "User: $user; Host: $HostName; Permission: $Permission; Log: File `n Datei wurde geöffnet: $($File.FileName)" | Out-File "$LogPath\File-Log_$date.log" -Append
    }

}


## Get current user
Function Iam {

if($UN -eq $null){$TempUN = $env:USERNAME}else{$TempUN = $UN}
return $TempUN

}

## check if you are the initial user
Function Init {

if($initialName -eq (Iam)){return $true}else{return $false}

}


## Check if credentaisl are valid
Function Cred-Check {

 $username = $Credentials.username
 $password = $Credentials.GetNetworkCredential().password

 # Get current domain using logged-on user's credentials
 $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
 $domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UserName,$Password)

if ($domain.name -eq $null)
{
 return $false
}
else
{
 return $true
}

}

Function User-Exist {

$exists = Get-ADUser -LDAPFilter "(sAMAccountName=$($User_TB.Text))"
if($exists -ne $null){return $true}
}

## Check if user is in the AD-Admin group
Function Check-Local-Admin {

if($UN -eq $null)
    {
    $user = $env:USERNAME
	$GrpName = "SERVER ADMIN GRP" ## Change this!!
        $GrpMember = (Get-ADGroup $GrpName -Properties member).member
            foreach($member in $GrpMember)
                {
                
                $GrpMemberSam += (Get-ADUser -filter * -SearchBase $member).SamAccountName
                   if($user -in $GrpMemberSam){return $true}

                }
    }
else
    {
    $user = $UN
	$GrpName = "AD ADMIN GRP"
        $GrpMember = (Get-ADGroup $GrpName -Properties member).member
            foreach($member in $GrpMember)
                {
                
                $GrpMemberSam += (Get-ADUser -filter * -SearchBase $member).SamAccountName
                   if($user -in $GrpMemberSam){return $true}

                }
    }
}

## Check if tool login was successful
Function Check-Login {
$LoginCheck = $null

    if($Login_TB.Text -ne "!QAY2wsx") ## Change this, its the Apps password!!
        {
        [System.Windows.Forms.MessageBox]::Show('Please enter a valid password!', 'Error', 'Ok', 'Error')
        $LoginCheck = $false
        $Login_TB.Text = ""
        $Login_LB2.Text = "X"
        $Login_LB2.ForeColor = "Red"
        
        }
        else
        {
        $LoginCheck = $true
        }
if($LoginCheck -eq $true)
    {

    $Login_LB2.Text = "✓"
    $Login_LB2.ForeColor = "Green"
    sleep -sec 1


if($Check -eq $true)
    {
	
        #################################################################################
		if((Iam) -match "ADMINPREFIX*") ### Change this!!
		{
		
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$ReqForm                            = New-Object system.Windows.Forms.Form
$ReqForm.ClientSize                 = '400,73'
$ReqForm.text                       = "Admin Permission"
$ReqForm.TopMost                    = $false
$ReqForm.FormBorderStyle = "FixedDialog"
$ReqForm.MaximizeBox = $false
$ReqForm.MinimizeBox = $false
$ReqForm.StartPosition = "CenterScreen"

$Request_BT                      = New-Object system.Windows.Forms.Button
$Request_BT.text                 = "Request"
$Request_BT.width                = 80
$Request_BT.height               = 30
$Request_BT.location             = New-Object System.Drawing.Point(284,25)
$Request_BT.Font                 = 'Microsoft Sans Serif,10'
$Request_BT.Add_Click({

if((User-Exist) -eq $true)
{
        # Windows User
        $CurrentUser = $User_TB.Text
        $Computername = $env:computername
		$ADMGroup = "AD ADMIN GRP" ## Change this!!
        #
		Add-ADGroupMember -identity $ADMGroup -Members $CurrentUser	
		Permission-Log -Permission Admin -ADUser $CurrentUser
			
			
			[System.Windows.Forms.MessageBox]::Show("Task complete.", 'Permission', 'Ok', 'Information')
            $ReqForm.Tag = $null; $ReqForm.Close()
			Set-Variable -Name LoginComplete -Value $true -Scope global
}
else
{
Set-Variable -Name LoginComplete -Value $false -Scope global
[System.Windows.Forms.MessageBox]::Show("User doesen't exist", 'Error', 'Ok', 'Error')
}


})

$User_TB                         = New-Object system.Windows.Forms.TextBox
$User_TB.multiline               = $false
$User_TB.width                   = 100
$User_TB.height                  = 20
$User_TB.location                = New-Object System.Drawing.Point(23,36)
$User_TB.Font                    = 'Microsoft Sans Serif,10'
$User_TB.Add_KeyDown({
    If($_.KeyCode -eq 'Enter')  {
        $_.SuppressKeyPress = $true
        $Request_BT.PerformClick()
    }
})

$User_LB                         = New-Object system.Windows.Forms.Label
$User_LB.text                    = "Username"
$User_LB.AutoSize                = $true
$User_LB.width                   = 25
$User_LB.height                  = 10
$User_LB.location                = New-Object System.Drawing.Point(29,12)
$User_LB.Font                    = 'Microsoft Sans Serif,10'

## PowerShell Icon
$iconBase64      = 'AAABAAEAAAAAAAEAIAC4KAAAFgAAAIlQTkcNChoKAAAADUlIRFIAAAEAAAABAAgGAAAAXHKoZgAAKH9JREFUeNrt3Xl8lNd18PHffWZG+4YQkhCbQIAxxgbjLd6NjeO9ado0TdLF3dI0Sd04iW2cOLHBaWzj2Emc1O2bNmnfpE2bN2vt4B2M93hHGIzBBiyQQCAh0L7O3PP+8cxIArNomZk7Mzrfzwd7YEYzV3fmOXOf+5x7LiillFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSanSM6wbEW+DWdQgGRMbUEYJBIPrf2D/K0CMMh/Waib2WGfbYYffb4T9w1DYN3e+/5ujaPZLfaTzk8J4Y5evLmNsQv16YgAyIF0RE4O5LTvTQ9OatWIv/cfEO+3dBPIPJAnKBbCAQfZCJ/oAMPhTERP8uGBEQM3S0it+TBoaO59h9NhoAho4T//Ygi7GIib6q+P90GCNmKOjIUaLEmI8FLw7HUQQvehiP/qk8BG+MTbBuPpvpfDwIIOJZS9iI8T74q1gJ4pkIdvWl6f0Le7euw1j/Qykm9mvYAjCzgYXRP7OBqUAJkA9k4QeAAP5BGAsCsQPSHufvMsr7YmScf489/5EEiIygqyKMPwiM5HWOJRZwR8vgv09jfU1vjD871td0zQJhoB/oBNqBJqARqAN2gmkE6QcIGsOAFeTey9IsAKxcidd7oX9bwAhBMZwKXA0sxz/wJ5O+b6RS8SRAD7AfqAV+CzwCNA2ddqYJc+tajP91jw1Y40W8c4C/xT/4K1y3T6k0EAFeAVZKpO8pE8hOjwDgrViH9brwbD5AGfAP+Ae/HvhKjd5e4NMY82jKBwBvxTowg7P6C4H7gKtct0upNPc68LGUPlc2K9aDFYwfppYC/w5c5LpdSmWACqAx6LoVx2Owsfnc+cD/Ac5w3SalMkQAuDplRwDeretiN0uAfwIuc90mpTJM9livlyZU4MbnAChszQb4LPB7rtukVAaanJIBQHL6QaCjpO9M4O8Ze2KHUurYslLvwLr1qWhirgkBnweqXDdJqQw1kHIBwLPRaQkjZ6NDf6USqSPlAgAIYo0BPgmUum6NUhmsOaUCgPeVp8GA8WQOmuyjVKLtSakAkFWaHbu5DKh23R6lMtx7KRUA+pt7QQgCl6Mz/0olUgTYkjqZgDc8GlubOAM4y3VzlMpwXcDWlPmW9fJzYjeXANNdt0epDLcf2J4yAUCGFv2cBYRct0epDLcT2J8yAQADVshFF/wolQybge6UmQOIFiaoxF/5l7H8sp9+mT7jGQJ+4MPaaOk+Y/BSvkqDSnMWv0QYKREAvFsGV/7NI0Or/MQO/JK8IKdWFHDGtALmlOZQmB2kL2xpaO9jY2MXb+7pYG97P4LgGY0EKiFagXcgRQKAWDB+BvBi/DLeGcVaobwwi99fWMYnTpvC4qkFFOUECAw7wAXoGYiwvaWXX29u5qe1Tew42IMxJj3qtql0Ug/sghQJACZgQAhg5HTXbYknEQh4hqtOLuWmC2dw7sxCQgEPawURCB+xBUBWwOPUinxOqcjjDxdN4b7n6/nFpgP0hq2eFqh42orhEJIiAcCv8c0k/Jp/GcGKUJIT5Mbzp/P5c6sozQsRsULEHr9MfyQaFBZV5PPgR+ZxelUBdz2zmwNdA3pKoOKlFiEiJhXq53/2JUx2GOBk/LX/aX8KYEWYVpTN/VfX8JlzqsjL8rCj3J5DgFDAcPb0ImaV5PC7+g7a+8IYDQJqfPqA7wHvxdJunQqWt2N7QwCn4Jf/SmtWhBnFOXzvurlcd3Lp0Tf7GqHYz338tCkEPMMXfrudfZ39OhJQ49EEvAsgq5e7z7e3vVlgBOB00jz/XwRK80Ksvmo21508GSvx2eTSCvzBKWXcfeUcJuWGRj2aUGqYnfhbhgEpccAJiMkDTnPdkvEKeIYbz5vGHy6agh3r1/5xfGpxOV+/dBb5Wd6YRxVqwtsURLpiH58UCACAv4nnXNeNGA9rhfNnFfG3Z08lkIARugCegc+cPZUvXTCdUGDs23arCUuA2jCGjav9IttOA4AZSgCaD5Q77Zpxygp6/OWZlZQXZCVsiC5AVtBw04Uz+PTZU1Mmequ00Q68DXDabeuB1BkBLAZyxv0sjlgR5pTmcPHs4oQM/YcTgfwsjzsum8Ufn1aupwJqNPbgbxcO31wGuB4B+EPlIP4S4PQlsLA8n4oEfvsPZwVKc0PcfeVsrjqpNOFBR2WMrQgtw88dU2EEUEoGJABVFWURSmK6nhVhelE2919Tw/mziocWEyl1bBsxDAw/6t0FgJueiN2ahV8FKK2Zwf8kT0SE+WW5fPfauZw6tUCDgDqefmAj4O+7EeUsAGRnF8VuLgKK3fVLfOzr7CccSf4BGLHC0mkFPHBtDXMm5+rpgDqWFmAbgF196eA/OgsA/eEuAuKBnwCU3qltBt490MPBnjAukvQiVrhodgn3XT2HysIsDQLqaN4H2XtkapqzAGAwRIzNJwMSgIwx7GjpoXZv52FLfJPJinDdgsnc9eHZlOQGNVtQHWlzINTXfuRXretJwCqgxnEbxs0AnX0Rfrm5mb6wddqWP1lSwdeWzSIvpNmC6jC1kYEcbM/ha+2cBIDAUALQScAUt/0SH8YY1mw9yMv1HQQcLd6PZQt+9pwqvqjZgmpIB34NQEzWwGF3uBkBmMGP5RIge+xPlDqMgebOfr7zQgOtjuYCYChb8OaLpvPXZ1am+eSKipNG/EVAyLcuOewOJwFAAEFC+BOAGcPzDI+/e5Afvb4vPssAx0gECrICrFxezcdPnaKnAupd4MDR7nA0B2AwmMnAAnd9khj9EeH+5+t5/L1Dzk4FwM8WnJwXYvVVc7hi/iS9MjCxbcRIn8gHP49JDwBmxVOxm3PIwB2APAP7O/u59bGdvLHH3XwADGULfueaGs7TbMGJKgxsRAwm8MEJ6qQHAPHCsZunAkXjeKqU5RnD2/u7uHHNDrY1dzu7NAjRbMEpeTxwbY1mC05MB4GtALal5AN3Jj0AeDaLkOkGWOq4YxL7e3qGl3a1ceOaHexq7XVaxsvPFizku5otOBHtAhoA+NczP3Bn8ucABAZsXhF+CnBG84zhyfcOcdNjO9nvuJZfxAoXa7bgRPS2iLQea1Y6uQHgj37uZ80YpuPPAWQ8z8Bv3j7AV594n9aeAaf1/QezBa+YrbUFJ45aY4x43tEP9aQGAK+mLHbzZGCy235Jrv+q3c+qdbvo7LfOcgRi/mRxBV+/dKbWFsx83cAmGNqP8kjJ3RfgvOsxfsj5E+ASlz2TTAZ/ALZhb6ffDTOLCSaicOAIeQZOryokbIWX69uJSLqvxlLHUA98F2iz0RqAR0rqCMAYASGbdK8ANJbfHRiICN95oYEHX95DxLo76AZrC140VFtQBwIZ6T1g//Ee4CIRqBx/DcCEYwx0D1i+uX43P3lzn9ODzs8W9GsLfmJxuUaAzLQJ6D3eA5IWAIYtAKrBLwM+IXkG2nojfO3JOn7z9gHHk4LR2oJXzOZqrS2YaSxQC4B37BWqSQsAQ+t/WAzku+qVVOAZaOrq5+bHdvLUe4ecJgoN7mN4TQ0XVGu2YAY5BGwBsOFj7wCYtABgDYjFI8MWAI2VZwy7W3u58ZEd/G53u9OU4YgI88pyeeDauSyu0mzBDFEP7AbgW8uO+aDkzQEYMB4lTIAEoJHyjGFbUzdfWLOdzfu63AYBKyypKuCBa+dSU6bZghlgC0jriR6UnABwy5OxWzPxqwCrKM8zvLGngxvX7OD9g71u1w1Y4YLqYr59dQ1VRdkaBNLbRjARTlCgKikBIOANphssBCY57ZYU5BnD+p2t3PzYDucpw1aEqxeUcs8VsynN02zBNNVLrAS4d/w3MCmJQN75f47gYeB64HzXvZOKjIGtzT0c6glz0exickOesytzBjilMp/CrCDP17XRHxHn2YtqVPYC3wYO2dXLj/vApIwARAxGJA//CoA6jp+8uZ+7ntlNz4C7lGHB/2D8zVmV3HLxdLKDRlOG08t2YN9IHpicOQB/AVAlMM9dn6Q+g38e/uDv9vK9l/YQtuI0WzAUMNx4/nQ+96FpBDwtMJpGNhnP6x5J1E54ADC3Ph27eRJQ4bZfUp8x0Be2rH62nv/7xn7n2YJ5IY/bls3k+qUVul4gPVhgg1hLoPDE9XYTHgCGBaElpPEW4MlkDLT3Rbj9qTp+nQLZgsU5Ab7x4Wo+ekqZTgqmvjaiCUAD+zpP+OCEBwAPC0iQDK8AFG+egeaufm55bCdrt7c6zhaE8vwsvnXVHC6fpwVGU1wDUAfAg1ed8MFJmAMw4FcAPtllr6SjWLbgFx/ZwasNbrMFrQizSnL47jU1fGhmkWYLpq53QA6N9MEJDQBmxdrYzYysAJwMnjG8s7+LL6zZwTtN7guMLijP44Fr57KoMl+DQGqqBROWEY7SEhoAZKgM8WlkwBbgrnie4dX6dr70yA7q2/qc1xY8c1ohD1w3VwuMpp4+YglAI/yMJDQAeJEAgaCAnv+PW6zA6K2P76Sl221twYj4BUbvv6aGqYWaMpxCmvGLgCDHqAB0pITPAUTCFOPvAaDGyTPw803NrFq3iy7HtQWtCNcuKOWeK2dTqgVGU8UO/H0ARyxxqcA3PIoJBQEzF7gRKHDZM5lCgI2NnQQ8w3kzi5zOCcRShguyArygKcOpYE1Q5KGIMfDiT0b0AwkbAXgFg5f8FzLBKgAnUqy24P3P1/NvrzWeaLFXQsVShj999lRuvmgGWUHNFnRIgNqwMXx+9X+N+IcSFgAkMpjGejoQHNeTqcMYA139ljvX7eIXm5qdzgfEUoa/eMF0PvehKgJGyws60g5sBvin2/58xD+UsABgMAgmB60AlBCegZbuAW59fCdPOi4rFksZ/tqyWVy/tFJTht0YSgD65rIR/1DiJgGNAFIBzHfaLRnMM4aGtj6+9MgOXnGeKOSnDP/jh6v52KIpunow+bYi0jLajk9IAPBWDFYAngdUuu2XzOYZw9ambm78rftEISswJT+Le6+ew5VaZTjZNmJMGDO6ef2EBIBhb/sSIM9hp0wInmd4tSE1EoWsCDOKsvnONTVcWF2iQSA5+okmABkZ3bRwQgJA9OMXQM//kybVEoXmleXyvetqWFpVqCnDiXcA2AYQuXdkCUAxiUwEKgVOcdcnE08qJQpFrHDa1AK+93tzWVCepyOBxNqJXwZs1OIfAL78XOxWNX4VYJVEAvzwtUbuf6GBgYi7ikLgB4FzZxTxwHVzqZ6Uo0EgcTbbjt6OsbzZcQ8AeUWDmYiLgBKXvTIRpVKiEPinA5fVTOL+q2uoLMzSIJAYG7zCHGxv1qh/MO4BoKezjGCWBX8BkF4SdmB4otAvHScKgT8x+HsnT+aeK+fouoH4G0wAMlnhUf9w3AOA8SDc7xWgFYCdiiUKrUiBRKGYTy4uZ+XyagqzA5onED97gfcB5N6RJwDFJGoScBr+LsDKoVRKFBpcN3BWJSsunkF20NMgEB9bMRwY61g7rgHAG9oC/GRgitNuUUBqJQoJEAwYvnDeNP7hvGkEA7p4KA42IgyMdbInviMAIXbWfzoQctsvKiaVEoVEICfk8ZVLZvA3Z1bioYuHxmGAWAJQKowACAggWfgZgCqFpFKikAgUZgdYtbyaTywu1wgwdi3AVoDICCsAHSnOIwADYsqBBa57Rn2QZ+AXm5q5MwUShaxAaV6Ie66czdULdN3AGL0P7BnPE8QtAARuGawAXANUuesTdTwW+LfXGvl2CiQKWRGqCrO576o5nD1dS42PwWYTMO3jeRPjFgDM0CzEYrT8V8oanij0o9f3OR99R0SYPyWPu66YTVVRtuYIjE6tRATbfeItwI4lbgHAEkTEeGgF4JRnDHT2W1atreNXm91uPQZ+yvDFs4v5+/OqCCZnu9pM0AlsAjBZA2N+kvh1txGMkRL8FGCV4jwDB6KJQut2uN16DPygdP3SSs6arqsHR2gv/iIg5L7RJwDFxCcA3Pxk7NZM/EVAKg14xrD7UC9femQHb+ztcF5RqLIwiz87vYJgQIcBI/Au/j4A4xKXng54g5f8FwGT3PWJGi3PM7y9r4sb1+zgvQM9zmsLLqspYXpxls4FnNhGkP7xTuPGJQCI2FgmwtJ4PadKHs8zvLSrjS8/uoO9He4ShSR6VaBmci6aJ3xcYfw9ABlvLmV8DlYDiOShC4DSlmcMj247yG1P1tHSPeAkR0CA7KChLE+TSE9gMAHI5o7vEI7nt/VU/CKgKk2JCL/c1MzTO1rxHGUIRAR6BlxXMUh5dfhlwGHl2CcAIQ4bdgRWrIsNQhYA5Y47Ro2RtcKUgiy+dOF0Lp83yUlmnjFwqDtM3aFerSRxfG+L9dqMGX+gjMOOPYZoMvcSYOwZCcoJwf/mX1JVwDcur+aK+aUY4+YUPGAMrzS0s72lB5MC9QtS2AbjWbEmMu4nGncAEASBkNEEoLRjBUKe4aOLprBy+SxOmpJHxIqTg98YONQT5oev7aO7P4LnOjspdQ0mACHjP4OPy559BsrwawCoNGFFmJwX4sbz/T39SnKCRBxeexOBf399H+u2H9KD//ga8bcBh9XLx/1k4woAZsVhC4Cmu+0XNVJWhFMrC7hzeTVXn1SK5/k5+a54Bn61+QD3PldPf0ScpyanuLgkAMWMKwAIFkMA4DSg0G2/qBMRgYBn+P2FZaxaPouFFfnOhvwQnecz8L9bWrjp0Z00d/U7LVaSJjaC6ZM41XseVwDwCCD+6Zue/6c4K0JpbogbzpvGDedWMSk35HTI7xnojwg/eXM/K9fVsa9DD/4RiCYACUa8uKzkHPccgIFi/BGASkGxWf5TKwtYuXwW15402fmQP+AZmjr7+fYLDfzLy4109kf04B+Zg8A7ADbvQFyecOwB4Ob1+OUldAFQqorN8v/+ojLuuKyak6fkERG3Q35jDK81dLBybR1PvXcIK+g5/8jVMZgA9PG4POGYA0AgEEHEgL//X6nrnlGHs1YoKwjxxfOn83fnRGf5HU/09YaFn721n7vW72ZnSw+eZ5yWJUtDb4sE4pIAFDP2EYA1iAdGWIq/E7BKAbEh/+nTClm1fBZXzC/FM+6H/PVtfdz7bD0/fnMfXXqdf6w2GBMRa+PXd2MOAAIYSx5GKwCnCiuQFTB8bFE5t182i3lluW5n+aNJos/sbOWOtXW8WNcOoOf7Y9NFLAEojsY+AvDfw0p0AVBKsFaoKMziyxfO4NNnVVKY7TaxxzOGzv4wP3p9H/c910Bje59+64/PUALQty6N25OOKQCYoR2ATgIq3PbLxOYP+eHsGUXceXk1l9aUYAxOy2wHPMO7B7r55tO7+cWmZvoiogf/+L0LNMX7SccUAGSoEMHpQI7bfpm4rEBO0PCJ08q57dKZzCl1P+S3Fta808Id6+qo3duJMUZn+eNjoxH6bJzL7YwpAHhGEAgaPwAoB6wVqoqzufmiGfzVGZXkZwWcDvkDxtDSPcCDL+/ln363h5auAf3Wj58wUCsGjJW4lnIf8xxAdAHQQtc9M9HEhvznVRdz5/JqLp5dDA6H/LFr+7WNnaxct4vHtrUQsejBH1/DEoDie8Ft1AHA3PQMEAGYgy4ASiorQm4owJ8uKecrl8xk1qQc/1vf0Rd/LJ33V5ub+cbTu3i3uVuv7SfGLqAeGHcFoCONfgQQDkIgAn76b5HrnpkorBVmlOTwlUtm8GenV5Abcjzk9wyN7f3cF91hqKMvrN/6ifO2FduWiCIpox8BZPeBGIORM1z3ykQg0S3XL6kp4c7l1Zw7qwjE7ZAfAy/WtXHH2l08+34rInptP8E2eMYTGwjH/YnHNgdgpBg41XGnZDwrQn5WgL86s5JbLppBVVG282v73QMRfvzmfu59tp761l4d8ideF/AWAHHMAIwZXQC49XmQfoAZwGzXPZPJrBXmTM7la8tm8senlZMdNM6H/DsP9nDX+t38z8ZmesOazpskQwlA93w47k8+qgAQkD6iO5EsBCa77plMJNECC1fML+XOy6s5Y1ohIuJsp5xYgdAn3j3IHWt38VpDB8bokD+J3gOJewJQzOhGAOIhRjBwBroAKO6sCMU5QT5zdhU3XjCNioIs59f2D/WG+cEre3ngxT00dfbrt37ybTR4fTZOFYCONKoAED34c0EXAMWbtcKC8jxuv2wWH11YRijgeMhvDFuauli5bhcPb2lhwGo6rwMRoFYQjI1PBaAjjWUSUBcAxZFfpw+ujdbpO62yAOtwyO8ZCFvhoS0trFpXx+b9XXiazuvKUAJQfldCXmDEAeCIBUCVjjsmI1gRSvNC3HDuND5/bhWTc0PO1+03dw3wvRcb+OdXGmntGdBzfbfqGEwAui4hLzDiACDiEa1EsgRdADQuw+v0rVo+i2sc1+mLpfO+saeDlWt38cS7B6OluvTgd+xtC62JfBdGHAA8E0GEoDFGKwCPgxUIBQx/cMoUvn7pLOd1+jwDfWHh55ua+Ob6XWw/oKW6UkitB2JNnJcADjPyOQBjMP6lP10ANEbWCuUFWXzxgul85pypFGe7rdMX8Ax72vr41vP1/Mfr+/zqvHqynyqGEoAS+BkZUQAwNw2e/+sCoDGIreA7c3ohqy6v5vK5kzAO6/TF0nlfqGvj9qfqeK6uDXTIn2r2MbgFWPwqAB1pRAFAeoOY/DD4C4CKXfdMOhks2rG4nK9eMpOayW6LdgxP5139bD0N0XRe3Y475SSkAtCRRhQAvIIBvGAEOxDU8/9RsFaYVpzNLRfP4C+WpkDRDk3nTSdvAb2JfpGRzQGIwQ4EdQegEYp9u180u4RVl8/igmp/0ORsBZ+m86abCLABINEJIScOACvXQ48FXQA0IrEVfH9xhr+Cb3qx2xV8AWNo7Q3zr6828p0XG2jq0HTeNDAsASixGfcnDABeZwQCugBoJKwVZpfmctuymXxycQqs4DOGLc3dfGPdLn6z5QADWp03XSSsAtCRTjwCCAx+YJaO6PETUGwF34fnl7Jq+SzOml6ISMJHb8d0tHRerc6bVt4WS1syztBGekDnoAuAjiq2gu9vz57KFy+Y7n4FXyyd96U9/MvLezmk6bzpaIPxsJ7xErQGcMhIA0AlMN9xp6QcK8LJU/L4egqs4Iul8765p4M7NJ03nQ0mAEkSJo2PGwC8FYMJQPPRBUCDrEDQM3xk4WTuuKyaUyvyna/g6wsLv9jUxD9qOm+6G0wAiiQwASjm+CMA8WBoAVCu655JBdYKk/ND/MN50/jch6ooTYEVfLHqvD98bR+d/VqdN80lJQEo5gSnABaEAEZ3AIqt4FtSVcCq5dVcOb80BVbwwUu72rljbR3P7NTqvBlioxHTa71En/37RjIHMBk4xWmXOGYFsoOGP1pUzm3LZjJ/Sp7zdN6egQj/VdvE3c/sZvchrc6bIcLABjGJqwB0pGMGAPPlp8EIQDV+EtCEZK0wtSibmy+azl+dOZWCFEjn3d3ay93P1POfG/bTM6DpvBlk2BZgiakAdKRjBoC8N/LoOacL/Pr/E24BkET/c351MatSYQ8+47dn/Y5Wbl9bx+92tYOm82aaYQlAiakAdKRjBoCec7oIiTDgFwCZUJ8yK0JeKMCfL61gxcUzmFnieg8+Q2d/hB+93sh9zzXQ2N6n3/qZabM1ts1I8t7b48wBGAaMKQSZUAuArBWqS3P46iUz+dSScnKC7of821t6+Mend/PzTU30hY+ezivu4lNCmYm1UnmDJ57YYPLeyaMHgJUroUfAL/5R47pXkiGWznt5NJ337MF0XndDfivw2LaD3LG2jjf2dHwgnVfEvzIRDBiKcoPkhQLDMrfT34AVOvoidPZFEMn4dQxdwCaAhKf/DXPUAOD1XhxrxclAmeueSbTD0nnPn05FofsNOVp7w/xLdEOO5qNsyGFFKMkNsbymhCvnl3JKRR6TckOEMiQCiEBv2LKvo5/X93Tw0JYWXt/T4S9oyoxf8UhDW4DdvTxpL3rUACBEMOKBkdOBkOueSSQrwoIpqbchx6p1u3joGBtyWIFzZhTxtUtnsWxOMXmhwGDZscw6ETAsLM9jWU0J1y+t4Ke1Tdz/fAONHX2ZOPm5DUNTst++owYAIwaMZEPmJgClYjrvSDbksCJcPq+U7183l/llfnmxsMOAlVhD70dZfogvnD+NuZNzueHh7dS39WZaENiI0CdJjgDHSwQqx98EJONYK5RF03k/myLpvAeiK/j++Tgr+KwIp1UW8O1r5jCvLDeDD/wPir091y6YTFtvmL9/eDud/ZFMmSAMA7UARgJJDQEfCADe0A5Ac4GprnsmnmLpvKdPK2TV8llcMb8Uz3F1XmMMtXs7uX1tHY9vO/YKPgHyQgFuuXgGC8vznZ6muCQifGzRFJ57v40fvd6IyYxRQAuDCUDNSX3hD+w4MKw/FwP5bvslfqxAyDN8anEF//OJk7lmwWQMCS25flye8We5/3tjE5/42Ts88k4LAsdM5xUrXFhdzNUnlWIn6MEPfiDMCXn8zVmVVBRkOXv/4qwOaABg5ceT+sIfGAFE+9PDrwCUEawIZXkhvnzhDD5zzlSKsoPOr+03tvdz/wv+Cr6OvhOv4AsEDB89pYySnOCEGvofTcT626qdP6uYX29uzoRRwGYR02ZM8t/XY80BTAIWOe2SOLEi1JTmcs+Vc/jIwsnR6+tuV/C9vLud25+qY/0IV/CJQEVBFh+aWZQp33jjlhfyuHhOMf+75YDrpsRDrTEiyVoBONzhAeArD8eSEGZF/6Q1K8IpFfl8/7q5XDS7BOt4D77esPDftU3c9cwu6g6OfAWfiDCjJJtpRVnYjLrMNz6nlOeTnxVI98nATga3AEv+b3FYAAjayVh/L4JFQInrnhkPK8K8sjz++SPzuKC62PmQv6Gtj9XP1vPjN/fRNYY9+CoKssjLCugIIMoKlBeEKMgK0NkXSed84UZgJwD3JC8BKOawABChFw9BMEs5ygRhuhCB0rwQd18x2+nBH9uD7/m6Nm5/so7n69qAsa3gyw95GZXmO35CbtAjFDD+5Knr5ozdNpJYAehIhwUAf8Wpyce/ApDW/vKMSq5dMNnZwR/bg+8nb+7nnmd309A6vhV8/bECJGn8SY8vw4CVTLgcWgv0u3rxo00CVuHnAKQlK1BTmsNfn1lJ0DNOJvwCnqHuUC93rd/Nf9c20ROHPfhaugboDVsKspKbKJKqjIFDPWG6B2w6x8ShBCBHCxwGA0DglnWxD9YC/CzA9CTCRbOLqSnNTfrBHyvasW77IW5/qo6X6+O0B58x1Lf1caB7gMJsnQcAfyC0o6WHjr5IOpdCawG2AkS2u7maMTQCEAOegLAEyHLdM2NlPMPiqQWEAiap18sTWbTDM9DY0c+mfV1OAlsqClvhpd3thCM2nZcJv08sAegXyU0Aihmc6BMPEBMizROAAgZKcpO7g1nAM+w42MMND2/nq0+8T2MCNuDs6Y+wZutB+iPJv1acajxj2N3axzM7W9N9TmSzwWt3+UsMm+kXQKbgnwKkrYhAe284Ka8VG3o+vu0gn/rZO/znhn30J2i9ujGGR7cd5I09nQTS9xsvToRfbm7mvQM96b4icINgxZKcAqBH4wGYm9bG/l4DTHPdK+MhVnh7f3fCh/8BY+jojXDf8w385S+38UZDB54xCYvlxsC+jj7uf76B1p5wphbFOKGAZ3hjTyc/eKWRSHqfCXUQrQBkHJ5xewAyMNiTpwGFjjtmfAy8uKvNH4Yn6CAJeIatzd383UPvccfaOpq6BpJyHuoZw2+3tnDvc/X0DNh0//YbtaBn2NnSw62Pv8/7h3rSPQjuJVoBSFZf4awRHoCX4yH+iUhan/+Df5Bsa+5hzdaWuC8SMcZPMnp4Swuf/Nk7/PytJsI2uSWqwhHhgRcb+OoT77O3vY+gZxI68nDNGD/gGvw1FJ/+zbus39maCcFvG+B8IcPgbJnxU39Pdd2geBiwln99tZEPz5vE7EnxmTUPGMPBngEefHkv339pDy3dbrbdNgb6IsKDL+/l1YYOrl9awbI5JUwtyiY7EFtbEL0embb89luBzv4IO1p6eGhLCz+tbcqkSkC1GPqJuG1EkJueiN2egb8LUNrzjOGtxi6+/UID37qqhuxouuhYmOjzbd7fxR1r61iz9SARK04/hLFXfqW+nTf2dDKtKIvZpTmU5YXICqZtBvdhRITuAUtjRz87D/ZwoMuf2M2Qg38AqEXAJLEE+NEEA8FQbB/yU4BS1z0TNwZ+/MZ+Tp6Sx9+dUzWm70TPwEBEeOidA9y5bhdbmvw6fanyGfSMn+m4q7WPXYd6XTcnYcxRaiOmuaEEoLsvc9qQINYinocRWQoEXPdMvBige8By59O7KckJ8snF5YPn8CP5Wc8z1Lf28f2X9vDD1xtp6w2n7LePFys0oNLFTmCPf9Pt+xYUYzAiuWTAAqAjeQYOdPXz5Ud30tYb4fozKsjPCmDt0WuvetG03dbeMI9tO8h3X9zD63s6QLfdVvG1ORAItEcijicAGJoErATmu25MInjG0Nw1wC2P7+Tl+nY+e04Vi6fmk5cVOCz29keEve39PF/Xxk9r9/Pc+210D0T8A1+PfRVfb0YiEaznPuM+FgDmAxWuG5MofjUey09r9/Pke4c4Z0YhZ04vpKowazBAbGnq4o09nexo6aEvbDHRy2tKxVkbsBHASNj5tZpYAFgC5DhuS0LFSnAf6BpgzTstrNnaQiD67R6xRDcH9EcMaby4RKW+3UQrAMk9y1y3hSBGgojJ2B2AjmQMgwlCsZ20dBJNJdFb+FcBUoKHmDLSfAGQUmnkJSBCMDVWdXrAHPxtwJVSiXUQeBWASGqMOD389N9i1w1RagLYBrwHYB1UAD4aD78EeHIraCg1MT0L0ua6EcN5wELXjVBqAugC1oIBB1uAHYtHhiwAUirFvQW8CWD78ly3ZZBHOlcAVip9PIzhkFgPvnOe67YM8oAC141QKsPVAw8h4GIH4OPJjMXjSqW2X4vxtoLB3nup67YcRgOAUom1G/iRkdTcw8wjvWtHKZXKBPiBFwhsQgTruPrP0XikUF6yUhnmSeAHNhLdvvybbqv/HI0HbHDdCKUy0BbgVqDFCNjVqZH5dyQP+H9An+uGKJVBtgGfA2qtBzaFC+15wK+Ax103RKkM8SzwZ9H/41kQx4U/jycItAJfBaYAqZOhoFR62QP8B/AgsC9Wfdbem5pD/5ig9QTPmi3AnwI3A38ElLlumFJpoBd/dd8jwP8QsJuIeIIY8MDek7rf/DEmsGIdNro+wQhBMZwOXAtcCMzD3ysgB80ZUBPbANCJv53XTvy8/peA123A7POG7VRqc5+HlStdt3dE/KoEt6zHMxGQwyrg5gNTgZlAVfR2KVAE5AGh6B9v2HMFjnhuj8Nr6h7tfo5x//HanMxgZIl/roREn9eFFJ6SOqZEvAfDRYb9GQC68VfvdQGHgGZgH9AY/dOC0Dv4yY62zOZ5sNJ9nb/R+EBZEu/WdYgIR9tu0gA2GMH0GiNBf48cL/rbi//HjOa1/Mxov0KfX6lfRlImxQDJ2Z5HYlUDE/HhM2IY+5Zlo341RtXHKSZxfWUQib7RsacXEUQGum0gKx851qsaAQs2L5B2B/3hv/9IfG09eEFMX//QUmZz+BOM5c2RD3yRj/BLMVkFPAeP/zgzRI/DZB+LCYplCZfIvpJjhhZBEPr9z9s9V7nuBKWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKpYT/DyWnKnh+bg3pAAAAAElFTkSuQmCC'
$iconBytes       = [Convert]::FromBase64String($iconBase64)
$stream          = New-Object IO.MemoryStream($iconBytes, 0, $iconBytes.Length)
$stream.Write($iconBytes, 0, $iconBytes.Length);
$iconImage       = [System.Drawing.Image]::FromStream($stream, $true)
$ReqForm.Icon       = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $stream).GetHIcon())

$ReqForm.controls.AddRange(@($User_TB,$Request_BT,$User_LB))
$ReqForm.ShowDialog()

		}
		else
		{
		[System.Windows.Forms.MessageBox]::Show("Aktueller User ist kein Admin!", 'Error', 'Ok', 'Error')
		}
	}
	else
    {
    
    Set-Variable -Name LoginComplete -Value $true -Scope global
    #$ReqForm.Tag = $null; $ReqForm.Close()

    }
############################# Form ####################################

if($LoginComplete -eq $true){
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()


## Standard Form
$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,400'
$Form.text                       = "SecurityApp"
$Form.TopMost                    = $false
$Form.FormBorderStyle = "FixedDialog"
$Form.MaximizeBox = $false
$Form.MinimizeBox = $false
$Form.StartPosition = "CenterScreen"

## PowerShell Icon
$iconBase64      = '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'
$iconBytes       = [Convert]::FromBase64String($iconBase64)
$stream          = New-Object IO.MemoryStream($iconBytes, 0, $iconBytes.Length)
$stream.Write($iconBytes, 0, $iconBytes.Length);
$iconImage       = [System.Drawing.Image]::FromStream($stream, $true)
$Form.Icon       = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $stream).GetHIcon())

## CMD Button
$CMD_BT                          = New-Object system.Windows.Forms.Button
$CMD_BT.text                     = "CMD"
$CMD_BT.width                    = 60
$CMD_BT.height                   = 30
$CMD_BT.location                 = New-Object System.Drawing.Point(18,23)
$CMD_BT.Font                     = 'Microsoft Sans Serif,10'
$CMD_BT.Add_Click({

if($CheckBox2.Checked -eq $true)
    {
        $Check = $true    
    }
    else
    {
        $Check = $false
    }
if($Check -eq $true){
if((Init) -eq $True){
Clear-Content C:\Users\$($env:USERNAME)\AppData\Local\clink\.history
#Start-Process -WindowStyle Hidden PowerShell -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\cmd.exe  -Credential $Credentials}"
 $ListBox1.Items.Add("CMD successfully started $(GD)")
$Process = Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\cmd.exe -verb runAs}" -WorkingDirectory $env:windir -PassThru -Wait
 #Start-Process powershell -Credential $credentials -Verb RunAs
 
$Process.WaitForExit()
 if($UN -eq $null)
    {
    $user = $env:USERNAME
    $history = Get-Content  C:\Users\$($user)\AppData\Local\clink\.history
    Set-Variable -Name CMDHistory -Value $history -Scope global
    }
else
    {
    $user = $UN
    $history = Get-Content  C:\Users\$($user)\AppData\Local\clink\.history
    Set-Variable -Name CMDHistory -Value $history -Scope global
    }
    $Process.WaitForExit()
    CMD-Log -Permission Admin
}else{

if($CredSet -eq $True -and $Credentials -ne $null){
Clear-Content C:\Users\$($env:USERNAME)\AppData\Local\clink\.history
#Start-Process -WindowStyle Hidden PowerShell -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\cmd.exe  -Credential $Credentials}"
 $ListBox1.Items.Add("CMD successfully started as Admin $(GD)")
$Process = Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -Credential $Credentials -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\cmd.exe -verb runAs}" -WorkingDirectory $env:windir -PassThru -Wait
 #Start-Process powershell -Credential $credentials -Verb RunAs

$Process.WaitForExit()
 if($UN -eq $null)
    {
    $user = $env:USERNAME
    $history = Get-Content  C:\Users\$($user)\AppData\Local\clink\.history
    Set-Variable -Name CMDHistory -Value $history -Scope global
    }
else
    {
    $user = $UN
    $history = Get-Content  C:\Users\$($user)\AppData\Local\clink\.history
    Set-Variable -Name CMDHistory -Value $history -Scope global
    }
    CMD-Log -Permission Admin
}else{
[System.Windows.Forms.MessageBox]::Show('Credntials not set!', 'Error', 'Ok', 'Error')
 $ListBox1.Items.Add("CMD couldn't be started $(GD)")
}

}
}
else
{

if((Init) -eq $True){
Clear-Content C:\Users\$($env:USERNAME)\AppData\Local\clink\.history
#Start-Process -WindowStyle Hidden PowerShell -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\cmd.exe  -Credential $Credentials}"
 $ListBox1.Items.Add("CMD successfully started $(GD)")
$Process = Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\cmd.exe}" -WorkingDirectory $env:windir -PassThru -Wait
 #Start-Process powershell -Credential $credentials -Verb RunAs
 
$Process.WaitForExit()
 if($UN -eq $null)
    {
    $user = $env:USERNAME
    $history = Get-Content  C:\Users\$($user)\AppData\Local\clink\.history
    Set-Variable -Name CMDHistory -Value $history -Scope global
    }
else
    {
    $user = $UN
    $history = Get-Content  C:\Users\$($user)\AppData\Local\clink\.history
    Set-Variable -Name CMDHistory -Value $history -Scope global
    }
    $Process.WaitForExit()
    CMD-Log -Permission User
}else{

if($CredSet -eq $True -and $Credentials -ne $null){
Clear-Content C:\Users\$($env:USERNAME)\AppData\Local\clink\.history
#Start-Process -WindowStyle Hidden PowerShell -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\cmd.exe  -Credential $Credentials}"
 $ListBox1.Items.Add("CMD successfully started $(GD)")
$Process = Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -Credential $Credentials -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\cmd.exe}" -WorkingDirectory $env:windir -PassThru -Wait
 #Start-Process powershell -Credential $credentials -Verb RunAs


$Process.WaitForExit()
 if($UN -eq $null)
    {
    $user = $env:USERNAME
    $history = Get-Content  C:\Users\$($user)\AppData\Local\clink\.history
    Set-Variable -Name CMDHistory -Value $history -Scope global
    }
else
    {
    $user = $UN
    $history = Get-Content  C:\Users\$($user)\AppData\Local\clink\.history
    Set-Variable -Name CMDHistory -Value $history -Scope global
    }
    CMD-Log -Permission User
}else{
[System.Windows.Forms.MessageBox]::Show('Credntials not set!', 'Error', 'Ok', 'Error')
 $ListBox1.Items.Add("CMD couldn't be started $(GD)")
}

}

}
})

## PowerShell Button
$PS_BT                           = New-Object system.Windows.Forms.Button
$PS_BT.text                      = "PS"
$PS_BT.width                     = 60
$PS_BT.height                    = 30
$PS_BT.location                  = New-Object System.Drawing.Point(18,65)
$PS_BT.Font                      = 'Microsoft Sans Serif,10'
$PS_BT.Add_Click({

if($CheckBox2.Checked -eq $true)
    {
        $Check = $true
            
    }
if($Check -eq $true){
if((Init) -eq $True){
Clear-Content C:\Users\$($env:USERNAME)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
#Start-Process -WindowStyle Hidden PowerShell -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\WindowsPowerShell\v1.0\\PowerShell.exe  -Credential $Credentials}"
 $ListBox1.Items.Add("Powershell successfully started as Admin $(GD)")
$Process = Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\WindowsPowerShell\v1.0\\PowerShell.exe -verb runAs}" -WorkingDirectory $env:windir -PassThru -Wait
 #Start-Process powershell -Credential $credentials -Verb RunAs

 
$Process.WaitForExit()
 if($UN -eq $null)
    {
    $user = $env:USERNAME
    $history = Get-Content  C:\Users\$($user)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
    Set-Variable -Name PSHistory -Value $history -Scope global
    }
else
    {
    $user = $UN
    $history = Get-Content  C:\Users\$($user)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
    Set-Variable -Name PSHistory -Value $history -Scope global
    }
    $Process.WaitForExit()
    PS-Log -Permission Admin
}else{

if($CredSet -eq $True -and $Credentials -ne $null){
Clear-Content C:\Users\$($env:USERNAME)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
#Start-Process -WindowStyle Hidden PowerShell -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\WindowsPowerShell\v1.0\\PowerShell.exe  -Credential $Credentials}"
 $ListBox1.Items.Add("Powershell  successfully started as Admin $(GD)")
$Process = Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -Credential $Credentials -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\WindowsPowerShell\v1.0\\PowerShell.exe -verb runAs}" -WorkingDirectory $env:windir -PassThru -Wait
 #Start-Process powershell -Credential $credentials -Verb RunAs

$Process.WaitForExit()
 if($UN -eq $null)
    {
    $user = $env:USERNAME
    $history = Get-Content  C:\Users\$($user)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
    Set-Variable -Name PSHistory -Value $history -Scope global
    }
else
    {
    $user = $UN
    $history = Get-Content  C:\Users\$($user)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
    Set-Variable -Name PSHistory -Value $history -Scope global
    }
    PS-Log -Permission Admin
}else{
[System.Windows.Forms.MessageBox]::Show('Credntials not set!', 'Error', 'Ok', 'Error')
 $ListBox1.Items.Add("Powershell couldn't be started $(GD)")
}

}
}
else
{

if((Init) -eq $True){
Clear-Content C:\Users\$($env:USERNAME)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
#Start-Process -WindowStyle Hidden PowerShell -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\WindowsPowerShell\v1.0\\PowerShell.exe  -Credential $Credentials}"
 $ListBox1.Items.Add("Powershell successfully started $(GD)")
$Process = Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\WindowsPowerShell\v1.0\\PowerShell.exe}" -WorkingDirectory $env:windir -PassThru -Wait
 #Start-Process powershell -Credential $credentials -Verb RunAs

 
$Process.WaitForExit()
 if($UN -eq $null)
    {
    $user = $env:USERNAME
    $history = Get-Content  C:\Users\$($user)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
    Set-Variable -Name PSHistory -Value $history -Scope global
    }
else
    {
    $user = $UN
    $history = Get-Content  C:\Users\$($user)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
    Set-Variable -Name PSHistory -Value $history -Scope global
    }
    $Process.WaitForExit()
    PS-Log -Permission User
}else{

if($CredSet -eq $True -and $Credentials -ne $null){
Clear-Content C:\Users\$($env:USERNAME)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
#Start-Process -WindowStyle Hidden PowerShell -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\WindowsPowerShell\v1.0\\PowerShell.exe  -Credential $Credentials}"
 $ListBox1.Items.Add("Powershell successfully started $(GD)")
$Process = Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -Credential $Credentials -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\WindowsPowerShell\v1.0\\PowerShell.exe}" -WorkingDirectory $env:windir -PassThru -Wait
 #Start-Process powershell -Credential $credentials -Verb RunAs


$Process.WaitForExit()
 if($UN -eq $null)
    {
    $user = $env:USERNAME
    $history = Get-Content  C:\Users\$($user)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
    Set-Variable -Name PSHistory -Value $history -Scope global
    }
else
    {
    $user = $UN
    $history = Get-Content  C:\Users\$($user)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
    Set-Variable -Name PSHistory -Value $history -Scope global
    }
    PS-Log -Permission User
}else{
[System.Windows.Forms.MessageBox]::Show('Credntials not set!', 'Error', 'Ok', 'Error')
 $ListBox1.Items.Add("Powershell couldn't be started $(GD)")
}

}

}
})


## Server Manager Button
$SM_BT                           = New-Object system.Windows.Forms.Button
$SM_BT.text                      = "SM"
$SM_BT.width                     = 60
$SM_BT.height                    = 30
$SM_BT.location                  = New-Object System.Drawing.Point(126,23)
$SM_BT.Font                      = 'Microsoft Sans Serif,10'
$SM_BT.Add_Click({
Set-Variable -Name Tool -Value "Server Manager" -Scope global
Tool-Log -Permission Admin


if((Init) -eq $True){

#Start-Process -WindowStyle Hidden PowerShell -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\WindowsPowerShell\v1.0\\PowerShell.exe  -Credential $Credentials}"
Start-Process -WindowStyle Hidden "PowerShell.exe" -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\ServerManager.exe -verb runas}"
 #Start-Process powershell -Credential $credentials -Verb RunAs
 $ListBox1.Items.Add("Server Manager successfully started $(GD)")

}else{

if($CredSet -eq $True -and $Credentials -ne $null){

#Start-Process -WindowStyle Hidden PowerShell -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\WindowsPowerShell\v1.0\\PowerShell.exe  -Credential $Credentials}"
Start-Process -WindowStyle Hidden "PowerShell.exe" -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\ServerManager.exe -verb runas}"
 #Start-Process powershell -Credential $credentials -Verb RunAs
 $ListBox1.Items.Add("Server Manager successfully started $(GD)")

}else{
[System.Windows.Forms.MessageBox]::Show('Credntials not set!', 'Error', 'Ok', 'Error')
 $ListBox1.Items.Add("Server Manager couldn't be started $(GD)")
}

}

})

## AD Search Dialog Button
$AD_BT                            = New-Object system.Windows.Forms.Button
$AD_BT.text                       = "AD"
$AD_BT.width                      = 60
$AD_BT.height                     = 30
$AD_BT.location                   = New-Object System.Drawing.Point(126,65)
$AD_BT.Font                       = 'Microsoft Sans Serif,10'
$AD_BT.Add_Click({
		$cmd="$env:windir\system32\rundll32.exe"
		$param="dsquery.dll,OpenQueryWindow"
		Start-Process $cmd $param
 $ListBox1.Items.Add("Active Directory query successfully started $(GD)")
})

$Browse_BT                           = New-Object system.Windows.Forms.Button
$Browse_BT.text                      = "Open"
$Browse_BT.width                     = 60
$Browse_BT.height                    = 30
$Browse_BT.location                  = New-Object System.Drawing.Point(18,105)
$Browse_BT.Font                      = 'Microsoft Sans Serif,10'
$Browse_BT.Add_Click({
if($CheckBox2.Checked -eq $true)
    {
        $Check = $true    
    }
if($Check -eq $true){
if((Init) -eq $True){

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog 
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "EXE Files | *.exe" 
    $OpenFileDialog.Title = $Title 
    $OpenFileDialog.ShowDialog() | Out-Null 
    $OpenFileDialog.filename 
    Set-Variable -Name File -Value $OpenFileDialog -Scope global

#Start-Process -WindowStyle Hidden PowerShell -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\WindowsPowerShell\v1.0\\PowerShell.exe  -Credential $Credentials}"
Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -ArgumentList "-noprofile -command &{Start-Process $($File.FileName) -verb runAs}" -WorkingDirectory $env:windir -PassThru
 #Start-Process powershell -Credential $credentials -Verb RunAs
 if($file.FileName -ne ""){
 $ListBox1.Items.Add("$($File.SafeFileName)  successfully started as Admin $(GD)")
 File-Log -Permission Admin}
 else{$ListBox1.Items.Add("Programm was not started $(GD)")}

}else{

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog 
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "EXE Files | *.exe" 
    $OpenFileDialog.Title = $Title 
    $OpenFileDialog.ShowDialog() | Out-Null 
    $OpenFileDialog.filename 
    Set-Variable -Name File -Value $OpenFileDialog -Scope global

if($CredSet -eq $True -and $Credentials -ne $null){

#Start-Process -WindowStyle Hidden PowerShell -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\WindowsPowerShell\v1.0\\PowerShell.exe  -Credential $Credentials}"
Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -Credential $Credentials -ArgumentList "-noprofile -command &{Start-Process $($File.FileName) -verb runAs}" -WorkingDirectory $env:windir -PassThru
 #Start-Process powershell -Credential $credentials -Verb RunAs
 $ListBox1.Items.Add("Programm successfully started as Admin $(GD)")
File-Log -Permission Admin
}else{
[System.Windows.Forms.MessageBox]::Show('Credntials not set!', 'Error', 'Ok', 'Error')
 $ListBox1.Items.Add("Programm coudln't be started $(GD)")
}

}

}else
{
if((Init) -eq $True){

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog 
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "EXE Files | *.exe" 
    $OpenFileDialog.Title = $Title 
    $OpenFileDialog.ShowDialog() | Out-Null 
    $OpenFileDialog.filename 
    Set-Variable -Name File -Value $OpenFileDialog -Scope global

#Start-Process -WindowStyle Hidden PowerShell -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\WindowsPowerShell\v1.0\\PowerShell.exe  -Credential $Credentials}"
Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -ArgumentList "-noprofile -command &{Start-Process $($File.FileName)}" -WorkingDirectory $env:windir -PassThru
 #Start-Process powershell -Credential $credentials -Verb RunAs
 if($file.FileName -ne ""){
 $ListBox1.Items.Add("$($File.SafeFileName)  successfully started $(GD)")
 File-Log -Permission User}
 else{$ListBox1.Items.Add("Programm couldn't be started $(GD)")}

}else{

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog 
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "EXE Files | *.exe" 
    $OpenFileDialog.Title = $Title 
    $OpenFileDialog.ShowDialog() | Out-Null 
    $OpenFileDialog.filename 
    Set-Variable -Name File -Value $OpenFileDialog -Scope global

if($CredSet -eq $True -and $Credentials -ne $null){

#Start-Process -WindowStyle Hidden PowerShell -ArgumentList "-noprofile -command &{Start-Process C:\Windows\system32\WindowsPowerShell\v1.0\\PowerShell.exe  -Credential $Credentials}"
Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -Credential $Credentials -ArgumentList "-noprofile -command &{Start-Process $($File.FileName)}" -WorkingDirectory $env:windir -PassThru
 #Start-Process powershell -Credential $credentials -Verb RunAs
 $ListBox1.Items.Add("Programm  successfully started $(GD)")
File-Log -Permission User
}else{
[System.Windows.Forms.MessageBox]::Show('Credntials not set!', 'Error', 'Ok', 'Error')
 $ListBox1.Items.Add("Programm couldn't be started $(GD)")
}

}
}

})

## Info Listbox
$ListBox1                        = New-Object system.Windows.Forms.ListBox
$ListBox1.text                   = "listBox"
$ListBox1.width                  = 381
$ListBox1.height                 = 220
$ListBox1.location               = New-Object System.Drawing.Point(10,182)

$Cancel_BT                       = New-Object system.Windows.Forms.Button
$Cancel_BT.text                  = "Cancel"
$Cancel_BT.width                 = 92
$Cancel_BT.height                = 30
$Cancel_BT.location              = New-Object System.Drawing.Point(267,80)
$Cancel_BT.Font                  = 'Microsoft Sans Serif,10'
$Cancel_BT.Add_Click({
$Form.Tag = $null; $Form.Close()
$LogForm.Tag = $null; $LogForm.Close()
})

$Check_BT                       = New-Object system.Windows.Forms.Button
$Check_BT.text                  = "Check Local Admin"
$Check_BT.width                 = 150
$Check_BT.height                = 30
$Check_BT.location              = New-Object System.Drawing.Point(240,150)
$Check_BT.Font                  = 'Microsoft Sans Serif,10'
$Check_BT.Add_Click({

$ADMCheck = Check-Local-Admin
if($ADMCheck -eq $True)
    {
    if($UN -eq $null){$Name = $env:username}else{$Name = $UN}
    $ListBox1.Items.Add("User $User is in the Admin group.")
    }
else
    {
    if($UN -eq $null){$Name = $env:username}else{$Name = $UN}
    $ListBox1.Items.Add("User $User is not in the Admin group.")
    }
})

$Clear_BT                       = New-Object system.Windows.Forms.Button
$Clear_BT.text                  = "Clear"
$Clear_BT.width                 = 92
$Clear_BT.height                = 30
$Clear_BT.location              = New-Object System.Drawing.Point(10,150)
$Clear_BT.Font                  = 'Microsoft Sans Serif,10'
$Clear_BT.Add_Click({

$ListBox1.items.Clear()

})

$Creds_BT                        = New-Object system.Windows.Forms.Button
$Creds_BT.text                   = "Credentials"
$Creds_BT.width                  = 92
$Creds_BT.height                 = 30
$Creds_BT.location               = New-Object System.Drawing.Point(267,23)
$Creds_BT.Font                   = 'Microsoft Sans Serif,10'
$Creds_BT.Add_Click({
if($UN -eq $null){$TempUN = $env:USERNAME}else{$TempUN = $UN}
$ListBox1.items.Clear()
 $ListBox1.Items.Add("Current loged in User: $($TempUN)")

$CredSet = $null
$UN = $null
#$Credentials = $null

$Cred = Get-Credential -Credential "$($env:USERDOMAIN)\" -ErrorAction SilentlyContinue
Set-Variable -Name Credentials -Value $Cred -Scope global
if($Cred -ne $null)
{
$CredCheck = Cred-Check
if($CredCheck -eq $true){
Set-Variable -Name CredSet -Value $true -Scope global
$UserName = $Cred.UserName
$UserName = $UserName -replace "$($env:USERDOMAIN)\\", ""
Set-Variable -Name UN -Value $UserName -Scope global
 $ListBox1.Items.Add("Current user switched to $UserName. $(GD)")
 }else{[System.Windows.Forms.MessageBox]::Show('Credentials are not valid.', 'Error', 'Ok', 'Error')}
}

})

$Groupbox1                       = New-Object system.Windows.Forms.Groupbox
$Groupbox1.height                = 135 #100
$Groupbox1.width                 = 184 #184
$Groupbox1.text                  = "Options"
$Groupbox1.location              = New-Object System.Drawing.Point(10,11)

$CheckBox2                       = New-Object system.Windows.Forms.CheckBox
$CheckBox2.text                  = "as Admin"
$CheckBox2.AutoSize              = $false
$CheckBox2.width                 = 95
$CheckBox2.height                = 20
$CheckBox2.location              = New-Object System.Drawing.Point(90,105)
$CheckBox2.Font                  = 'Microsoft Sans Serif,10'


$Form.controls.AddRange(@($ListBox1,$PS_BT,$SM_BT,$AD_BT,$CMD_BT,$Cancel_BT,$Creds_BT,$Check_BT,$Clear_BT,$Browse_BT,$CheckBox2,$Groupbox1))

$LogForm.Tag = $null; $LogForm.Close()

$Form.ShowDialog()
    }
}
}
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$LogForm                            = New-Object system.Windows.Forms.Form
$LogForm.ClientSize                 = '400,84'
$LogForm.text                       = "Login"
$LogForm.TopMost                    = $false
$LogForm.FormBorderStyle = "FixedDialog"
$LogForm.MaximizeBox = $false
$LogForm.MinimizeBox = $false
$LogForm.StartPosition = "CenterScreen"

$Login_LB                        = New-Object system.Windows.Forms.Label
$Login_LB.text                   = "App Password"
$Login_LB.AutoSize               = $true
$Login_LB.width                  = 25
$Login_LB.height                 = 10
$Login_LB.location               = New-Object System.Drawing.Point(29,24)
$Login_LB.Font                   = 'Microsoft Sans Serif,10'

$Login_LB2                        = New-Object system.Windows.Forms.Label
$Login_LB2.text                   = "////"
$Login_LB2.ForeColor 			  = "#892B78"
$Login_LB2.AutoSize               = $true
$Login_LB2.width                  = 25
$Login_LB2.height                 = 10
$Login_LB2.location               = New-Object System.Drawing.Point(10,24)
$Login_LB2.Font                   = 'Microsoft Sans Serif,10'

$Login_TB = New-Object Windows.Forms.MaskedTextBox
$Login_TB.PasswordChar = '*'
$Login_TB.width                  = 100
$Login_TB.height                 = 20
$Login_TB.location               = New-Object System.Drawing.Point(12,52)
$Login_TB.Font                   = 'Microsoft Sans Serif,10'
$Login_TB.Add_KeyDown({
    If($_.KeyCode -eq 'Enter')  {
        $_.SuppressKeyPress = $true
        $Los_BT.PerformClick()
    }
})


$Los_BT                          = New-Object system.Windows.Forms.Button
$Los_BT.text                     = "Login"
$Los_BT.width                    = 60
$Los_BT.height                   = 30
$Los_BT.location                 = New-Object System.Drawing.Point(240,16)
$Los_BT.Font                     = 'Microsoft Sans Serif,10'
$Los_BT.Add_Click({
if($CheckBox1.Checked -eq $true)
    {
        Set-Variable -Name Check -Value $true -Scope Global
        
    }
else
    {
        Set-Variable -Name Check -Value $false -Scope Global
        
    }
Check-Login
Set-Variable -Name CredSet -Value $true -Scope global

})

$Abbrechen_BT                    = New-Object system.Windows.Forms.Button
$Abbrechen_BT.text               = "Cancel"
$Abbrechen_BT.width              = 90
$Abbrechen_BT.height             = 30
$Abbrechen_BT.location           = New-Object System.Drawing.Point(308,16)
$Abbrechen_BT.Font               = 'Microsoft Sans Serif,10'
$Abbrechen_BT.Add_Click({ $LogForm.Tag = $null; $LogForm.Close() })

$LoginCreds                    = New-Object system.Windows.Forms.Button
$LoginCreds.text               = "Credentials"
$LoginCreds.width              = 90
$LoginCreds.height             = 30
$LoginCreds.location           = New-Object System.Drawing.Point(308,50)
$LoginCreds.Font               = 'Microsoft Sans Serif,10'
$LoginCreds.Add_Click({

$Cred = Get-Credential -Credential "$($env:USERDOMAIN)\" -ErrorAction SilentlyContinue

if($Cred -ne $null)
{
Set-Variable -Name Credentials -Value $Cred -Scope global
$CredCheck = Cred-Check
if($CredCheck -eq $true){
Set-Variable -Name CredSet -Value $true -Scope global
$UserName = $Cred.UserName
$UserName = $UserName -replace "$($env:USERDOMAIN)\\", ""
Set-Variable -Name UN -Value $UserName -Scope global
 }else{[System.Windows.Forms.MessageBox]::Show('Credentials are not valid.', 'Error', 'Ok', 'Error')}
}

})

$iconBase64      = 'AAABAAEAAAAAAAEAIAC4KAAAFgAAAIlQTkcNChoKAAAADUlIRFIAAAEAAAABAAgGAAAAXHKoZgAAKH9JREFUeNrt3Xl8lNd18PHffWZG+4YQkhCbQIAxxgbjLd6NjeO9ado0TdLF3dI0Sd04iW2cOLHBaWzj2Emc1O2bNmnfpE2bN2vt4B2M93hHGIzBBiyQQCAh0L7O3PP+8cxIArNomZk7Mzrfzwd7YEYzV3fmOXOf+5x7LiillFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSanSM6wbEW+DWdQgGRMbUEYJBIPrf2D/K0CMMh/Waib2WGfbYYffb4T9w1DYN3e+/5ujaPZLfaTzk8J4Y5evLmNsQv16YgAyIF0RE4O5LTvTQ9OatWIv/cfEO+3dBPIPJAnKBbCAQfZCJ/oAMPhTERP8uGBEQM3S0it+TBoaO59h9NhoAho4T//Ygi7GIib6q+P90GCNmKOjIUaLEmI8FLw7HUQQvehiP/qk8BG+MTbBuPpvpfDwIIOJZS9iI8T74q1gJ4pkIdvWl6f0Le7euw1j/Qykm9mvYAjCzgYXRP7OBqUAJkA9k4QeAAP5BGAsCsQPSHufvMsr7YmScf489/5EEiIygqyKMPwiM5HWOJRZwR8vgv09jfU1vjD871td0zQJhoB/oBNqBJqARqAN2gmkE6QcIGsOAFeTey9IsAKxcidd7oX9bwAhBMZwKXA0sxz/wJ5O+b6RS8SRAD7AfqAV+CzwCNA2ddqYJc+tajP91jw1Y40W8c4C/xT/4K1y3T6k0EAFeAVZKpO8pE8hOjwDgrViH9brwbD5AGfAP+Ae/HvhKjd5e4NMY82jKBwBvxTowg7P6C4H7gKtct0upNPc68LGUPlc2K9aDFYwfppYC/w5c5LpdSmWACqAx6LoVx2Owsfnc+cD/Ac5w3SalMkQAuDplRwDeretiN0uAfwIuc90mpTJM9livlyZU4MbnAChszQb4LPB7rtukVAaanJIBQHL6QaCjpO9M4O8Ze2KHUurYslLvwLr1qWhirgkBnweqXDdJqQw1kHIBwLPRaQkjZ6NDf6USqSPlAgAIYo0BPgmUum6NUhmsOaUCgPeVp8GA8WQOmuyjVKLtSakAkFWaHbu5DKh23R6lMtx7KRUA+pt7QQgCl6Mz/0olUgTYkjqZgDc8GlubOAM4y3VzlMpwXcDWlPmW9fJzYjeXANNdt0epDLcf2J4yAUCGFv2cBYRct0epDLcT2J8yAQADVshFF/wolQybge6UmQOIFiaoxF/5l7H8sp9+mT7jGQJ+4MPaaOk+Y/BSvkqDSnMWv0QYKREAvFsGV/7NI0Or/MQO/JK8IKdWFHDGtALmlOZQmB2kL2xpaO9jY2MXb+7pYG97P4LgGY0EKiFagXcgRQKAWDB+BvBi/DLeGcVaobwwi99fWMYnTpvC4qkFFOUECAw7wAXoGYiwvaWXX29u5qe1Tew42IMxJj3qtql0Ug/sghQJACZgQAhg5HTXbYknEQh4hqtOLuWmC2dw7sxCQgEPawURCB+xBUBWwOPUinxOqcjjDxdN4b7n6/nFpgP0hq2eFqh42orhEJIiAcCv8c0k/Jp/GcGKUJIT5Mbzp/P5c6sozQsRsULEHr9MfyQaFBZV5PPgR+ZxelUBdz2zmwNdA3pKoOKlFiEiJhXq53/2JUx2GOBk/LX/aX8KYEWYVpTN/VfX8JlzqsjL8rCj3J5DgFDAcPb0ImaV5PC7+g7a+8IYDQJqfPqA7wHvxdJunQqWt2N7QwCn4Jf/SmtWhBnFOXzvurlcd3Lp0Tf7GqHYz338tCkEPMMXfrudfZ39OhJQ49EEvAsgq5e7z7e3vVlgBOB00jz/XwRK80Ksvmo21508GSvx2eTSCvzBKWXcfeUcJuWGRj2aUGqYnfhbhgEpccAJiMkDTnPdkvEKeIYbz5vGHy6agh3r1/5xfGpxOV+/dBb5Wd6YRxVqwtsURLpiH58UCACAv4nnXNeNGA9rhfNnFfG3Z08lkIARugCegc+cPZUvXTCdUGDs23arCUuA2jCGjav9IttOA4AZSgCaD5Q77Zpxygp6/OWZlZQXZCVsiC5AVtBw04Uz+PTZU1Mmequ00Q68DXDabeuB1BkBLAZyxv0sjlgR5pTmcPHs4oQM/YcTgfwsjzsum8Ufn1aupwJqNPbgbxcO31wGuB4B+EPlIP4S4PQlsLA8n4oEfvsPZwVKc0PcfeVsrjqpNOFBR2WMrQgtw88dU2EEUEoGJABVFWURSmK6nhVhelE2919Tw/mziocWEyl1bBsxDAw/6t0FgJueiN2ahV8FKK2Zwf8kT0SE+WW5fPfauZw6tUCDgDqefmAj4O+7EeUsAGRnF8VuLgKK3fVLfOzr7CccSf4BGLHC0mkFPHBtDXMm5+rpgDqWFmAbgF196eA/OgsA/eEuAuKBnwCU3qltBt490MPBnjAukvQiVrhodgn3XT2HysIsDQLqaN4H2XtkapqzAGAwRIzNJwMSgIwx7GjpoXZv52FLfJPJinDdgsnc9eHZlOQGNVtQHWlzINTXfuRXretJwCqgxnEbxs0AnX0Rfrm5mb6wddqWP1lSwdeWzSIvpNmC6jC1kYEcbM/ha+2cBIDAUALQScAUt/0SH8YY1mw9yMv1HQQcLd6PZQt+9pwqvqjZgmpIB34NQEzWwGF3uBkBmMGP5RIge+xPlDqMgebOfr7zQgOtjuYCYChb8OaLpvPXZ1am+eSKipNG/EVAyLcuOewOJwFAAEFC+BOAGcPzDI+/e5Afvb4vPssAx0gECrICrFxezcdPnaKnAupd4MDR7nA0B2AwmMnAAnd9khj9EeH+5+t5/L1Dzk4FwM8WnJwXYvVVc7hi/iS9MjCxbcRIn8gHP49JDwBmxVOxm3PIwB2APAP7O/u59bGdvLHH3XwADGULfueaGs7TbMGJKgxsRAwm8MEJ6qQHAPHCsZunAkXjeKqU5RnD2/u7uHHNDrY1dzu7NAjRbMEpeTxwbY1mC05MB4GtALal5AN3Jj0AeDaLkOkGWOq4YxL7e3qGl3a1ceOaHexq7XVaxsvPFizku5otOBHtAhoA+NczP3Bn8ucABAZsXhF+CnBG84zhyfcOcdNjO9nvuJZfxAoXa7bgRPS2iLQea1Y6uQHgj37uZ80YpuPPAWQ8z8Bv3j7AV594n9aeAaf1/QezBa+YrbUFJ45aY4x43tEP9aQGAK+mLHbzZGCy235Jrv+q3c+qdbvo7LfOcgRi/mRxBV+/dKbWFsx83cAmGNqP8kjJ3RfgvOsxfsj5E+ASlz2TTAZ/ALZhb6ffDTOLCSaicOAIeQZOryokbIWX69uJSLqvxlLHUA98F2iz0RqAR0rqCMAYASGbdK8ANJbfHRiICN95oYEHX95DxLo76AZrC140VFtQBwIZ6T1g//Ee4CIRqBx/DcCEYwx0D1i+uX43P3lzn9ODzs8W9GsLfmJxuUaAzLQJ6D3eA5IWAIYtAKrBLwM+IXkG2nojfO3JOn7z9gHHk4LR2oJXzOZqrS2YaSxQC4B37BWqSQsAQ+t/WAzku+qVVOAZaOrq5+bHdvLUe4ecJgoN7mN4TQ0XVGu2YAY5BGwBsOFj7wCYtABgDYjFI8MWAI2VZwy7W3u58ZEd/G53u9OU4YgI88pyeeDauSyu0mzBDFEP7AbgW8uO+aDkzQEYMB4lTIAEoJHyjGFbUzdfWLOdzfu63AYBKyypKuCBa+dSU6bZghlgC0jriR6UnABwy5OxWzPxqwCrKM8zvLGngxvX7OD9g71u1w1Y4YLqYr59dQ1VRdkaBNLbRjARTlCgKikBIOANphssBCY57ZYU5BnD+p2t3PzYDucpw1aEqxeUcs8VsynN02zBNNVLrAS4d/w3MCmJQN75f47gYeB64HzXvZOKjIGtzT0c6glz0exickOesytzBjilMp/CrCDP17XRHxHn2YtqVPYC3wYO2dXLj/vApIwARAxGJA//CoA6jp+8uZ+7ntlNz4C7lGHB/2D8zVmV3HLxdLKDRlOG08t2YN9IHpicOQB/AVAlMM9dn6Q+g38e/uDv9vK9l/YQtuI0WzAUMNx4/nQ+96FpBDwtMJpGNhnP6x5J1E54ADC3Ph27eRJQ4bZfUp8x0Be2rH62nv/7xn7n2YJ5IY/bls3k+qUVul4gPVhgg1hLoPDE9XYTHgCGBaElpPEW4MlkDLT3Rbj9qTp+nQLZgsU5Ab7x4Wo+ekqZTgqmvjaiCUAD+zpP+OCEBwAPC0iQDK8AFG+egeaufm55bCdrt7c6zhaE8vwsvnXVHC6fpwVGU1wDUAfAg1ed8MFJmAMw4FcAPtllr6SjWLbgFx/ZwasNbrMFrQizSnL47jU1fGhmkWYLpq53QA6N9MEJDQBmxdrYzYysAJwMnjG8s7+LL6zZwTtN7guMLijP44Fr57KoMl+DQGqqBROWEY7SEhoAZKgM8WlkwBbgrnie4dX6dr70yA7q2/qc1xY8c1ohD1w3VwuMpp4+YglAI/yMJDQAeJEAgaCAnv+PW6zA6K2P76Sl221twYj4BUbvv6aGqYWaMpxCmvGLgCDHqAB0pITPAUTCFOPvAaDGyTPw803NrFq3iy7HtQWtCNcuKOWeK2dTqgVGU8UO/H0ARyxxqcA3PIoJBQEzF7gRKHDZM5lCgI2NnQQ8w3kzi5zOCcRShguyArygKcOpYE1Q5KGIMfDiT0b0AwkbAXgFg5f8FzLBKgAnUqy24P3P1/NvrzWeaLFXQsVShj999lRuvmgGWUHNFnRIgNqwMXx+9X+N+IcSFgAkMpjGejoQHNeTqcMYA139ljvX7eIXm5qdzgfEUoa/eMF0PvehKgJGyws60g5sBvin2/58xD+UsABgMAgmB60AlBCegZbuAW59fCdPOi4rFksZ/tqyWVy/tFJTht0YSgD65rIR/1DiJgGNAFIBzHfaLRnMM4aGtj6+9MgOXnGeKOSnDP/jh6v52KIpunow+bYi0jLajk9IAPBWDFYAngdUuu2XzOYZw9ambm78rftEISswJT+Le6+ew5VaZTjZNmJMGDO6ef2EBIBhb/sSIM9hp0wInmd4tSE1EoWsCDOKsvnONTVcWF2iQSA5+okmABkZ3bRwQgJA9OMXQM//kybVEoXmleXyvetqWFpVqCnDiXcA2AYQuXdkCUAxiUwEKgVOcdcnE08qJQpFrHDa1AK+93tzWVCepyOBxNqJXwZs1OIfAL78XOxWNX4VYJVEAvzwtUbuf6GBgYi7ikLgB4FzZxTxwHVzqZ6Uo0EgcTbbjt6OsbzZcQ8AeUWDmYiLgBKXvTIRpVKiEPinA5fVTOL+q2uoLMzSIJAYG7zCHGxv1qh/MO4BoKezjGCWBX8BkF4SdmB4otAvHScKgT8x+HsnT+aeK+fouoH4G0wAMlnhUf9w3AOA8SDc7xWgFYCdiiUKrUiBRKGYTy4uZ+XyagqzA5onED97gfcB5N6RJwDFJGoScBr+LsDKoVRKFBpcN3BWJSsunkF20NMgEB9bMRwY61g7rgHAG9oC/GRgitNuUUBqJQoJEAwYvnDeNP7hvGkEA7p4KA42IgyMdbInviMAIXbWfzoQctsvKiaVEoVEICfk8ZVLZvA3Z1bioYuHxmGAWAJQKowACAggWfgZgCqFpFKikAgUZgdYtbyaTywu1wgwdi3AVoDICCsAHSnOIwADYsqBBa57Rn2QZ+AXm5q5MwUShaxAaV6Ie66czdULdN3AGL0P7BnPE8QtAARuGawAXANUuesTdTwW+LfXGvl2CiQKWRGqCrO576o5nD1dS42PwWYTMO3jeRPjFgDM0CzEYrT8V8oanij0o9f3OR99R0SYPyWPu66YTVVRtuYIjE6tRATbfeItwI4lbgHAEkTEeGgF4JRnDHT2W1atreNXm91uPQZ+yvDFs4v5+/OqCCZnu9pM0AlsAjBZA2N+kvh1txGMkRL8FGCV4jwDB6KJQut2uN16DPygdP3SSs6arqsHR2gv/iIg5L7RJwDFxCcA3Pxk7NZM/EVAKg14xrD7UC9femQHb+ztcF5RqLIwiz87vYJgQIcBI/Au/j4A4xKXng54g5f8FwGT3PWJGi3PM7y9r4sb1+zgvQM9zmsLLqspYXpxls4FnNhGkP7xTuPGJQCI2FgmwtJ4PadKHs8zvLSrjS8/uoO9He4ShSR6VaBmci6aJ3xcYfw9ABlvLmV8DlYDiOShC4DSlmcMj247yG1P1tHSPeAkR0CA7KChLE+TSE9gMAHI5o7vEI7nt/VU/CKgKk2JCL/c1MzTO1rxHGUIRAR6BlxXMUh5dfhlwGHl2CcAIQ4bdgRWrIsNQhYA5Y47Ro2RtcKUgiy+dOF0Lp83yUlmnjFwqDtM3aFerSRxfG+L9dqMGX+gjMOOPYZoMvcSYOwZCcoJwf/mX1JVwDcur+aK+aUY4+YUPGAMrzS0s72lB5MC9QtS2AbjWbEmMu4nGncAEASBkNEEoLRjBUKe4aOLprBy+SxOmpJHxIqTg98YONQT5oev7aO7P4LnOjspdQ0mACHjP4OPy559BsrwawCoNGFFmJwX4sbz/T39SnKCRBxeexOBf399H+u2H9KD//ga8bcBh9XLx/1k4woAZsVhC4Cmu+0XNVJWhFMrC7hzeTVXn1SK5/k5+a54Bn61+QD3PldPf0ScpyanuLgkAMWMKwAIFkMA4DSg0G2/qBMRgYBn+P2FZaxaPouFFfnOhvwQnecz8L9bWrjp0Z00d/U7LVaSJjaC6ZM41XseVwDwCCD+6Zue/6c4K0JpbogbzpvGDedWMSk35HTI7xnojwg/eXM/K9fVsa9DD/4RiCYACUa8uKzkHPccgIFi/BGASkGxWf5TKwtYuXwW15402fmQP+AZmjr7+fYLDfzLy4109kf04B+Zg8A7ADbvQFyecOwB4Ob1+OUldAFQqorN8v/+ojLuuKyak6fkERG3Q35jDK81dLBybR1PvXcIK+g5/8jVMZgA9PG4POGYA0AgEEHEgL//X6nrnlGHs1YoKwjxxfOn83fnRGf5HU/09YaFn721n7vW72ZnSw+eZ5yWJUtDb4sE4pIAFDP2EYA1iAdGWIq/E7BKAbEh/+nTClm1fBZXzC/FM+6H/PVtfdz7bD0/fnMfXXqdf6w2GBMRa+PXd2MOAAIYSx5GKwCnCiuQFTB8bFE5t182i3lluW5n+aNJos/sbOWOtXW8WNcOoOf7Y9NFLAEojsY+AvDfw0p0AVBKsFaoKMziyxfO4NNnVVKY7TaxxzOGzv4wP3p9H/c910Bje59+64/PUALQty6N25OOKQCYoR2ATgIq3PbLxOYP+eHsGUXceXk1l9aUYAxOy2wHPMO7B7r55tO7+cWmZvoiogf/+L0LNMX7SccUAGSoEMHpQI7bfpm4rEBO0PCJ08q57dKZzCl1P+S3Fta808Id6+qo3duJMUZn+eNjoxH6bJzL7YwpAHhGEAgaPwAoB6wVqoqzufmiGfzVGZXkZwWcDvkDxtDSPcCDL+/ln363h5auAf3Wj58wUCsGjJW4lnIf8xxAdAHQQtc9M9HEhvznVRdz5/JqLp5dDA6H/LFr+7WNnaxct4vHtrUQsejBH1/DEoDie8Ft1AHA3PQMEAGYgy4ASiorQm4owJ8uKecrl8xk1qQc/1vf0Rd/LJ33V5ub+cbTu3i3uVuv7SfGLqAeGHcFoCONfgQQDkIgAn76b5HrnpkorBVmlOTwlUtm8GenV5Abcjzk9wyN7f3cF91hqKMvrN/6ifO2FduWiCIpox8BZPeBGIORM1z3ykQg0S3XL6kp4c7l1Zw7qwjE7ZAfAy/WtXHH2l08+34rInptP8E2eMYTGwjH/YnHNgdgpBg41XGnZDwrQn5WgL86s5JbLppBVVG282v73QMRfvzmfu59tp761l4d8ideF/AWAHHMAIwZXQC49XmQfoAZwGzXPZPJrBXmTM7la8tm8senlZMdNM6H/DsP9nDX+t38z8ZmesOazpskQwlA93w47k8+qgAQkD6iO5EsBCa77plMJNECC1fML+XOy6s5Y1ohIuJsp5xYgdAn3j3IHWt38VpDB8bokD+J3gOJewJQzOhGAOIhRjBwBroAKO6sCMU5QT5zdhU3XjCNioIs59f2D/WG+cEre3ngxT00dfbrt37ybTR4fTZOFYCONKoAED34c0EXAMWbtcKC8jxuv2wWH11YRijgeMhvDFuauli5bhcPb2lhwGo6rwMRoFYQjI1PBaAjjWUSUBcAxZFfpw+ujdbpO62yAOtwyO8ZCFvhoS0trFpXx+b9XXiazuvKUAJQfldCXmDEAeCIBUCVjjsmI1gRSvNC3HDuND5/bhWTc0PO1+03dw3wvRcb+OdXGmntGdBzfbfqGEwAui4hLzDiACDiEa1EsgRdADQuw+v0rVo+i2sc1+mLpfO+saeDlWt38cS7B6OluvTgd+xtC62JfBdGHAA8E0GEoDFGKwCPgxUIBQx/cMoUvn7pLOd1+jwDfWHh55ua+Ob6XWw/oKW6UkitB2JNnJcADjPyOQBjMP6lP10ANEbWCuUFWXzxgul85pypFGe7rdMX8Ax72vr41vP1/Mfr+/zqvHqynyqGEoAS+BkZUQAwNw2e/+sCoDGIreA7c3ohqy6v5vK5kzAO6/TF0nlfqGvj9qfqeK6uDXTIn2r2MbgFWPwqAB1pRAFAeoOY/DD4C4CKXfdMOhks2rG4nK9eMpOayW6LdgxP5139bD0N0XRe3Y475SSkAtCRRhQAvIIBvGAEOxDU8/9RsFaYVpzNLRfP4C+WpkDRDk3nTSdvAb2JfpGRzQGIwQ4EdQegEYp9u180u4RVl8/igmp/0ORsBZ+m86abCLABINEJIScOACvXQ48FXQA0IrEVfH9xhr+Cb3qx2xV8AWNo7Q3zr6828p0XG2jq0HTeNDAsASixGfcnDABeZwQCugBoJKwVZpfmctuymXxycQqs4DOGLc3dfGPdLn6z5QADWp03XSSsAtCRTjwCCAx+YJaO6PETUGwF34fnl7Jq+SzOml6ISMJHb8d0tHRerc6bVt4WS1syztBGekDnoAuAjiq2gu9vz57KFy+Y7n4FXyyd96U9/MvLezmk6bzpaIPxsJ7xErQGcMhIA0AlMN9xp6QcK8LJU/L4egqs4Iul8765p4M7NJ03nQ0mAEkSJo2PGwC8FYMJQPPRBUCDrEDQM3xk4WTuuKyaUyvyna/g6wsLv9jUxD9qOm+6G0wAiiQwASjm+CMA8WBoAVCu655JBdYKk/ND/MN50/jch6ooTYEVfLHqvD98bR+d/VqdN80lJQEo5gSnABaEAEZ3AIqt4FtSVcCq5dVcOb80BVbwwUu72rljbR3P7NTqvBlioxHTa71En/37RjIHMBk4xWmXOGYFsoOGP1pUzm3LZjJ/Sp7zdN6egQj/VdvE3c/sZvchrc6bIcLABjGJqwB0pGMGAPPlp8EIQDV+EtCEZK0wtSibmy+azl+dOZWCFEjn3d3ay93P1POfG/bTM6DpvBlk2BZgiakAdKRjBoC8N/LoOacL/Pr/E24BkET/c351MatSYQ8+47dn/Y5Wbl9bx+92tYOm82aaYQlAiakAdKRjBoCec7oIiTDgFwCZUJ8yK0JeKMCfL61gxcUzmFnieg8+Q2d/hB+93sh9zzXQ2N6n3/qZabM1ts1I8t7b48wBGAaMKQSZUAuArBWqS3P46iUz+dSScnKC7of821t6+Mend/PzTU30hY+ezivu4lNCmYm1UnmDJ57YYPLeyaMHgJUroUfAL/5R47pXkiGWznt5NJ337MF0XndDfivw2LaD3LG2jjf2dHwgnVfEvzIRDBiKcoPkhQLDMrfT34AVOvoidPZFEMn4dQxdwCaAhKf/DXPUAOD1XhxrxclAmeueSbTD0nnPn05FofsNOVp7w/xLdEOO5qNsyGFFKMkNsbymhCvnl3JKRR6TckOEMiQCiEBv2LKvo5/X93Tw0JYWXt/T4S9oyoxf8UhDW4DdvTxpL3rUACBEMOKBkdOBkOueSSQrwoIpqbchx6p1u3joGBtyWIFzZhTxtUtnsWxOMXmhwGDZscw6ETAsLM9jWU0J1y+t4Ke1Tdz/fAONHX2ZOPm5DUNTst++owYAIwaMZEPmJgClYjrvSDbksCJcPq+U7183l/llfnmxsMOAlVhD70dZfogvnD+NuZNzueHh7dS39WZaENiI0CdJjgDHSwQqx98EJONYK5RF03k/myLpvAeiK/j++Tgr+KwIp1UW8O1r5jCvLDeDD/wPir091y6YTFtvmL9/eDud/ZFMmSAMA7UARgJJDQEfCADe0A5Ac4GprnsmnmLpvKdPK2TV8llcMb8Uz3F1XmMMtXs7uX1tHY9vO/YKPgHyQgFuuXgGC8vznZ6muCQifGzRFJ57v40fvd6IyYxRQAuDCUDNSX3hD+w4MKw/FwP5bvslfqxAyDN8anEF//OJk7lmwWQMCS25flye8We5/3tjE5/42Ts88k4LAsdM5xUrXFhdzNUnlWIn6MEPfiDMCXn8zVmVVBRkOXv/4qwOaABg5ceT+sIfGAFE+9PDrwCUEawIZXkhvnzhDD5zzlSKsoPOr+03tvdz/wv+Cr6OvhOv4AsEDB89pYySnOCEGvofTcT626qdP6uYX29uzoRRwGYR02ZM8t/XY80BTAIWOe2SOLEi1JTmcs+Vc/jIwsnR6+tuV/C9vLud25+qY/0IV/CJQEVBFh+aWZQp33jjlhfyuHhOMf+75YDrpsRDrTEiyVoBONzhAeArD8eSEGZF/6Q1K8IpFfl8/7q5XDS7BOt4D77esPDftU3c9cwu6g6OfAWfiDCjJJtpRVnYjLrMNz6nlOeTnxVI98nATga3AEv+b3FYAAjayVh/L4JFQInrnhkPK8K8sjz++SPzuKC62PmQv6Gtj9XP1vPjN/fRNYY9+CoKssjLCugIIMoKlBeEKMgK0NkXSed84UZgJwD3JC8BKOawABChFw9BMEs5ygRhuhCB0rwQd18x2+nBH9uD7/m6Nm5/so7n69qAsa3gyw95GZXmO35CbtAjFDD+5Knr5ozdNpJYAehIhwUAf8Wpyce/ApDW/vKMSq5dMNnZwR/bg+8nb+7nnmd309A6vhV8/bECJGn8SY8vw4CVTLgcWgv0u3rxo00CVuHnAKQlK1BTmsNfn1lJ0DNOJvwCnqHuUC93rd/Nf9c20ROHPfhaugboDVsKspKbKJKqjIFDPWG6B2w6x8ShBCBHCxwGA0DglnWxD9YC/CzA9CTCRbOLqSnNTfrBHyvasW77IW5/qo6X6+O0B58x1Lf1caB7gMJsnQcAfyC0o6WHjr5IOpdCawG2AkS2u7maMTQCEAOegLAEyHLdM2NlPMPiqQWEAiap18sTWbTDM9DY0c+mfV1OAlsqClvhpd3thCM2nZcJv08sAegXyU0Aihmc6BMPEBMizROAAgZKcpO7g1nAM+w42MMND2/nq0+8T2MCNuDs6Y+wZutB+iPJv1acajxj2N3axzM7W9N9TmSzwWt3+UsMm+kXQKbgnwKkrYhAe284Ka8VG3o+vu0gn/rZO/znhn30J2i9ujGGR7cd5I09nQTS9xsvToRfbm7mvQM96b4icINgxZKcAqBH4wGYm9bG/l4DTHPdK+MhVnh7f3fCh/8BY+jojXDf8w385S+38UZDB54xCYvlxsC+jj7uf76B1p5wphbFOKGAZ3hjTyc/eKWRSHqfCXUQrQBkHJ5xewAyMNiTpwGFjjtmfAy8uKvNH4Yn6CAJeIatzd383UPvccfaOpq6BpJyHuoZw2+3tnDvc/X0DNh0//YbtaBn2NnSw62Pv8/7h3rSPQjuJVoBSFZf4awRHoCX4yH+iUhan/+Df5Bsa+5hzdaWuC8SMcZPMnp4Swuf/Nk7/PytJsI2uSWqwhHhgRcb+OoT77O3vY+gZxI68nDNGD/gGvw1FJ/+zbus39maCcFvG+B8IcPgbJnxU39Pdd2geBiwln99tZEPz5vE7EnxmTUPGMPBngEefHkv339pDy3dbrbdNgb6IsKDL+/l1YYOrl9awbI5JUwtyiY7EFtbEL0embb89luBzv4IO1p6eGhLCz+tbcqkSkC1GPqJuG1EkJueiN2egb8LUNrzjOGtxi6+/UID37qqhuxouuhYmOjzbd7fxR1r61iz9SARK04/hLFXfqW+nTf2dDKtKIvZpTmU5YXICqZtBvdhRITuAUtjRz87D/ZwoMuf2M2Qg38AqEXAJLEE+NEEA8FQbB/yU4BS1z0TNwZ+/MZ+Tp6Sx9+dUzWm70TPwEBEeOidA9y5bhdbmvw6fanyGfSMn+m4q7WPXYd6XTcnYcxRaiOmuaEEoLsvc9qQINYinocRWQoEXPdMvBige8By59O7KckJ8snF5YPn8CP5Wc8z1Lf28f2X9vDD1xtp6w2n7LePFys0oNLFTmCPf9Pt+xYUYzAiuWTAAqAjeQYOdPXz5Ud30tYb4fozKsjPCmDt0WuvetG03dbeMI9tO8h3X9zD63s6QLfdVvG1ORAItEcijicAGJoErATmu25MInjG0Nw1wC2P7+Tl+nY+e04Vi6fmk5cVOCz29keEve39PF/Xxk9r9/Pc+210D0T8A1+PfRVfb0YiEaznPuM+FgDmAxWuG5MofjUey09r9/Pke4c4Z0YhZ04vpKowazBAbGnq4o09nexo6aEvbDHRy2tKxVkbsBHASNj5tZpYAFgC5DhuS0LFSnAf6BpgzTstrNnaQiD67R6xRDcH9EcMaby4RKW+3UQrAMk9y1y3hSBGgojJ2B2AjmQMgwlCsZ20dBJNJdFb+FcBUoKHmDLSfAGQUmnkJSBCMDVWdXrAHPxtwJVSiXUQeBWASGqMOD389N9i1w1RagLYBrwHYB1UAD4aD78EeHIraCg1MT0L0ua6EcN5wELXjVBqAugC1oIBB1uAHYtHhiwAUirFvQW8CWD78ly3ZZBHOlcAVip9PIzhkFgPvnOe67YM8oAC141QKsPVAw8h4GIH4OPJjMXjSqW2X4vxtoLB3nup67YcRgOAUom1G/iRkdTcw8wjvWtHKZXKBPiBFwhsQgTruPrP0XikUF6yUhnmSeAHNhLdvvybbqv/HI0HbHDdCKUy0BbgVqDFCNjVqZH5dyQP+H9An+uGKJVBtgGfA2qtBzaFC+15wK+Ax103RKkM8SzwZ9H/41kQx4U/jycItAJfBaYAqZOhoFR62QP8B/AgsC9Wfdbem5pD/5ig9QTPmi3AnwI3A38ElLlumFJpoBd/dd8jwP8QsJuIeIIY8MDek7rf/DEmsGIdNro+wQhBMZwOXAtcCMzD3ysgB80ZUBPbANCJv53XTvy8/peA123A7POG7VRqc5+HlStdt3dE/KoEt6zHMxGQwyrg5gNTgZlAVfR2KVAE5AGh6B9v2HMFjnhuj8Nr6h7tfo5x//HanMxgZIl/roREn9eFFJ6SOqZEvAfDRYb9GQC68VfvdQGHgGZgH9AY/dOC0Dv4yY62zOZ5sNJ9nb/R+EBZEu/WdYgIR9tu0gA2GMH0GiNBf48cL/rbi//HjOa1/Mxov0KfX6lfRlImxQDJ2Z5HYlUDE/HhM2IY+5Zlo341RtXHKSZxfWUQib7RsacXEUQGum0gKx851qsaAQs2L5B2B/3hv/9IfG09eEFMX//QUmZz+BOM5c2RD3yRj/BLMVkFPAeP/zgzRI/DZB+LCYplCZfIvpJjhhZBEPr9z9s9V7nuBKWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKpYT/DyWnKnh+bg3pAAAAAElFTkSuQmCC'
$iconBytes       = [Convert]::FromBase64String($iconBase64)
$stream          = New-Object IO.MemoryStream($iconBytes, 0, $iconBytes.Length)
$stream.Write($iconBytes, 0, $iconBytes.Length);
$iconImage       = [System.Drawing.Image]::FromStream($stream, $true)
$LogForm.Icon       = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $stream).GetHIcon())

$CheckBox1                    = New-Object system.Windows.Forms.CheckBox
$CheckBox1.text               = "Admin"
$CheckBox1.AutoSize           = $true
$CheckBox1.width              = 104
$CheckBox1.height             = 20
$CheckBox1.location           = New-Object System.Drawing.Point(240,55)
$CheckBox1.Font               = 'Microsoft Sans Serif,10'


$LogForm.controls.AddRange(@($Login_LB,$Login_TB,$Los_BT,$Abbrechen_BT,$Login_LB2,$CheckBox1,$LoginCreds,$PictureBox1))

$LogForm.ShowDialog()
