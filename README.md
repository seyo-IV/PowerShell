# Powershell-Random-Scripts
A collection of Powershell scripts i used to use.

The Power_loop is a multifunctional script with buildin AD-Querys, Attribute change and some other tools like a portscanner or serverinfo.
In order to use it you may need to change some variables first.

Change:

$URDC to your Domain Controller

-SearchBase to your search base (like OU=OUsname,DC=example,DC=com)

$Path to your export path.

Modules required:
Windows Powershell Active Directory Module


To use Get-Effective_Permissions u need to alter $Path, the DOMAINPREFIX(thats the Domain\Name thing) and Local_Group_Prefix(If you are using Local and global groups from Mictosoft best practice) to suit your company standards. The module Active Direcotry is alse required.
Same for Get-Effective-Permissions-HTML.
