$proxyset = Get-ItemProperty -Path "Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
if($proxyset.proxyEnable -eq 1)
{
Write-Host "Proxy is enabled, please provide some info" -ForegroundColor Yellow
$pAddress = Read-Host "Proxy Address"
$pPort = Read-Host "Proxy Port"
$pAddress | Out-File $PSScriptRoot\proxy.conf
$pPort | Out-File $PSScriptRoot\proxy.conf -Append

## Set Proxy
[system.net.webrequest]::defaultwebproxy = new-object system.net.webproxy('http://pAddress:pPort')
[system.net.webrequest]::defaultwebproxy.credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
[system.net.webrequest]::defaultwebproxy.BypassProxyOnLocal = $true

}

## Install Choco
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
