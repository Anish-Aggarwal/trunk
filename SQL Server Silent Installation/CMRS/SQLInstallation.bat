@ECHO off
echo Installing SQL Server 2008 R2
date/t
time /t
".\setup.exe" /ConfigurationFile=".\ConfigurationFile.ini" /INDICATEPROGRESS
date/t
time /t
pause
exit /b