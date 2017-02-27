@ECHO OFF
ECHO Starting Stopping of Windows Update

rem execute powershell script
powershell.exe Set-ExecutionPolicy Unrestricted LocalMachine
powershell.exe .\DisablingWindowsUpdate.ps1

ECHO Windows Update is stopped on All the VMs
