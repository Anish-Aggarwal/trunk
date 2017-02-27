Function Set-WINRMListener
{
[cmdletBinding()]
Param
    (
        # Enter a ComputerName or IP Address, accepts multiple ComputerNames
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        Mandatory=$True,
        HelpMessage="Enter a ComputerName or IP Address, accepts multiple ComputerNames")] 
        [String[]]$ComputerName,
        [Parameter(
        HelpMessage="Enter the IPv4 address range for the WinRM listener")]
        [String]$IPv4Range = '*',
        [Parameter(
        HelpMessage="Enter the IPv4 address range for the WinRM listener")]
        [String]$IPv6Range = '*'
    )
Begin
    {
        $HKLM = 2147483650
        $Key = "SOFTWARE\Policies\Microsoft\Windows\WinRM\Service"
        $DWORDName = "AllowAutoConfig" 
        $DWORDvalue = "0x1"
        $String1Name = "IPv4Filter"
        $String2Name = "IPv6Filter"
    }
Process
    {
        Foreach ($computer in $ComputerName)
            {
                Write-Verbose "Beginning function on $computer"
                Try
                    {
                        Write-Verbose "Attempting to create remote registry handle"
                        $Reg = New-Object -TypeName System.Management.ManagementClass -ArgumentList \\$computer\Root\default:StdRegProv
                    }
                Catch 
                    {
                        Write-Warning $_.exception.message
                        Write-Warning "The function will abort operations on $Computer"
                        $problem =$true
                    }
                if (-not($problem))
                    {
                        Try 
                            {
                                Write-Verbose "Attempting to create Remote Key"
                                if (($reg.CreateKey($HKLM, $key)).returnvalue -ne 0) {Throw "Failed to create key"}
                            }
                        Catch 
                            {
                                Write-Warning $_.exception.message
                                Write-Warning "The function will abort operations on $Computer"
                                $problem =$true
                            }
                    }
                if (-not($problem))
                    {
                        Try 
                            {
                                Write-Verbose "Attemping to set DWORD value"
                                if (($reg.SetDWORDValue($HKLM, $Key, $DWORDName, $DWORDvalue)).ReturnValue -ne 0) {Throw "Failed to set DWORD"}
                            }
                        Catch 
                            {
                                Write-Warning $_.exception.message
                                Write-Warning "The function will abort operations on $Computer"
                                $problem =$true
                            }
                    }
                if (-not($problem))
                    {
                        Try 
                            {
                                Write-Verbose "Attempting to set first REG_SZ Value"
                                if (($reg.SetStringValue($HKLM, $Key, $String1Name, $IPv4Range)).ReturnValue -ne 0) {Throw "Failed to set REG_SZ"}
                            }
                        Catch 
                            {
                                Write-Warning $_.exception.message
                                Write-Warning "The function will abort operations on $Computer"
                                $problem =$true
                            }
                    }
                if (-not($problem))
                    {
                        Try 
                            {
                                Write-Verbose "Attempting to set second REG_SZ Value"
                                if (($reg.SetStringValue($HKLM, $Key, $String2Name, $IPv6Range)).ReturnValue -ne 0) {Throw "Failed to set REG_SZ"}
                            }
                        Catch 
                            {
                                Write-Warning $_.exception.message
                                Write-Warning "The function will abort operations on $Computer"
                                $problem =$true
                            }
                    }
                if ($problem) {$problem = $false} 
                Else {Write-Verbose "Successfully completed operation on $computer"}
            }
    }
End {}
}

Function Restart-WinRM
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
        [String[]]$ComputerName
    )
Begin {}
Process 
    {
         Foreach ($computer in $ComputerName)
            {
                Write-Verbose "Beginning function on $computer"
                Try
                    {
                        Write-Verbose "Attempting to stop WinRM"
                        (Get-WmiObject win32_service -Filter "Name='WinRM'" -ComputerName $computer).StopService() | Out-Null
                        Start-Sleep -Seconds 1
                        if ((Get-WmiObject win32_service -Filter "Name='WinRM'" -ComputerName $computer).state -notlike "Stopped") {Throw "Failed to Stop WinRM"}
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
                                Write-Verbose "Attempting to start WinRM"
                                (Get-WmiObject win32_service -Filter "Name='WinRM'" -ComputerName $computer).StartService() | Out-Null
                                Start-Sleep -Seconds 1
                                if ((Get-WmiObject win32_service -Filter "Name='WinRM'" -ComputerName $computer).state -notlike "Running") {Throw "Failed to Start WinRM"}
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
    }
End {}
}

Function Set-WinRMStartup
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
        [String[]]$ComputerName
    )
Begin {}
Process 
    {
         Foreach ($computer in $ComputerName)
            {
                Write-Verbose "Beginning function on $computer"
                Try
                    {
                        if (((Get-WmiObject win32_service -Filter "name='WinRM'" -ComputerName $computer).ChangeStartMode('Automatic')).ReturnValue -ne 0) {Throw "Failed to change WinRM Startup type on $Computer"}
                    }
                Catch
                    {
                        Write-Warning $_.exception.message
                        Write-Warning "Failed to change startmode on the WinRM service for $computer"
                    }
            }
    }
}

Function Set-WinRMFirewallRule
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
        [String[]]$ComputerName
    )
