<#	
	.NOTES
	===========================================================================
	 Created on:   	2022-04-09
	 Created by:   	Erhard Rainer
	 Filename:     	join-mp3.ps1
	===========================================================================
	.DESCRIPTION
#>
<# Configuration #>
$output = "C:\_Skripte\currentfiles.csv"
$outputdrive = "C:\_Skripte\currentDrives.csv"
<# Script #>
$startime = (get-Date)
$drives = (Get-Volume | Select-Object -Property DriveLetter, Size, SizeRemaining )
$drives | Export-Csv $outputdrive -NoTypeInformation
Remove-Item -Path $output
foreach ($drive in $drives)
{
    if ($drive.DriveLetter -ne $null)
    {
        $driveLetter = $drive.DriveLetter
        $startdir = $driveLetter + ':\'
        Write-Host $startdir -BackgroundColor Yellow
        $files = (Get-ChildItem -Path $startdir -Recurse -ErrorAction SilentlyContinue)
        $files | Select-Object -Property Name, Extension, FullName, Length , Directory, *time | Export-Csv $output -NoTypeInformation -Append
    }
}
$endtime = (get-Date)
Write-Host $startime
Write-Host $endtime
$duration = (New-TimeSpan -Start $startime -End $endtime).Minutes
Wirte-Host 'The Scan took: $duration'