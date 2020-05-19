#
Function Check-PS-RL {
$Modules = (Get-Module -ListAvailable).Name
if($Modules -contains "PSReadLine")
    {
    
    return $true
    
    }
else
    {
    
    return $false

    }
}

if((Check-PS-RL) -eq $False)
    {
    $proxy = Get-Content $PSScriptRoot\proxy.conf
    $pAddress= $proxy[0]
    $pPort = $proxy[1]
    ## setup Proxy
    [system.net.webrequest]::defaultwebproxy = new-object system.net.webproxy('http://$pAddress:$pPort')
    [system.net.webrequest]::defaultwebproxy.credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
    [system.net.webrequest]::defaultwebproxy.BypassProxyOnLocal = $true
    ## install PSReadLine
    Install-Module -Name PSReadLine -Force
    }
