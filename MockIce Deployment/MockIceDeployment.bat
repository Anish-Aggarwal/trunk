@ECHO OFF

rem execute powershell script
powershell.exe Set-ExecutionPolicy Unrestricted LocalMachine
SET /P ServerName=Enter the server name(Eg: blrcmrsdevitg):
SET /P DirectoryToSaveTo=Enter the directory(Eg: D: or E:):

Echo Starting the MockIce Deployment
powershell.exe .\MockICEDeployment.ps1 -ServerName %ServerName% -DirectoryToSaveTo %DirectoryToSaveTo%
pause
exit