
$src = "D:\PortRecon\trunk\TestData\DTCCUS\XCCY_FixFloat\DP Output\IRSCML_*.csv"
$dstDir = "D:\PortRecon\trunk\TestData\DTCCUS\XCCY_FixFloat\DP Output\"

# Delete previous output files
#Remove-Item -Path "$dstDir\\*"

# Read input and create subordinate files based on column 8 content
$header = Get-Content -Path $src | select -First 1

Get-Content -Path $src | select -Skip 1 | foreach {
    $file = "$(($_ -split ",")[940]).csv"
    if($file -notlike "")
    {
    Write-Verbose "Wrting to $file"
    if (-not (Test-Path -Path $dstDir\$file))
    {
        Out-File -FilePath $dstDir\$file -InputObject $header -Encoding ascii
    }
    Out-File -FilePath $dstDir\$file -InputObject $_ -Encoding ascii -Append
    }
}