# SCCM Scripts

#### Add-LaptopAdmin
* Adds a local admin account onto the host.  Designed to be used on laptops since desktops should be authenticating with AD

#### Invoke-ErrorMessage
* To be run if my Task Sequence has an error

#### Get-TSVariables
* I have a Powershell script that does all the preflight gathering and setting needed to prestage a host for installation.  In that script, a DNS TXT in a custom DNS Zone record is made.  This record contains token strings that will enable or disable steps in the task sequence.  In order to get this information though, I need to get the current host's IP address and then perform a couple DNS lookups.  This script automates the entire process.  
