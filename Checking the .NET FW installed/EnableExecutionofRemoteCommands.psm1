##########################################################################
#
# Purpose:Enable execution of Powershell Scripts on another Servers
# Author:Anish Aggarwal
# Written on: 14th July, 2014 
# Input parameters - 
#
##########################################################################
Import-Module -Name ".\PSRemoting.psm1" -DisableNameChecking

function EnableExecutionofRemoteCommands
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
        [String[]]$Server        
    )
Begin 
{
     
}
Process 
{
    Set-WinRMListener -ComputerName $Server
    Restart-WinRM -ComputerName $Server    
    Set-WinRMStartup -ComputerName $Server    
    Set-WinRMFirewallRule -ComputerName $Server    
    Restart-WindowsFirewall -ComputerName $Server
}
End {}
}