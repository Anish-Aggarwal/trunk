Function XMLReader
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
        # Enter a ComputerName or IP Address
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        Mandatory=$True,
        HelpMessage="Enter the Database Name")] 
        [String[]]$DatabaseName
        )
Begin {}
Process 
{
    $xml = [xml](Get-Content ".\Test1.xml")
    $nodes = $xml.SelectNodes("/ScriptsInfo/DatabaseName[@Value ='$DatabaseName']/Table")
    foreach($node in $nodes.Value)
    {
        Write-Output $node
    }
}
end{}
}

XMLReader -ServerName dluaagg2185993 -DatabaseName CMRS_MASTER