@ECHO OFF
ECHO Starting DB Build for CMRS DATABASE(s)....

rem execute powershell script
powershell.exe Set-ExecutionPolicy Unrestricted LocalMachine
powershell.exe .\ExecuteScripts.ps1 %1


ECHO DB Upgrade for CMRS DATABASE(s) completed.
ECHO Please refer to out.txt for a list of files that have been executedexecution results
ECHO Please refer to seachresults.txt for output of SQL execution

rem start notepad.exe out.txt