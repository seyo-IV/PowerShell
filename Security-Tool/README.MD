# Setup #

## Recomendation ##
I recomend to compile an exe with ps2exe https://gallery.technet.microsoft.com/scriptcenter/PS2EXE-GUI-Convert-e7cb69d5 so noone can change or manipulate the script.

### Install ###
0) Run [generate_Shortcuts.ps1]
1) Copy the Tool with [Copy_Tool.lnk]. Tool is always copied to C:\temp\Security-Tool. Or copy it by hand.
2) Run [generate_Shortcut]. This will generate a [Setup_Enviroment.lnk].
3) Now run (as Administrator) Setup_Enviroment.lnk, this will open a new Shell.
	Setting up chocolatey and installing the required module activates the ability of CMD to log commands.
4) After installing Choco and setting up CMD you can execute [Security-Tool.exe] Password: Standard
#### PS: All Values that has to be changed so the script works are marked with "## Change it!!" ####
### Uninstall ###
0) Run both as admin!
1) Run [Remove-Tools.lnk] to remove the tools that were installed to work with the Security-Tool(Chocolatey, clink).
2) Run [Delete-Tool.lnk] to remove the Security-Tool folder and its content.

# Usage #

![SecurityApp GUI](https://github.com/seyo-IV/Powershell/blob/master/Security-Tool/images/Login.PNG)

### Login ###
The tool usage differs depending on what credentials you use. There are 2 cases.
 1) You have global adminrights or the tool has been started with admin credentials and your account starts with "ADMINPREFIX", then you have permission to check the Admin checkbox.
	Checking the Admin Checkbox will open a new dialog and ask for a username to grant local admin right to. This process can take up to 5 minutes to finish.
	Checkbox has to be checked before you login.
 2) You are a non admin user or the tool was started with non admin credentials.
	Checking the checkbox will generate an error, since you are not an admin.
	As a non admin user you can still login.

![Login GUI](https://github.com/seyo-IV/Powershell/blob/master/Security-Tool/images/SecurityApp.PNG)

### SecurityApp ###
####Explanation:####
	Credentials: You can user the credentials you granted localadmin rights to or use your admin credentials.
	Local Admin rights or a glabl admin account are required to use the Admin checkbox and start things as admin.
	Check Local Admin: Checks if the current logedin user has local admin rights(is in ad group).
	
####Options:####
	From the Options groupbox you can start CMD, PowerShell, Server Manager or the AD Dialog.
	If t he Admin checkbox is checked you start PowerShell or CMD as admin.
	All commands typed in PowerShel or CMD are logged and saved under \\SERVER\SHARE\Logs\Security-Tool ## Change this in [Security-Tool.ps1]
	You can also open a file from the Options groupbox, this is also logged(Who opened, what, where, when).