Begin 
    {
        $HKLM = 2147483650
        $Key = "SOFTWARE\Policies\Microsoft\WindowsFirewall\FirewallRules"
        $Rule1Value = "v2.20|Action=Allow|Active=TRUE|Dir=In|Protocol=6|Profile=Public|LPort=5985|RA4=LocalSubnet|RA6=LocalSubnet|App=System|Name=@FirewallAPI.dll,-30253|Desc=@FirewallAPI.dll,-30256|EmbedCtxt=@FirewallAPI.dll,-30267|"
        $Rule1Name = "WINRM-HTTP-In-TCP-PUBLIC"
        $Rule2Value = "v2.20|Action=Allow|Active=TRUE|Dir=In|Protocol=6|Profile=Domain|Profile=Private|LPort=5985|App=System|Name=@FirewallAPI.dll,-30253|Desc=@FirewallAPI.dll,-30256|EmbedCtxt=@FirewallAPI.dll,-30267|"
        $Rule2Name = "WINRM-HTTP-In-TCP"
    }
Process 
    {
        Foreach ($computer in $ComputerName)
            {
                Write-Verbose "Beginning function on $computer"
                Try
                    {
                        Write-Verbose "Attempting to create remote registry handle"
                        $Reg = New-Object -TypeName System.Management.ManagementClass -ArgumentList \\$computer\Root\default:StdRegProv
                    }
                Catch 
                    {
                        Write-Warning $_.exception.message
                        Write-Warning "The function will abort operations on $Computer"
                        $problem =$true
                    }
                if (-not($problem))
                    {
                        Try 
                            {
                                Write-Verbose "Attempting to create Remote Key"
                                if (($reg.CreateKey($HKLM, $key)).returnvalue -ne 0) {Throw "Failed to create key"}
                            }
                        Catch 
                            {
                                Write-Warning $_.exception.message
                                Write-Warning "The function will abort operations on $Computer"
                                $problem =$true
                            }
                    }
                if (-not($problem))
                    {
                        Try 
                            {
                                Write-Verbose "Attempting to set first REG_SZ Value"
                                if (($reg.SetStringValue($HKLM, $Key, $Rule1Name, $Rule1Value)).ReturnValue -ne 0) {Throw "Failed to set REG_SZ"}
                            }
                        Catch 
                            {
                                Write-Warning $_.exception.message
                                Write-Warning "The function will abort operations on $Computer"
                                $problem =$true
                            }
                    }
                if (-not($problem))
                    {
                        Try 
                            {
                                Write-Verbose "Attempting to set second REG_SZ Value"
                                if (($reg.SetStringValue($HKLM, $Key, $Rule2Name, $Rule2Value)).ReturnValue -ne 0) {Throw "Failed to set REG_SZ"}
                            }
                        Catch 
                            {
                                Write-Warning $_.exception.message
                                Write-Warning "The function will abort operations on $Computer"
                                $problem =$true
                            }
                    }
                if ($problem) {$problem = $false} 
                Else {Write-Verbose "Successfully completed operation on $computer"}
            }    
    }
}

Function Restart-WindowsFirewall
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
        [String[]]$ComputerName
    )
Begin {}
Process 
    {
         Foreach ($computer in $ComputerName)
            {
                Write-Verbose "Beginning function on $computer"
                Try
                    {
                        Write-Verbose "Attempting to stop MpsSvc"
                        (Get-WmiObject win32_service -Filter "Name='MpsSvc'" -ComputerName $computer).StopService() | Out-Null
                        Start-Sleep -Seconds 1
                        if ((Get-WmiObject win32_service -Filter "Name='MpsSvc'" -ComputerName $computer).state -notlike "Stopped") {Throw "Failed to Stop MpsSvc"}
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
                                Write-Verbose "Attempting to start MpsSvc"
                                (Get-WmiObject win32_service -Filter "Name='MpsSvc'" -ComputerName $computer).StartService() | Out-Null
                                Start-Sleep -Seconds 1
                                if ((Get-WmiObject win32_service -Filter "Name='MpsSvc'" -ComputerName $computer).state -notlike "Running") {Throw "Failed to Start MpsSvc"}
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
    }
End {}
}

Function Stop-WinRM
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
        [String[]]$ComputerName
    )
Begin {}
Process 
    {
         Foreach ($computer in $ComputerName)
            {
                Write-Verbose "Beginning function on $computer"
                Try
                    {
                        Write-Verbose "Attempting to stop WinRM"
                        (Get-WmiObject win32_service -Filter "Name='WinRM'" -ComputerName $computer).StopService() | Out-Null
                        Start-Sleep -Seconds 1
                        if ((Get-WmiObject win32_service -Filter "Name='WinRM'" -ComputerName $computer).state -notlike "Stopped") {Throw "Failed to Stop WinRM"}
                    }
                Catch 
                    {
                        Write-Warning $_.exception.message
                        Write-Warning "The function will abort operations on $Computer"
                        $problem = $true
                    }
                if ($problem) {$problem = $false} 
                Else {Write-Verbose "Successfully completed operation on $computer"}
            }    
    }
End {}
}
Function Start-WinRM
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
        [String[]]$ComputerName
    )
Begin {}
Process 
    {
         Foreach ($computer in $ComputerName)
            {
                Write-Verbose "Beginning function on $computer"
                Try 
                    {
                        Write-Verbose "Attempting to start WinRM"
                        (Get-WmiObject win32_service -Filter "Name='WinRM'" -ComputerName $computer).StartService() | Out-Null
                        Start-Sleep -Seconds 1
                        if ((Get-WmiObject win32_service -Filter "Name='WinRM'" -ComputerName $computer).state -notlike "Running") {Throw "Failed to Start WinRM"}
                    }
                Catch
                    {
                        Write-Warning $_.exception.message
                        Write-Warning "The function will abort operations on $Computer"
                        $problem = $true
                    }
                if ($problem) {$problem = $false} 
                Else {Write-Verbose "Successfully completed operation on $computer"}
            }    
    }
End {}
}