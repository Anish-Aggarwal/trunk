Param($ServerName)
set-psdebug -strict
$ErrorActionPreference = "stop" # you can opt to stagger on, bleeding, if an error occurs


$strlogfilelocation ="OutputLog.txt"        #create text file to store the contents of defaulted servers
Write-Output "" > $strlogfilelocation

# Handle any errors that occur
    Trap {
      # Handle the error
      $err = $_.Exception
      write-Output $err.Message | Tee-Object -filepath $strlogfilelocation
      while( $err.InnerException ) {
       $err = $err.InnerException
       write-Output $err.Message | Tee-Object -filepath $strlogfilelocation
       };
      # End the script.
      break
      }


## Robocopy Directories and Retain ACL's
##
## Explanation of Code:
## command source destination all sub-directories even when empty & copy all attributes, retry 1 second wait 30 seconds and output a log file

$ServerNames= Get-Content -Path ".\ServerNames.txt"
foreach($requiredserver in $ServerNames)
{
    robocopy \\DLUBBISHT30950\Rates  D:\PortRecon\trunk\TestData\ IRSCML_*.csv /S /E /COPY:DATSOU /R:1 /W:30 >>".\OutputLog.log"
}