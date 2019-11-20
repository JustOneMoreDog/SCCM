$TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment

<#

Predefined Variables:
OSDComputerName

Custom Variables:
OSDBitlocker
OSDTSM
OSDOUName
OSDIPAddress
OSDEnterprise
OSDLaptopUser (ex picnicsecurity)
OSDLaptopFullName (ex Adam Littrell)

#>
$dnsserver = "1.1.1.1"

Write-Output "Starting OSDIPAddress"
# There should be only 1 active IP Address
$ipaddrobj = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object {$_.IPAddress -and $_.IPAddress[0] -notlike "169*"}
# Gets rid of the IPv6
$ipaddr = $ipaddrobj | Select-Object -ExpandProperty IPAddress | Where-Object {$_ -notlike "*:*"}
$TSEnv.Value("OSDIPAddress") = $ipadrr 
Write-Output "Done"

Write-Output "Starting OSDComputerName"
# See below for explination
$hostname = $(C:\Windows\System32\nslookup.exe $ipaddr).Split(":")[6].Trim().Split(".")[0]
# When we run the Apply Windows Settings step, the computer name will be whatever the value of OSDComputerName is
$TSEnv.Value("OSDComputerName") = $hostname

Write-Output "Starting DNS TXT Record"
# Now we can get the TXT record containing our TS customizations
# First we get the raw output
$nslookup = 'C:\windows\system32\nslookup.exe'
$nslookupargs = "-type=TXT $($hostname+".deploymentzone.company.com") $dnsserver"

# C:\windows\system32\nslookup.exe -type=TXT hostname.deploymentzone.company.com $dnsserver
[string]$nslookupout = Invoke-Expression "$nslookup $nslookupargs"

# Then we remove everything except the data
$nslookupout = $nslookupout.Split('"')[1]

# Lastly we get our tokens
$tokens = $nslookupout.Split(':')
Write-Output "TXT Data`n$tokens"
Write-Output "Finished"

Write-Output "Starting Custom TS Variables"
# Now we can loop through our tokens and set the remaining variables
foreach($token in $tokens){
    Write-Output "Working with $token"
    switch -Wildcard ($token){
       
        "tsm" { $TSEnv.Value("OSDTSM") = "true" }
        "bitlocker" { $TSEnv.Value("OSDBitlocker") = "true" }
        "user=*" { $TSEnv.Value("OSDLaptopUser") = $token.Split("=")[1] }
        "fullname=*" { $TSEnv.Value("OSDLaptopFullName") = $token.Split("=")[1] }
        "enterprise" { $TSEnv.Value("OSDEnterprise") = "true" }
        "OU*" { $TSEnv.Value("OSDOUName") = $token }
        "hostname=*" { $TSEnv.Value("OSDComputerName") = $token.Split("=")[1] }
        default { Write-Output "Grab the harmonica we panicking`n"  }

    }     
}   
Write-Output "Finished"



<###############################

nslookup command explination
This is the code block I would like to use but since we are in WinPE I do not have access to all of the cmdlets that I want I can not use it

foreach($ip in $(Get-NetIPConfiguration | Where-Object {$_.NetAdapter.Status -ne "Disconnected"} | Select-Object -ExpandProperty IPv4Address | Select-Object -ExpandProperty IPAddress)){ 
    if($hostname = $(Resolve-DnsName $ip -Server $dnsserver -ErrorAction SilentlyContinue | Select-Object -ExpandProperty NameHost)){
        $TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
        $TSEnv.Value("OSDComputerName") = $hostname.Split(".")[0] 
    } 
}

As such, I have to use nslookup which is a bummer because it makes the code look disgusting.  It is disgusting mainly because nslookup.exe is not in winpe so I have to copy it over.  Lets break it down

Worthing noting this is how I use to get the IP but I eventually switched to the less ugly WMI call
The code calls nslookup on the current IP by calling ipconfig and then splitting it by ":"s
PS C:\Users\windowsadmin> $(ipconfig).Split(":")[17]
 1.1.1.1

Then it trims it to give us our IP
1.1.1.1

Now we call nslookup to get our hostname
PS C:\Users\rgbterpadmin> nslookup 2.2.2.2
Server:  dnsserver.company.com
Address:  1.1.1.1

Name:    hostname.company.com
Address:  2.2.2.2

We can then split this on ":"s and trim again to get our name
hostname.company.com

Now we split this on "."s and grab the first token to finally get our hostname
hostname

Since the tokens that we need to customize our TS are located in the host's txt record and its txt record is stored in a different zone, we just need to append its deployment fqdn and repeat the nslookup call
hostname.deploymentzone.company.com

###############################>
