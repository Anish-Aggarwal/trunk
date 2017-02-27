@ECHO OFF

SET /P ServerName=Enter the Source database server name(Eg: blrcmrsdevitg):
SET /P DatabaseName=Enter the Database Name (Eg: CMRS_MASTER):
SET /P InputPath=Enter the Input File Location:
SET /P OutputPath=Enter the Output Location:

SET /P DBType=Enter the XML or CSV Associations required (Eg: XML or CSV):

SET /P BuildLocation=Enter the Database Build location:
SET /P BuildServer=Enter the Server where the DB is to be build:

rem BuildLocation = "%BuildLocation%"

rem execute powershell script
powershell.exe Set-ExecutionPolicy Unrestricted LocalMachine

echo Reverting at the location requested > outputlog.txt && type outputlog.txt

"C:\Program Files\TortoiseSVN\bin\svn.exe" revert -R %BuildLocation%
if "%errorlevel%"=="1" (exit ) 

ECHO Revert is completed >> outputlog.txt && type outputlog.txt

echo Taking update at the location requested > outputlog.txt && type outputlog.txt

"C:\Program Files\TortoiseSVN\bin\svn.exe" update %BuildLocation%
if "%errorlevel%"=="1" (exit ) 
ECHO Update is completed. >> outputlog.txt && type outputlog.txt

ECHO Starting the database scripting >> outputlog.txt && type outputlog.txt
@ECHO OFF
powershell.exe .\GenerateScripts.ps1 -ServerName %ServerName% -DatabaseName %DatabaseName% -XMLorCSVparameter %DBType% -DirectoryToSaveTo ""%OutputPath%"" -DirectoryToTakeFiles ""%InputPath%""
if "%errorlevel%"=="1" (EXIT /B %ERRORLEVEL%) 
ECHO Scripting out is complete >> outputlog.txt && type outputlog.txt


cd %BuildLocation%
ECHO Starting DB Build for CMRS DATABASE(s).... >> outputlog.txt && type outputlog.txt
powershell.exe .\ExecuteScripts.ps1 "%BuildServer%" %DBType%
if exist resumeinfo.txt goto process_it 
    echo DB Build for CMRS DATABASE(s) completed. >> outputlog.txt && type outputlog.txt
    echo Please refer to out.txt for a list of files that have been executed >> outputlog.txt && type outputlog.txt
    echo Please refer to sqlresults.txt for output of SQL execution >> outputlog.txt && type outputlog.txt

    echo Committing the files in SVN >> outputlog.txt && type outputlog.txt
    "C:\Program Files\TortoiseSVN\bin\svn.exe" commit %OutputPath% -m "Adding the DMLs as per QA DBCR Automated Process"
    echo Commit is completed >> outputlog.txt && type outputlog.txt
    pause
    exit
:process_it
echo DB Build for CMRS DATABASE(s) failed >> outputlog.txt && type outputlog.txt
echo Please refer to sqlresults.txt for output of SQL execution >> outputlog.txt && type outputlog.txt
pause
exit