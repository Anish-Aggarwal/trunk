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
        [String[]]$DirectoryToSaveTo
        )
Begin {}
Process 
{
   # set "Option Explicit" to catch subtle errors
    set-psdebug -strict
    #$DirectoryToSaveTo='D:\CMRS Operations\Scripts\Script out Data from the database'; # local directory to save build-scripts to
    #$ServerName='blrcmrsdevitg'; # server name and instance
    #$DatabaseName='CMRS_TRACK_N_TRACE'; # the database to copy from (Adventureworks here)
    #$Filename='MyFileName.txt';
    #$TableList='AdventureWorksDW2008R2.dbo.DimCustomer, DimCurrency, DimSalesTerritory';
    # a list of tables with possible schema or database qualifications
    # AdventureWorksDW2008R2 used for this example
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
      write-host $err.Message
      while( $err.InnerException ) {
       $err = $err.InnerException
       write-host $err.Message
       };
      # End the script.
      break
      }
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
      
    #$d=Get-Content .\TableNames.txt

    $xml = [xml](Get-Content ".\Test1.xml")
    $tablenodes = $xml.SelectNodes("/ScriptsInfo/DatabaseName[@Value ='$DatabaseName']/Table")
        
    foreach($node in $tablenodes)
    {
        $dbtablenames = $node.Value
        $tablenames= $node.Sequence + '_' + $node.Value
        $SavePath="$($DirectoryToSaveTo)\$tablenames.Table.sql"
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
            $scripter.Options.AnsiFile = $true



            $scripter.Options.Filename = "$SavePath";




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
            $TableName=$dbtablenames.Trim() -split '.',0,'SimpleMatch'
               
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
            $urn
           $UrnsToScript.Add($Urn)
              #}
            #and script them
            $scripter.EnumScript($UrnsToScript) #Simple eh?
            "Saved to $homedir"+', wondrous carbon-based life form!'
            "done!"
            
            $contextFileName= $DatabaseName + "Context.txt"
            
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
$( ,$_; Get-Content $Path -ea SilentlyContinue) | Out-File $Path
}
}