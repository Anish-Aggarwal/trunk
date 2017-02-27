###############################################################################
#
# Purpose: To Manage the Windows Services in a VM and output the create a Log File 
#          OutputLog.txt at the mentioned location
# 
# Author:  Anish Aggarwal
#
# Written on: 11th August, 2014 
#
###############################################################################

<#
.SYNOPSIS
Sets the startup mode for the specified service
.PARAMETER computer
Enter a ComputerName or IP Address
.PARAMETER service
Enter the Service Name
.PARAMETER mode
Enter the mode for the servive like Automatioc, Disable and Manual
.EXAMPLE
SetServiceStartup -Server Server1 -service Service1 -mode Automatic, Disable
#>
Function SetServiceStartup
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
        [String[]]$computer,
        # Enter the Service for which Startup mode needs to be changed
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        Mandatory=$True,
        HelpMessage="Enter the Service for which Startup mode needs to be changed")] 
        [String[]]$service,
        #Enter the mode for the Service
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        Mandatory=$True,
        HelpMessage="Enter the mode for the Service < Automatic | Disable | | >")] 
        [String[]]$mode
    )
Begin {}
Process 
{
    Write-Verbose "Beginning function on $computer"
    Try
    {
        if (((Get-WmiObject win32_service -Filter "name='$service'" -ComputerName $computer).ChangeStartMode($mode)).ReturnValue -ne 0) 
        {
            Throw "Failed to change $service Startup type on $computer"
        }
    }
    Catch
    {
        Write-Warning $_.exception.message
        Write-Warning "Failed to change startmode on the $service service for $computer"
        Write-Output "Failed to change startmode on the $service service for $computer"
    }      
}
}
<#
.SYNOPSIS
Stops the specified service
.PARAMETER computer
Enter a ComputerName or IP Address
.PARAMETER service
Enter the Service Name
.EXAMPLE
StopService -Server Server1 -service Service1
#>
Function StopService
{
[CmdletBinding()]
Param 
    (
        # Enter a ComputerName or IP Address, accepts multiple ComputerNames
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        Mandatory=$True,
        HelpMessage="Enter a ComputerName or IP Address")] 
        [String[]]$computer,
        # Enter the Service to be stopped
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        Mandatory=$True,
        HelpMessage="Enter the Service to be stopped")] 
        [String[]]$service
    )
Begin {}
Process 
    {         
        Write-Verbose "Beginning function on $computer"
        Write-Output "Beginning function on $computer"
        Try
            {
                Write-Verbose "Attempting to stop $service"
                Write-Output "Attempting to stop $service"
                (Get-WmiObject win32_service -Filter "Name='$service'" -ComputerName $computer).StopService() | Out-Null
                Start-Sleep -Seconds 10
                if ((Get-WmiObject win32_service -Filter "Name='$service'" -ComputerName $computer).state -notlike "Stopped") {Throw "Failed to Stop WinRM"}
            }
        Catch 
            {
                Write-Warning $_.exception.message
                Write-Warning "The function will abort operations on $computer"
                $problem = $true
            }
        #if ($problem) {$problem = $false} 
        #Else {
        Write-Verbose "Successfully completed operation on $computer"
        Write-Output "Successfully completed operation on $computer"
        #}             
    }
End {}
}
<#
.SYNOPSIS
Starts the specified service
.PARAMETER computer
Enter a ComputerName or IP Address
.PARAMETER service
Enter the Service Name
.EXAMPLE
StartService -Server Server1 -service Service1
#>
Function StartService
{
[CmdletBinding()]
Param 
    (
        # Enter a ComputerName or IP Address, accepts multiple ComputerNames
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        Mandatory=$True,
        HelpMessage="Enter a ComputerName or IP Address")] 
        [String[]]$computer,
        #Enter the Service to be started
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        Mandatory=$True,
        HelpMessage="Enter the Service to be started")] 
        [String[]]$service
    )
Begin {}
Process 
    {
        Write-Verbose "Beginning function on $computer"
        Try 
            {
                Write-Verbose "Attempting to start $service"
                (Get-WmiObject win32_service -Filter "Name='$service'" -ComputerName $computer).StartService() | Out-Null
                Start-Sleep -Seconds 10
                if ((Get-WmiObject win32_service -Filter "Name='$service'" -ComputerName $computer).state -notlike "Running") {Throw "Failed to Start $service"}
            }
        Catch
            {
                Write-Warning $_.exception.message
                Write-Warning "The function will abort operations on $computer"
                $problem = $true
            }
        #if ($problem) {$problem = $false} 
        Write-Verbose "Successfully completed operation on $computer"
    }
