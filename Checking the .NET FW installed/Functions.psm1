##########################################################################
#
# Purpose: Functions that help in checking the .NET FW installed 
# Author:Anish Aggarwal
# Written on: 14th August, 2014 
#
##########################################################################
<#
.SYNOPSIS
Helps in getting the version of .NET FW installed
.PARAMETER Servers
Enter a ComputerName or IP Address, accepts multiple ComputerNames
.PARAMETER LogFileLocation
Enter the log file location
.PARAMETER frameWorktobeChecked
Enter the .NET FW to be checked
.EXAMPLE
GetInfoonFrameworkVersion -Server Server1,Server2 -frameworkVersionRequired <FW like 4.0,4.5,4.5.1,4.5.2,3.5, etc>
.EXAMPLE
GetInfoonFrameworkVersion -Server Server1,Server2 -LogFileLocation <some location>
#>
function GetInfoonFrameworkVersion
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
        [String[]]$Server, 
        #Enter the FrameWork Version Required
        [Parameter(
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        HelpMessage="Enter the FrameWork Version Required")] 
        [String[]]$frameworkVersionRequired
    )
Begin 
{
     
}
Process 
{    
    Foreach ($computer in $Server)
    {
        $subkeyPath=GetPathforFW($frameworkVersionRequired);                    #Registry path where the software is installed
        $subkeyPathKey=GetPathKeyforFW($frameworkVersionRequired);                    #Key to differentiate between different versions
        $Hive = [Microsoft.Win32.RegistryHive]'LocalMachine'                    #Gets the registry Hive of HKEY_LOCAL_MACHINE
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$computer)                    #Create registry key class taking Hive and Server as parameters
        $regkey = $reg.OpenSubkey($subkeyPath);                    #Creates the registry key for the Registry Path mentioned
        $serialkey = $regkey.GetValue($subkeyPathKey);                    #Gets the keyValue for the Registry Path
        
        if($serialkey)
        {
            switch($serialkey)
            {
                "1" {
                if($frameworkVersionRequired -le "4.0"){
                    Write-Output ".NET FrameWork $frameworkVersionRequired is installed"
                    }
                else{
                    Write-Output "Required framework is not installed"
                    }
                }
                "378389" {
                if($frameworkVersionRequired -eq "4.5"){
                    Write-Output ".NET FrameWork 4.5 is installed"
                    }
                else{
                    Write-Output "Required framework is not installed"
                    }
                }
                "378675" {
                if($frameworkVersionRequired -eq "4.5.1"){
                    Write-Output ".NET FrameWork 4.5.1 is installed with Windows 8.1"
                    }
                else{
                    Write-Output "Required framework is not installed"
                    }
                }
                "378758" {
                if($frameworkVersionRequired -eq "4.5.1"){
                    Write-Output ".NET Framework 4.5.1 installed on Windows 8, Windows 7 SP1, or Windows Vista SP2"
                    }
                else{
                    Write-Output "Required framework is not installed"
                    }
                }
                "379893" {
                if($frameworkVersionRequired -eq "4.5.2"){
                    Write-Output ".NET FrameWork 4.5.2 is installed"
                    }
                else{
                    Write-Output "Required framework is not installed"
                    }
                }
            }
        }
        else
        {
            Write-Output "Required framework is not installed"
        }
    }   
}
End {}
}

<#
.SYNOPSIS
Helps in getting the registry path of .NET FW installed
.PARAMETER frameworkVersionRequired
Enter the .NET FW to be checked
.EXAMPLE
GetPathforFW(4.0), GetPathforFW(4.5), GetPathforFW(4.5.1)
#>
function GetPathforFW([string]$frameworkVersionRequired)
{
    switch($frameworkVersionRequired)
    {
        "1.0" {return "Software\Microsoft\.NETFramework\Policy\v1.0"}
        "1.1" {return "Software\Microsoft\NET Framework Setup\NDP\v1.1.4322"}
        "2.0" {return "Software\Microsoft\NET Framework Setup\NDP\v2.0.50727"}
        "3.0" {return "Software\Microsoft\NET Framework Setup\NDP\v3.0\Setup"}
        "3.5" {return "Software\Microsoft\NET Framework Setup\NDP\v3.5"}
        "4.0c" {return "Software\Microsoft\NET Framework Setup\NDP\v4\Client"}
        "4.0" {return "Software\Microsoft\NET Framework Setup\NDP\v4\Full"}
        "4.5" {return "Software\Microsoft\NET Framework Setup\NDP\v4\Full"}
        "4.5.1" {return "Software\Microsoft\NET Framework Setup\NDP\v4\Full"}
        "4.5.2" {return "Software\Microsoft\NET Framework Setup\NDP\v4\Full"}
    }    
}

<#
.SYNOPSIS
Helps in getting the registry path key of .NET FW installed
.PARAMETER frameworkVersionRequired
Enter the .NET FW to be checked
.EXAMPLE
GetPathKeyforFW(4.0), GetPathKeyforFW(4.5), GetPathKeyforFW(4.5.1)
#>
function GetPathKeyforFW([string]$frameworkVersionRequired)
{
    switch($frameworkVersionRequired)
    {
        "1.0" {return "3705"}
        "1.1" {return "Install"}
        "2.0" {return "Install"}
        "3.0" {return "InstallSuccess"}
        "3.5" {return "Install"}
        "4.0c" {return "Install"}
        "4.0" {return "Install"}
        "4.5" {return "Release"}
        "4.5.1" {return "Release"}
        "4.5.2" {return "Release"}
    }    
}

<#
.SYNOPSIS
Helps in Remotely running dos commands
.PARAMETER Server
Enter a ComputerName or IP Address
.PARAMETER command
Enter the dos command to be executed on the server
.PARAMETER LogFileLocation
Enter the log file location
.EXAMPLE
Run-RemoteCMD -Servers Server1 -command del *.*
#>
function Run-RemoteCMD { 
 
    param( 
    [Parameter(Mandatory=$true,valuefrompipeline=$true)] 
    [string]$compname,
    [Parameter(Mandatory=$true,valuefrompipeline=$true)] 
    [string]$command
    ) 
    begin {        
        [string]$cmd = "CMD.EXE /C " +$command
                        } 
    process { 
        $newproc = Invoke-WmiMethod -class Win32_process -name Create -ArgumentList ($cmd) -ComputerName $compname
        if ($newproc.ReturnValue -eq 0 ) 
                {
                    Write-Output " Command $($command) invoked Sucessfully on $($compname)" 
                }
                # if command is sucessfully invoked it doesn't mean that it did what its supposed to do 
                #it means that the command only sucessfully ran on the cmd.exe of the server 
                #syntax errors can occur due to user input
    } 
    End{Write-Output "Script ...END"} 
                 } 