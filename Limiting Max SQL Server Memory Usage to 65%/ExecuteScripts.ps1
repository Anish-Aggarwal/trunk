Param($ServerName)

Try
{
    # Declare and initialize local varialbes
    $strOutputEnd    = "`r`n"
    $nExecutionCount = 1
    $nResumeCount    = 0	

    # Constants for file names
    set-variable strOutFile        "out.txt"        -Option ReadOnly
    Set-Variable strErrorFile      "errorlog.txt"   -Option ReadOnly
    Set-Variable strSqlFile        "sqlresults.txt" -Option ReadOnly
    Set-Variable strResumeInfoFile "resumeinfo.txt" -Option ReadOnly

    # Initialize log files
	Write-Output "Starting with DB upgrade..."
	Write-Output "Starting with DB upgrade..." > $strOutFile
    Write-Output "" > $strSqlFile
    Write-Output "" > $strErrorFile
    
    Try
    {
		Write-Output "Checking for resume information..."
		Write-Output "Checking for resume information..." >> $strOutFile
        
        # Read resume infomration, if exists from resumeinfo
        $strResumeContent = Get-Content $strResumeInfoFile -EA SilentlyContinue

        $nResumeCount = [int32]::Parse($strResumeContent)

		Write-Output "Resume information found"
		Write-Output "Resume information found" >> $strOutFile

        # Delete resume information
        del $strResumeInfoFile -EA SilentlyContinue
    }
    Catch
    {
        # DO Nothing - log a message and continue execution
        # All SQL files will be processed in this case
        # Possible reasons for exception are:
        #     1. File not found
        #     2. Content of the file is invalid (not a number)

		Write-Output "Unable to retrieve resume information. It may not be present"
		Write-Output "Unable to retrieve resume information. It may not be present" >> $strOutFile
    }

    $files = (Get-Childitem -Recurse -filter "*.sql" | Sort-Object Name | foreach-object -process { $_.FullName } | Sort-Object ) 

	foreach ($file in $files)
	{
        If($nResumeCount -gt $nExecutionCount)
        {
		    Write-Output "Ignoring: $file"
		    Write-Output "Ignoring: $file" >> $strOutFile
            
            $nExecutionCount++
            continue
        }
        Else
        {
		    Write-Output "Executing: $file"
		    Write-Output "Executing: $file" >> $strOutFile
        }

        $strOutputStart = "----------------- $file -----------------"
        Get-Content $file | ForEach-Object { $_ -replace "Domain", $ServerName } | Set-Content ($file+".tmp")
        Remove-Item $file
        Rename-Item ($file+".tmp") $file
		$strSqloutput   = sqlcmd.exe -b -S $ServerName -i $file
	Get-Content $file | ForEach-Object { $_ -replace $ServerName, "Domain" } | Set-Content ($file+".tmp")
        Remove-Item $file
        Rename-Item ($file+".tmp") $file

        Write-Output $strOutputStart $strSqloutput $strOutputEnd >> $strSqlFile

        if(($LASTEXITCODE -ne 0) -and ($LASTEXITCODE -ne $null))
        {
            Throw "SQL error occurred while executing file: $file";
        }

        # increment execution count
        $nExecutionCount++
	}

	Write-Output "Upgrade Completed. Please review $strSqlFile"
	Write-Output "Upgrade Completed. Please review $strSqlFile" >> $strOutFile
}
Catch
{
	Write-Output "Upgrade process aborted. Please review $strErrorFile and $strSqlFile for details around errors"
	Write-Output "Upgrade process aborted. Please review $strErrorFile and $strSqlFile for details around errors" >> $strOutFile
	Write-Output $_.Exception.Message > $strErrorFile
    
    # persist resume information
    Write-Output $nExecutionCount > $strResumeInfoFile
}