End {}
}

<#
.SYNOPSIS
Restarts the specified service
.PARAMETER computer
Enter a ComputerName or IP Address
.PARAMETER service
Enter the Service Name
.EXAMPLE
ReStartService -Server Server1 -service Service1
#>
Function ReStartService
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
        [String[]]$computer,
        # Enter the Service to be restarted
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        Mandatory=$True,
        HelpMessage="Enter the Service to be restarted")] 
        [String[]]$service
    )
Begin {}
Process 
    {
        Write-Verbose "Beginning function on $computer"
        Try
            {
                Write-Verbose "Attempting to stop $service"
                (Get-WmiObject win32_service -Filter "Name='$service'" -ComputerName $computer).StopService() | Out-Null
                Start-Sleep -Seconds 10
                if ((Get-WmiObject win32_service -Filter "Name='$service'" -ComputerName $computer).state -notlike "Stopped") {Throw "Failed to Stop $service"}
            }
        Catch 
            {
                Write-Warning $_.exception.message
                Write-Warning "The function will abort operations on $Computer"
                $problem = $true
            }
        if (-not($problem))
            {
                Try 
                    {
                        Write-Verbose "Attempting to start $service"
                        (Get-WmiObject win32_service -Filter "Name='$service'" -ComputerName $computer).StartService() | Out-Null
                        Start-Sleep -Seconds 10
                        if ((Get-WmiObject win32_service -Filter "Name='$service'" -ComputerName $computer).state -notlike "Running") {Throw "Failed to Start $service"}
                    }
                Catch
                    {
                        Write-Warning $_.exception.message
                        Write-Warning "The function will abort operations on $Computer"
                        $problem = $true
                    }
            }
        if ($problem) {$problem = $false} 
        Else {Write-Verbose "Successfully completed operation on $computer"}              
    }
End {}
}
<#
.SYNOPSIS
Helps in Managing Windows Service
.PARAMETER Servers
Enter a ComputerName or IP Address, accepts multiple ComputerNames
.PARAMETER Services
Enter the Service Names, accepts multiple Service Names
.PARAMETER Action
Enter the Action required like Start, Stop and Restart
.PARAMETER SetStartupType
Enter the SetStartupType required like Disable, Manual and Automatic
.PARAMETER LogFileLocation
Enter the log file location
.EXAMPLE
ManageWindowsService -Servers Server1,Server2 -Services Service1, Service2 -Action Start, Stop, Restart
.EXAMPLE
ManageWindowsService -Servers Server1,Server2 -Services Service1, Service2 -SetStartupType Automatic, Disable, Manual
.EXAMPLE
ManageWindowsService -Servers Server1,Server2 -Services Service1, Service2 -SetStartupType Automatic, Disable, Manual -LogFileLocation <some location>
#>
Function ManageWindowsService
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
        #Enter the Service Names, accepts multiple Service Names
        [Parameter(
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        Mandatory=$True,
        HelpMessage="Enter the Service Names, accepts multiple Service Names")] 
        [String[]]$Services,
        #Enter the Action required like Start, Stop and Restart
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        HelpMessage="Enter the Action required like Start, Stop and Restart")] 
        [String[]]$Action,
        #Enter the SetStartupType required like Disable, Manual and Automatic
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        HelpMessage="Enter the SetStartupType required like Disable, Manual and Automatic")] 
        [String[]]$SetStartupType,
        #Enter the log file location
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        HelpMessage="Enter the log file location")] 
        [String[]]$LogFileLocation
    )
Begin {
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
            if($Action)
            {                    
                switch($Action)
                {
                   "Restart"{ReStartService -computer $computer -service $service -Verbose >> $strDefaulterServers} 
                    "Stop"{StopService -computer $computer -service $service -Verbose >> $strDefaulterServers} 
                    "Start"{StartService -computer $computer -service $service -Verbose >> $strDefaulterServers}  
                }
            }
            elseif($SetStartupType)
            {
                switch($SetStartupType)
                {
                    "Disable"{SetServiceStartup -computer $computer -service $service -mode "Disabled"  >> $strDefaulterServers} 
                    "Manual"{SetServiceStartup -computer $computer -service $service -mode "Manual"  >> $strDefaulterServers}
                    "Automatic"{SetServiceStartup -computer $computer -service $service -mode "Automatic" >> $strDefaulterServers}
                }
            }
        }
    }
}
End {}
}