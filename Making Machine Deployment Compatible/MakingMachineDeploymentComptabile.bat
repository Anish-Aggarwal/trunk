@ECHO OFF

SET /P ServerName=Enter the Source database server name(Eg: blrcmrsdevitg):%1
SET /P Drive=Enter the Drive (Eg: D: or E:):%2
rem execute powershell script
powershell.exe Set-ExecutionPolicy Unrestricted LocalMachine

powershell.exe .\MakingMachineDeploymentComptabile.ps1 -Servers %ServerName% -Drive %Drive%