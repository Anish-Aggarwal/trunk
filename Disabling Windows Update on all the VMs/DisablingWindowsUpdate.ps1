$servers=Get-Content .\ServerNames.txt


foreach($server in $servers)

{
	Write-host Stopping Windows Update on $server 
	(get-service -ComputerName $server -Name "Windows Update").Stop()
}