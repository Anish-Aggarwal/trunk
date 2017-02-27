@ECHO OFF

:MAINMENU

ECHO.
ECHO ..................
ECHO SELECT THE OPTION to check which .NET FW version is installed
ECHO ..................
ECHO.
ECHO Type 1.0 to check .NET 1.0
ECHO Type 1.1 to check .NET 1.1
ECHO Type 2.0 to check .NET 2.0
ECHO Type 3.0 to check .NET 3.0
ECHO Type 3.5 to check .NET 3.5
ECHO Type 4.0c to check .NET 4.0c
ECHO Type 4.0 to check .NET 4.0
ECHO Type 4.5 to check .NET 4.5
ECHO Type 4.5.1 to check .NET 4.5.1
ECHO Type 4.5.2 to check .NET 4.5.2
ECHO Type X to Exit
ECHO.

SET /P MM=Type 1.0-4.5.2 and then press ENTER:

CLS

ECHO ============INVALID INPUT============
ECHO -------------------------------------
ECHO Please select a number from the Main
echo Menu [1.0-4.5.2]
ECHO -------------------------------------
ECHO ======PRESS ANY KEY TO CONTINUE======

PAUSE > NUL
GOTO MAINMENU

SET /P NN = Type "F" to check on servers mentioned in ServerName file or Type "D" to write the Server
IF %NN%==F GOTO Upload
IF %NN%==D GOTO upload
IF %MM%==X GOTO EOF

:Upload
powershell.exe Set-ExecutionPolicy Unrestricted LocalMachine
powershell.exe .\AllServersCheck.ps1 "%MM%" "%NN%"
ECHO Check is completed
GOTO MAINMENU

:EOF
ECHO ==============THANKYOU===============
ECHO -------------------------------------
ECHO ======PRESS ANY KEY TO CONTINUE======
PAUSE>NUL
EXIT
