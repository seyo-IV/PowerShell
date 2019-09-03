###########################################################
# AUTHOR  				: Sergiy Ivanov 
# Original Author	: Victor Ashiedu
# CREATED 				: 08-08-2014 
# UPDATED 				: 12-02-2019 
# COMMENT 				: This script exports Active Directory user
#                   to a a csv file.
###########################################################
#requires -version 3 -module ActiveDirectory
<#
.SYNOPSIS
  This script exports Active directory User to a CSV file, i added a field called MemberOf, which exports also the membership of a user.
  
.DESCRIPTION
  Export AD-User to a CSV.
  
.PARAMETER SearchBase
  Set the OU in which the filter will search for users.
    
.INPUTS
  None.
  
.OUTPUTS
  Creates the CSV in the current directory.
  
.NOTES
  Version:        1.0
  Author:         Sergiy Ivanov
  Creation Date:  12.02.2019
  Purpose/Change: Initial script development
  
.EXAMPLE
  Export_AD_Users_to_CSV.ps1 -SearchBase "OU=User,DC=example,DC=com"
#>

$path = Split-Path -parent $PWD

#Create a variable for the date stamp in the log file

$LogDate = get-date -f yyyyMMddhhmm

#Define CSV and log file location variables
#they have to be on the same location as the script

$csvfile = $path + "\ALLADUsers_$logDate.csv"

#import the ActiveDirectory Module

Import-Module ActiveDirectory
[CmdletBinding()]
param(
	[Parameter(Mandatory=$True]
	[string]$SearchBase = (Get-ADDomain).DistinguishedName
  )

$ErrorActionPreference = "SilentlyContinue"


$AllADUsers = Get-ADUser  -searchbase $SearchBase -Filter * -Properties * #| Where-Object {$_.info -NE 'Migrated'} #ensures that updated users are never exported.

$AllADUsers |
Select-Object @{Label = "First Name";Expression = {$_.GivenName}},
@{Label = "Last Name";Expression = {$_.Surname}},
@{Label = "Display Name";Expression = {$_.DisplayName}},
@{Label = "Logon Name";Expression = {$_.sAMAccountName}},
@{Label = "Job Title";Expression = {$_.Title}},
@{Label = "Company";Expression = {$_.Company}},
@{Label = "Directorate";Expression = {$_.Description}},
@{Label = "Department";Expression = {$_.Department}},
@{Label = "Office";Expression = {$_.OfficeName}},
@{Label = "Phone";Expression = {$_.telephoneNumber}},
@{Label = "Email";Expression = {$_.Mail}},
@{Label = "Manager";Expression = {%{(Get-AdUser $_.Manager -server $ADServer -Properties DisplayName).DisplayName}}},
@{Label = "Account Status";Expression = {if (($_.Enabled -eq 'TRUE')  ) {'Enabled'} Else {'Disabled'}}}, # the 'if statement# replaces $_.Enabled
@{Label = "Last LogOn Date";Expression = {$_.lastlogondate}},
@{Label = "MemberOf";Expression = {%{(((get-aduser $_.samaccountname -Properties memberof).memberof) | Get-ADGroup).samaccountname}}} | 

#Export CSV report

Export-Csv -Path $csvfile -NoTypeInformation
