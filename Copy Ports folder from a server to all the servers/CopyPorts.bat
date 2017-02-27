@ECHO OFF

rem execute powershell script
powershell.exe Set-ExecutionPolicy Unrestricted LocalMachine
SET /P ServerName=Enter the Source server name for the Ports(Eg: delvmcmrstfs):


Echo Starting the Automatic Sanity Test process
powershell.exe .\CopyPorts.ps1 -ServerName %ServerName%

pause
exit