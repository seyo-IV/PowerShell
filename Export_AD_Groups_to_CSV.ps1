###########################################################
# AUTHOR  				: Sergiy Ivanov 
# Original Author		: Victor Ashiedu
# CREATED 				: 08-08-2014 
# UPDATED 				: 12-02-2019 
# COMMENT 				: This script exports Active Directory groups
#           to a a csv file.
###########################################################


#Define location of my script variable
#the -parent switch returns one directory lower from directory defined. 
#below will return up to ImportADUsers folder 
#and since my files are located here it will find it.
#It failes withpout appending "*.*" at the end

$path = Split-Path -parent "C:\your\path\*.*"

#Create a variable for the date stamp in the log file

$LogDate = get-date -f yyyyMMddhhmm

#Define CSV and log file location variables
#they have to be on the same location as the script

$csvfile = $path + "\ALLADGroups_$logDate.csv"

#import the ActiveDirectory Module

Import-Module ActiveDirectory


#Sets the OU to do the base search for all user accounts, change as required.
#Simon discovered that some users were missing
#I decided to run the report from the root of the domain

$SearchBase = "OU=Group,DC=example,DC=com"

$ErrorActionPreference = "SilentlyContinue"


$AllADGroups = Get-ADGroup  -searchbase $SearchBase -Filter * -Properties * #| Where-Object {$_.info -NE 'Migrated'} #ensures that updated users are never exported.

$AllADGroups |
Select-Object @{Label = "sAMAccountName";Expression = {$_.sAMAccountName}},
@{Label = "Description";Expression = {$_.description}},
@{Label = "MemberOf";Expression = {foreach($group in $AllADGroups){$ADGroup = Get-ADGroup -Identity $group -Properties memberof | Select-Object -ExpandProperty memberof
foreach($grp in $ADGroup){(Get-ADGroup -Filter * -SearchBase "$grp").sAMAccountName}}}},
@{Label = "Member sAMAccountName";Expression = {foreach($group in $AllADGroups){$ADGroup = Get-ADGroup -Identity $group -Properties member | Select-Object -ExpandProperty member
foreach($user in $ADGroup){(Get-ADUser -Filter * -SearchBase "$user").sAMAccountName}}}} |
#Export CSV report

Export-Csv -Path $csvfile -NoTypeInformation
