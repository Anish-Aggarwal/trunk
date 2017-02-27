rem execute powershell script
powershell.exe Set-ExecutionPolicy Unrestricted LocalMachine

echo Reverting at the location requested > outputlog.txt && type outputlog.txt

"C:\Program Files\TortoiseSVN\bin\svn.exe" revert -R %6
if "%errorlevel%"=="1" (exit )
ECHO Revert is completed. >> outputlog.txt && type outputlog.txt


echo Taking update at the location requested >> outputlog.txt && type outputlog.txt


"C:\Program Files\TortoiseSVN\bin\svn.exe" update %6
if "%errorlevel%"=="1" (exit )

ECHO Update is completed. >> outputlog.txt && type outputlog.txt

ECHO Starting the scripting out of the files from the database >> outputlog.txt && type outputlog.txt
@ECHO OFF
powershell.exe .\GenerateScripts.ps1 -ServerName %1 -DatabaseName %2 -XMLorCSVparameter %5 -DirectoryToSaveTo ""%4"" -DirectoryToTakeFiles ""%3"" >> outputlog.txt && type outputlog.txt
if "%errorlevel%"=="1" (EXIT /B %ERRORLEVEL%)
ECHO Scripting out is complete >> outputlog.txt && type outputlog.txt



cd %6
ECHO Starting DB Build for CMRS DATABASE(s)....  >> outputlog.txt && type outputlog.txt
powershell.exe .\ExecuteScripts.ps1 "%7" %5
if exist resumeinfo.txt goto process_it 
    echo DB Build for CMRS DATABASE(s) completed. >> outputlog.txt && type outputlog.txt
    echo Please refer to out.txt for a list of files that have been executed
    echo Please refer to sqlresults.txt for output of SQL execution

    echo Committing the files in SVN >> outputlog.txt && type outputlog.txt
    "C:\Program Files\TortoiseSVN\bin\svn.exe" commit %6 -m "Adding the DMLs as per QA DBCR Automated Process"
    echo Commit is completed >> outputlog.txt && type outputlog.txt

   "C:\Program Files\TortoiseSVN\bin\svn.exe" update %8
	ECHO "`r `n" >> %8
    echo delvmpwlcmrs16 >> %8
    "C:\Program Files\TortoiseSVN\bin\svn.exe" commit %8 -m "Adding Auto QA DBCR server in deployment list"

    exit
:process_it
echo DB Build for CMRS DATABASE(s) failed >> outputlog.txt && type outputlog.txt
echo Please refer to sqlresults.txt for output of SQL execution >> outputlog.txt && type outputlog.txt
exit