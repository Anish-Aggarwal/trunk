@ECHO OFF

rem execute powershell script
powershell.exe Set-ExecutionPolicy Unrestricted LocalMachine
powershell.exe .\Uninstall.ps1
