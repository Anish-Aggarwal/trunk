@ECHO OFF


rem execute powershell script
powershell.exe Set-ExecutionPolicy Unrestricted LocalMachine
SET /P ServerName=Enter the server name(Eg: delvmcmrstfs):

Echo Starting the Queue Creation process
powershell.exe .\AddingCMRSQueues.ps1 -ServerName %ServerName%

pause
exit