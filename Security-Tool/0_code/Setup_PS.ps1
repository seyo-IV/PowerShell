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
    ## setup Proxy
    [system.net.webrequest]::defaultwebproxy = new-object system.net.webproxy('http://YOURPROXY:PORT')
    [system.net.webrequest]::defaultwebproxy.credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
    [system.net.webrequest]::defaultwebproxy.BypassProxyOnLocal = $true
    ## install PSReadLine
    Install-Module -Name PSReadLine -Force
    }