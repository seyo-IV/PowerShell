################################################################## 
# AUTHOR  : Sergiy Ivanov / ECKD Service GmbH - http://www.eckd.de
# DATE    : 09-01-2018  
# EDIT    : 09-01-2018 
# COMMENT : Change file and folder ACL with ICACLS.exe
# VERSION : 1.0 
##################################################################


$StartingDir=Read-Host "What directory do you want to start at?"
$Right=Read-Host "What ACL right do you want to grant? Valid choices are F, C, R or W `
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

$Principal=Read-Host "What security principal do you want to grant?" `
"ACL right"$Right.ToUpper()"to?" `n `
"Use format domain\username or domain\group"

$Verify=Read-Host `n "You are about to change permissions on all" `
"files starting at"$StartingDir.ToUpper() `n "for security"`
"principal"$Principal.ToUpper() `
"with new right of"$Right.ToUpper()"."`n `
"Do you want to continue? [Y,N]"

if ($Verify -eq "Y") {

 foreach ($file in $(Get-ChildItem $StartingDir -recurse)) {
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