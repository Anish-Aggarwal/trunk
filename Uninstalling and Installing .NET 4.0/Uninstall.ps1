$classKey="IdentifyingNumber=`"`{7DEBE4EB-6B40-3766-BB35-5CBBC385DA37`}`",Name=`"Microsoft .NET Framework 4.5.1`",version=`"4.5.50938`""

$servers=Get-Content .\ServerNames.txt

Set-Variable MyLogfile "MyLogfile.txt" -Option ReadOnly
Set-Variable MyVerfile "MyVerfile.txt" -Option ReadOnly

foreach($server in $servers)
{
Clear-Content "$MyVerfile"
ls \\$server\c$\Windows\Microsoft.NET\Framework | ? { $_.PSIsContainer } | select -exp Name -l 1  >>$MyVerfile

$CurrentVersion = Get-Content "$MyVerfile"

write-host "Current installed version is $CurrentVersion"

if ($CurrentVersion -eq "v4.0.30319")
	{
		write-host "The server $server has .Net Framework Version 4.0"
		write-output "The server $server has .Net Framework Version 4.0" >>$MyLogfile
		break;
	}
	
elseif ($CurrentVersion -eq "4.5.50938")
	{
		write-host "The server $server has .Net Framework 4.5"
		write-output "The server $server has .Net Framework Version 4.5" >>$MyLogfile
		(get-service -ComputerName $server -Name "Windows Update").Stop() >>$MyLogfile
		([wmi]"\\$server\root\cimv2:Win32_Product.$classKey").uninstall() >>$MyLogfile
		Copy-Item -Path \\delvmpwlcmrs08\e$\Software\dotNetFx40_Full_setup.exe -Destination \\$server\e$\CMRS_Automation -Recurse >>$MyLogfile

		invoke-command -computername $server -scriptblock {start-process "E:\CMRS_Automation\dotNetFx40_Full_setup.exe" -argumentlist "/s"} >>$MyLogfile
		break;
	}

else 
	{
		write-host "The .Net Framework Version currently present in the server $server is $CurrentVersion and it is not as per the guidelines for CMRS"
		write-output "The .Net Framework Version currently present in the server $server is $CurrentVersion and it is not as per the guidelines for CMRS" >>$MyLogfile
	}
	
}