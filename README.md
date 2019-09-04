
# Get-Effective-Permissions-HTML/EXCEL
  To use Get-Effective-Permissions-HTML u need to alter Local_Group_Prefix(If you are using local and global groups from Mictosoft best practice) to suit your company standards. The module Active Direcotry and NTFSSecurity is also required. For the EXCEL version is also importExcel required.

# Profile:
  To use the Powershell profile you need to Active Directory Module! Also read the head text in the profile.

# GUI
  I do recomend to start the scripts with a shortcut with the following content in Target: [%windir%\System32\WindowsPowerShell\v1.0\powershell.exe - windowstyle hidden -Noninteractive -ExecutionPolicy Bypass –Noprofile -file "\\SERVER\PATH\TO\SCRIPT"]
  
  Or you use the shortcut.ps1 to create the shortcut to the GUI with above parameters. Note that the script shortcut.ps1 should be in the same directory where the GUI script is. You can then palce the shortcut wherever you like.
  
  
  Membershipt.ps1 shows groupmembership of a user, group and the member of a group.
  wildcard_search.ps1 does a wildcard AD-Query for user or group.
  permission.ps1 shows the NTFS-Permissions to a specific path.
  
  For the GUIs you will need the Active Directory Module for wildcard_search.ps1 and membership.ps1.
  For GUI permissions.ps1 you wil need the NTFSSecurity Module.
