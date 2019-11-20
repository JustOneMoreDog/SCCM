# This was written to be run inside of a Task Sequence but if you modify the first three lines, you can do it outside of one.
$TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
$username = $TSEnv.Value("OSDLaptopUser")
$fullname = $TSEnv.Value("OSDLaptopFullName")
$temppass = "SomeTempPassOfYourChoosing"

New-LocalUser "$username" -Password $(ConvertTo-SecureString -AsPlainText $temppass -Force) -FullName "$fullname" -Description "$fullname's admin account" 
Add-LocalGroupMember -Group "Administrators" -Member "$username"
$usr = [ADSI]"WinNT://localhost/$username"  
$usr.passwordExpired = 1  
$usr.setinfo()

