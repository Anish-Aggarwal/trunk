<#
.SYNOPSIS
Gets the service dependencies for a Service
.PARAMETER Servers
Enter a ComputerName or IP Address, accepts multiple ComputerNames
.PARAMETER Services
Enter the Service Names, accepts multiple Service Names
.PARAMETER LogFileLocation
Enter the log file location
.EXAMPLE
GetDependentServices -Servers Server1,Server2 -Services Service1, Service2
.EXAMPLE
GetDependentServices -Servers c:\inputservers.txt -Services Service1, Service2
#>
Function GetDependentServices
{
[CmdletBinding()]
Param 
    (
        # Enter a ComputerName or IP Address, accepts multiple ComputerNames
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        Mandatory=$True,
        HelpMessage="Enter a ComputerName or IP Address, accepts multiple ComputerNames")] 
        [String[]]$Servers,
        [Parameter(
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        Mandatory=$True,
        HelpMessage="Enter the Service Names, accepts multiple Service Names")] 
        [String[]]$Services,
        #Enter the log file location
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        HelpMessage="Enter the log file location")] 
        [String[]]$LogFileLocation
    )
Begin 
{
    if($Servers -match "\:\\")
    {
        $ListofServers= Get-Content -Path $Servers
    }
    else 
    {
        $ListofServers=$Servers
    }
    if($LogFileLocation) #if the logfile exist remove it
    {
        Remove-Item $($LogFileLocation + "\OutputLog.txt") –erroraction silentlycontinue
    }    
}    
Process 
    {
    if($LogFileLocation)
    {
        $strDefaulterServers= $LogFileLocation + "\OutputLog.txt"        #create text file to store the contents of defaulted servers
    }
    else
    {
        $strDefaulterServers ="OutputLog.txt"        #create text file to store the contents of defaulted servers
    }

    # Initialize log files
    Write-Output "" > $strDefaulterServers
    Foreach ($computer in $ListofServers)
    {
        Foreach ($service in $Services)
        {
            Get-Service -ComputerName "$computer" -name "$service"  | Where-Object { $_.status -eq 'running'} | 
            ForEach-Object { 
            write-host -ForegroundColor 9 "Service name $($_.name)" 
              if($_.DependentServices) 
                { write-host -ForegroundColor 3 "`tServices that depend on $($_.name)" 
                  foreach($s in $_.DependentServices) 
                   { "`t`t" + $s.name } 
                } #end if DependentServices 
              if($_.RequiredServices) 
                { Write-host -ForegroundColor 10 "`tServices required by $($_.name)" 
                  foreach($r in $_.RequiredServices) 
                   { "`t`t" + $r.name } 
                } #end if DependentServices 
            } #end foreach-object
         }
    }
}
End {}
}