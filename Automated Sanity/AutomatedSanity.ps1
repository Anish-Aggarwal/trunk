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



$dropLocation = "\\$ServerName\Ports\DataImportService\Input\XML\BT"
#Drop a file in BT folder
robocopy ".\Sanity" "$dropLocation"  /E /XN /xf *.txt
Write-Output "A file is dropped in BT folder" | Tee-Object -filepath $strlogfilelocation 
#Start sleep for 3 seconds so that message processing can happen
Start-Sleep -s 3

#Query to check status in JobHeader table
$jobqueryOutput = sqlcmd.exe -b -S $ServerName /h-1 -i ".\StatusCheck.sql"
Write-Output "Output in JobHeader table is $jobqueryOutput" | Tee-Object -filepath $strlogfilelocation 
if($jobqueryOutput -like "Succeeded*")
{
    Write-Output "Succedding at Job Summary Stage" | Tee-Object -filepath $strlogfilelocation 
    
    #Query to get the deal status and store in Mydata.csv
    CMD.EXE /C "sqlcmd.exe -b -S $ServerName -i `".\MessageFlowCheck.sql`" -o `".\MyData.csv`" /h-1 -s`",`""
    $MessageStageWiseDetail = @()
    $StageStatus = @()
    
    Write-Output "MyData.csv is created with the Deal details" | Tee-Object -filepath $strlogfilelocation 
    
    #Add the details in csv to array
    Import-Csv ".\MyData.csv"  -header ("MessageStageWiseDetail","StageStatus") |
    ForEach-Object {
        $MessageStageWiseDetail += $_.MessageStageWiseDetail
        $StageStatus += $_.StageStatus
    }
    
    #Remove the csv
    Remove-Item ".\MyData.csv"
    Write-Output "MyData.csv is removed" | Tee-Object -filepath $strlogfilelocation 
    
    if ($StageStatus -like "Failed*")
    {
        Write-Output "Message Processing Failed" | Tee-Object -filepath $strlogfilelocation 
        $Where = [array]::IndexOf($StageStatus, "Failed")
        $errorCodeId=$MessageStageWiseDetail[$Where]
        
        #Get the error and save it in errorOutput.txt
        CMD.EXE /C "sqlcmd.exe -b -S $ServerName -i `".\ErrorCodeCheck.sql`" -o `".\errorOutput.txt`" -v ErrorCodeId = $errorCodeId "
        Write-Output "Check the errorOutput.txt to check the errors"  | Tee-Object -filepath $strlogfilelocation 
    }
    else
    {
        Write-Output "Message Processing is working" | Tee-Object -filepath $strlogfilelocation 
    }
}
else 
{
    Write-Output "Not Succedding at Job Summary Stage" | Tee-Object -filepath $strlogfilelocation 
}