Function ScriptOutData
{
[CmdletBinding()]
Param 
    (
        # Enter a ComputerName or IP Address
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        Mandatory=$True,
        HelpMessage="Enter a ComputerName or IP Address")] 
        [String[]]$ServerName,
        # Enter the database which is needed to be scripted out
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        Mandatory=$True,
        HelpMessage="Enter the Database Name")] 
        [String[]]$DatabaseName,
        # Enter the directory where the files need to be generated
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        Mandatory=$True,
        HelpMessage="Enter the directory where the files need to be generated")] 
        [String[]]$DirectoryToSaveTo,
        # Enter the directory where the files need to be taken
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        #Mandatory=$True,
        HelpMessage="Enter the directory where the files need to be taken")] 
        [String[]]$DirectoryToTakeFiles,
        # Enter the XML or CSV parameter to be required
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        Mandatory=$True,
        HelpMessage="Enter the XML or CSV parameter to be required")] 
        [String[]]$XMLorCSVparameter
        )
Begin {}
Process 
{
   # set "Option Explicit" to catch subtle errors
    set-psdebug -strict
    
    
    $ErrorActionPreference = "stop" # you can opt to stagger on, bleeding, if an error occurs
    # Load SMO assembly, and if we're running SQL 2008 DLLs load the SMOExtended and SQLWMIManagement libraries
    $v = [System.Reflection.Assembly]::LoadWithPartialName( 'Microsoft.SqlServer.SMO')
    if ((($v.FullName.Split(','))[1].Split('='))[1].Split('.')[0] -ne '9') {
      [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMOExtended') | out-null
      }
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
      
      
    
    #$DirectoryToTakeFiles="D:\CMRS\CMRS_Dev_Source_Database\CMRS_Scripts\01_CMRS_MASTER\DMLs\03_Client Data\QA"
    
    #if output location is not specified, save the files at input location
    if(!$DirectoryToSaveTo)
    {
        $DirectoryToSaveTo= $DirectoryToTakeFiles
    }
    
    
    #$DirectoryToSaveTo= "D:\CMRS\CMRS_Dev_Source_Database\CMRS_Scripts\01_CMRS_MASTER\DMLs\03_Client Data\QA"
    
      
    # Connect to the specified instance
    $s = new-object ('Microsoft.SqlServer.Management.Smo.Server') $ServerName
    # Create the Database root directory if it doesn't exist
    #$homedir = "$DirectoryToSaveTo\$Database\"
    #if (!(Test-Path -path $homedir))
    #  {Try { New-Item $homedir -type directory | out-null } 
    #     Catch [system.exception]{
    #        Write-Error "error while creating '$homedir'  $_"
     #       return
     #       } 
     # }
      

    #get the required tables present in the location specified by the user
      
    #$Eliminate = @("*common.Message.Table*", "*common.SDRMessage.Table*", "*common.RegulationMessage.Table*", "*common.EventsMessage.Table*", "*common.ProductRegulation.Table*", "*common.LegalEntityMessageDesitnationMap*")
    $Eliminate = @("*common.ProductRegulation.Table*", "*common.LegalEntityMessageDesitnationMap*", "*common.User.Table*", "*common.UserTokenInformation.Table*", "*common.SystemConfiguration_BinaryValue*", "*common.RoleToUserMapping*")
    $sqlFiles = gci -recurse "$DirectoryToTakeFiles" -Exclude $Eliminate | ? {$_.extension -eq ".sql"} | 
    Sort-Object Name | foreach-object -process { $_.Name } | Sort-Object| Out-File -filepath "$DirectoryToTakeFiles\sql.txt"
    
    if($XMLorCSVparameter -eq "CSV")
    {
        
        Get-Content "$DirectoryToTakeFiles\sql.txt" | Where-Object {($_ -match 'Table')} | Set-Content "$DirectoryToTakeFiles\interimout.txt"
        
        Get-Content "$DirectoryToTakeFiles\interimout.txt" | Where-Object {($_ -notmatch '_XML')} | Set-Content "$DirectoryToTakeFiles\out.txt"
        Remove-Item "$DirectoryToTakeFiles\sql.txt"
        Remove-Item "$DirectoryToTakeFiles\interimout.txt"
    }
    else
    {
        Get-Content "$DirectoryToTakeFiles\sql.txt" | Where-Object {($_ -match 'Table')} | Set-Content "$DirectoryToTakeFiles\interimout.txt"
        Get-Content "$DirectoryToTakeFiles\interimout.txt" | Where-Object {($_ -notmatch '_CSV')} | Set-Content "$DirectoryToTakeFiles\out.txt"
        Remove-Item "$DirectoryToTakeFiles\sql.txt"
        Remove-Item "$DirectoryToTakeFiles\interimout.txt"
    }
    
    #################################################
    
    $namesoftables=Get-Content "$DirectoryToTakeFiles\out.txt"
    
            
    foreach($tablenamewithsequence in $namesoftables)
    {        
        #get the database table name
        if($tablenamewithsequence -like "*_CSV*")
        {
            $start = $tablenamewithsequence.indexOf("_") + 1
            $end = $tablenamewithsequence.indexOf("_CSV", $start)
            $length = $end - $start
            $dbtablename = $tablenamewithsequence.substring($start, $length)
            $dbtablename = $tablenamewithsequence.substring($start, $length)
        }
        elseif($tablenamewithsequence -like "*_XML*")
        {
            $start = $tablenamewithsequence.indexOf("_") + 1
            $end = $tablenamewithsequence.indexOf("_XML", $start)
            $length = $end - $start
            $dbtablename = $tablenamewithsequence.substring($start, $length)
            $dbtablename = $tablenamewithsequence.substring($start, $length)
        }
        else
        {
            $start = $tablenamewithsequence.indexOf("_") + 1
            $end = $tablenamewithsequence.indexOf(".Table", $start)
            $length = $end - $start
            $dbtablename = $tablenamewithsequence.substring($start, $length)
            $dbtablename = $tablenamewithsequence.substring($start, $length)
        }
        #############################################
        
        
        
        #$dbtablename = $node.Value
        #$tablenames= $node.Sequence + '_' + $node.Value
        $SavePath="$($DirectoryToSaveTo)\$tablenamewithsequence"
       # create the directory if necessary (SMO doesn't).
       #if (!( Test-Path -path $SavePath )) # forcibly create if existing
       #{
       Try 
            { 
            New-Item $SavePath -type file -Force | out-null 
           
            $scripter = new-object ('Microsoft.SqlServer.Management.Smo.Scripter') $s
            $scripter.Options.ScriptSchema = $False; #no we're not scripting the schema
            $scripter.Options.ScriptData = $true; #but we're scripting the data
            $scripter.Options.NoCommandTerminator = $true;
            



            $scripter.Options.Filename = "$SavePath";

            $scripter.Options.AnsiFile = $true


            #$scripter.Options.FileName = $homedir+$Filename #writing out the data to file
            $scripter.Options.ToFileOnly = $true #who wants it on the screen?
            $ServerUrn=$s.Urn #we need this to construct our URNs.
            $UrnsToScript = New-Object Microsoft.SqlServer.Management.Smo.UrnCollection
            #so we just construct the URNs of the objects we want to script
            #$Table=@()
            #foreach ($tablepath in $TableList -split ',')
            #{
            $Tuple = "" | Select Database, Schema, Table
              #$TableName=$tablepath.Trim() -split '.',0,'SimpleMatch'
            $TableName=$dbtablename.Trim() -split '.',0,'SimpleMatch'
               
             switch ($TableName.count)
              {
                  1 { $Tuple.database=$DatabaseName; $Tuple.Schema='dbo'; $Tuple.Table=$tablename[0];  break}
                  2 { $Tuple.database=$DatabaseName; $Tuple.Schema=$tablename[0]; $Tuple.Table=$tablename[1];  break}
                  3 { $Tuple.database=$tablename[0]; $Tuple.Schema=$tablename[1]; $Tuple.Table=$tablename[2];  break}
                  default {throw 'too many dots in the tablename'}
              }
               #$Table += $Tuple
               #}
                #foreach ($tuple in $Table)
             # {
            $Urn="$ServerUrn/Database[@Name='$($Tuple.database)']/Table[@Name='$($Tuple.table)' and @Schema='$($Tuple.schema)']";
            Write-Output "$urn"
           $UrnsToScript.Add($Urn)
              #}
            #and script them
            $scripter.EnumScript($UrnsToScript) #Simple eh?
            "Saved to $homedir"+', wondrous carbon-based life form!'
            "done!"
            
            $contextFileName= $DatabaseName + "Context.txt"
            
            #locationfor CMRS Context
            #cd "D:\CMRS Operations\Scripts\Script out Data from the database"
            
            (Get-Content ".\CMRS_MASTERcontext.txt") | Insert-Content $SavePath 
                        
             }
        Catch [system.exception]{
                Write-Error "error while creating '$SavePath' $_"
                return
             }       
    } 
}    
end{}
}


function Insert-Content {
param ( [String]$Path )
process {
$( ,$_; Get-Content $Path -ea SilentlyContinue) | Out-File $Path -Encoding ASCII
}
}