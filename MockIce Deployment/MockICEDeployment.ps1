Param($ServerName,$DirectoryToSaveTo)
set-psdebug -strict
$ErrorActionPreference = "stop" # you can opt to stagger on, bleeding, if an error occurs

# Handle any errors that occur
    Trap {
      # Handle the error
      $err = $_.Exception
      write-Output $err.Message
      while( $err.InnerException ) {
       $err = $err.InnerException
       write-Output $err.Message
       };
      # End the script.
      break
      }

Import-Module .\Services.psm1 -DisableNameChecking
$homedir = "$DirectoryToSaveTo\CMRS_Automation\MockIce"

$strlogfilelocation ="OutputLog.txt"        #create text file to store the contents of defaulted servers
Write-Output "" > $strlogfilelocation

#Checkif MockIce folder is present or not. If not create it

if (!(Test-Path -path $homedir)){
    Try { 
    New-Item $homedir -type directory | out-null
    Write-Output "Folder Created" | Tee-Object -filepath $strlogfilelocation
    } 
    Catch [system.exception]{
        Write-Error "error while creating '$homedir'  $_" | Tee-Object -filepath $strlogfilelocation
        return
    }
}

#stop IIS
ManageWindowsService -Servers $ServerName -Services "WAS" -Action "Stop"
Write-Output "IIS Stopped" | Tee-Object -filepath $strlogfilelocation

#Copy contents from \\blrcmrsdepauto\CMRS_Automation\MockICE\Depolyment to $homedir/Deployment
robocopy "\\blrcmrsdepauto\CMRS_Automation\MockICE\Depolyment" "$homedir\Deployment"  /E /XN /xf *.txt
Write-Output "Copied contents from \\blrcmrsdepauto\CMRS_Automation\MockICE\Depolyment to $homedir/Deployment"  | Tee-Object -filepath $strlogfilelocation

#Copy contents from \\blrcmrsdepauto\CMRS_Automation\MockICE\DataBase to $homedir/DataBase
robocopy "\\blrcmrsdepauto\CMRS_Automation\MockICE\DataBase" "$homedir\DataBase"  /E /XN /xf *.txt
Write-Output "contents from \\blrcmrsdepauto\CMRS_Automation\MockICE\DataBase to $homedir/DataBase"  | Tee-Object -filepath $strlogfilelocation

#delete and overwrite CMRS_MOCK_ICE with MockIce.bak present in $homedir/DataBase
CMD.EXE /C "sqlcmd.exe -b -S $ServerName -i `".\DeleteandRestore.sql`" -v DriveParam = `$DirectoryToSaveTo`""
Write-Output "Mock Ice Database Restored"  | Tee-Object -filepath $strlogfilelocation
#update blrcmrsdepauto tag with the $ServerName in Web.Config in $homedir\Depolyment\Sapient.Cmrs.MockIceTradeVault
$file="$homedir\Depolyment\Sapient.Cmrs.MockIceTradeVault\Web.config"
Write-Output "Updated blrcmrsdepauto tag with the $ServerName in Web.Config"  | Tee-Object -filepath $strlogfilelocation

Get-Content $file | ForEach-Object { $_ -replace "blrcmrsdepauto", $ServerName } | Set-Content ($file+".tmp")
Remove-Item $file
Rename-Item ($file+".tmp") $file



#Point the Sapient.Cmrs.MockIceTradeVault with the correct location
#"C:\Windows\System32\Inetsrv\AppCmd.exe" set app "Default Web Site/Sapient.Cmrs.MockIceTradeVault" -[path='/'].physicalPath:"$homedir\Deployment\Sapient.Cmrs.MockIceTradeVault"
CMD.EXE /C "C:\Windows\System32\Inetsrv\AppCmd.exe set app `"Default Web Site/Sapient.Cmrs.MockIceTradeVault`" -[path='/'].physicalPath:`"$homedir\Deployment\Sapient.Cmrs.MockIceTradeVault`""
Write-Output "Pointed the Sapient.Cmrs.MockIceTradeVault with the correct location"

#IISStart
ManageWindowService -Servers $ServerName -Services "WAS" -Action "Start"
Write-Output "IIS Started" | Tee-Object -filepath $strlogfilelocation

#Query to update the webpath of Sapient.Cmrs.MockIceTradeVault in Track_N_Trace
sqlcmd.exe -b -S $ServerName -i ".\UpdateMockIcePath.sql"
Write-Output "Updated the webpath of Sapient.Cmrs.MockIceTradeVault in httpqueryparameter table" | Tee-Object -filepath $strlogfilelocation

#Delete the data in tables of MockIce Database
sqlcmd.exe -b -S $ServerName -i ".\DeletedataintablesofMockIce.sql"
Write-Output "Delete the data in tables of MockIce Database" | Tee-Object -filepath $strlogfilelocation