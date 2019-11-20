# In my TS I put all the steps into a folder and then set that folder to continue on error.  The next folder to be run after the TS is the Error Handling folder.  It will only run if _SMSTSLastActionSucceeded equals false.  This is the code that will run.  
# The goal here is to force a human to see that something went wrong and hopefully they will update the ticket and troubleshooting will follow

$errorout = 
"!!!!! THERE WAS AN ERROR IN THE TASK SEQUENCE !!!!!`n
Please check the logs to see where things went horribly wrong`n
All Logs: C:\Windows\CCM\Logs`n
TS Log: C:\Windows\CCM\Logs\smsts.log`n
PSADT Log: C:\Windows\Software`n
After you acknowledge this message the host will boot into Windows as if everything was fine (assuming it finished installing the OS)`n
Everything is not fine.`n
Please check the logs to see what went wrong and if you can fix it, do so, and if not, let the Windows Admins know`n
> Hit any key to exit the task sequence and diag the issue"

#Read-Host -Prompt $errorout

if(!(Test-Path -Path 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe')){
    Start-Process -FilePath 'X:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "Read-Host -Prompt '$errorout'" -Wait 
} else {
    Sleep 15
    Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "Read-Host -Prompt '$errorout'" -Wait
}
