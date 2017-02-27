function RemoteShutdown { 
 
    param(
    # Enter a ComputerName or IP Address, accepts multiple ComputerNames
    [Parameter( 
    ValueFromPipeline=$True, 
    ValueFromPipelineByPropertyName=$True,
    Mandatory=$True,
    HelpMessage="Enter a ComputerName or IP Address, accepts multiple ComputerNames")] 
    [String[]]$Servers   
    ) 
    begin {        
        [string]$cmd = "CMD.EXE /C shutdown -s -f"
        if($Servers -match "\:\\")
        {
            $ListofServers= Get-Content -Path $Servers                        # Get the contents of the servers stored in Servernames text file
        }
        else 
        {
            $ListofServers=$Servers                        #assigns the server list to the single requested server
        }
          } 
    process 
        { 
            foreach($server in $ListofServers)
            {
            $newproc = Invoke-WmiMethod -class Win32_process -name Create -ArgumentList ($cmd) -ComputerName $server
            if ($newproc.ReturnValue -eq 0 ) 
                    {
                        Write-Output " Command $($command) invoked Sucessfully on $($server)" 
                    }
                    # if command is sucessfully invoked it doesn't mean that it did what its supposed to do 
                    #it means that the command only sucessfully ran on the cmd.exe of the server 
                    #syntax errors can occur due to user input
            } 
        }
        End{Write-Output "Script ...END"}
  } 