Param($ServerName)
set-psdebug -strict
$ErrorActionPreference = "stop" # you can opt to stagger on, bleeding, if an error occurs

$Listofqueues= Get-Content -Path ".\Queuenames.txt"


foreach($queuename in $Listofqueues)
{
    .\CreateQueueu.ps1 -c $queuename Y "sapient\aagg21" all
}