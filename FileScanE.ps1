<#	
	.NOTES
	===========================================================================
	 Created on:   	2017-03-15
	 Created by:   	Erhard Rainer
	 Filename:     	FileScan.ps1
	===========================================================================
	.DESCRIPTION
		Diese Datei wird am jeweiligen Rechner ausgeführt, und überträgt die 
        Dateien an den SQL-Server
#>

 Param(
                [Parameter(Mandatory=$False,Position=1)]
                [string]$currentDrive
                )


# globale Variablen 
if (($currentDrive).Length -eq 0)
{
    $currentDrive = ((get-location).Drive.Name)
}


# [0] Vorbereitung
$startdir = $currentDrive + ":\"
Write-Host "Analyse folder: $startdir"

#Get Drive Information
#$driveInfo = (Get-PSDrive $currentDrive)
$driveInfo2 = (Get-Volume -DriveLetter $currentDrive)

$drivename = $driveInfo2.FileSystemLabel
if ($drivename.length -eq 0)
{
    $drivename = Read-Host 'Enter a Name fro this Drive:'
    $driveletter = $currentDrive + ":"
    $drive = Get-WmiObject "Win32_LogicalDisk WHERE DeviceID='$driveletter'"
    $drive.VolumeName = $drivename
    $null = $drive.Put()
}


# [1] Einlesen des Dateisystems
#Files einlesen
$startime = (get-Date)
$files = Get-ChildItem -Path $startdir -Recurse -ErrorAction SilentlyContinue
$endtime = (get-Date)

#DataTable erstellen
$dttable = New-Object system.Data.DataTable 'Content'
$newcol = New-Object system.Data.DataColumn FullName,([string]); $dttable.columns.add($newcol)
$newcol = New-Object system.Data.DataColumn Name,([string]); $dttable.columns.add($newcol)
$newcol = New-Object system.Data.DataColumn Directory,([string]); $dttable.columns.add($newcol)
$newcol = New-Object system.Data.DataColumn Extension,([string]); $dttable.columns.add($newcol)
$newcol = New-Object system.Data.DataColumn CreationDate,([DateTime]); $dttable.columns.add($newcol)
$newcol = New-Object system.Data.DataColumn Size,([Int64]); $dttable.columns.add($newcol)


##$files | ft fullname, name, length
##$files | ft fullname, name, Directory, Extension, CreationTime, length
$filesCount = $files.Count
$remaining = $filesCount
Write-Host "Files-Count: $filesCount"
if ($filesCount -gt 100000)
{
    $filesCount = 100000
}
Write-Host "Batch-Size: $filesCount"

Write-host "Send Files"
$counter = 1
foreach ($file in $files)
{
        $Row = $dttable.NewRow()
        $row.FullName=  $file.FullName
        $row.Name=  $file.Name
        $row.Directory=  $file.Directory
        $row.Extension=  $file.Extension
        $row.CreationDate=  $file.CreationTime
        $row.Size=  $file.length
        $dttable.Rows.Add($row)
        $counter = $counter + 1
        #Write-Host $counter
    if ($counter -eq $filesCount)
    {
        Write-host "Send Batch $filesCount"
        $remaining = ($remaining - $filesCount)
        Write-Host "Remaining: $remaining"
        if ($remaining -lt $filesCount)
        {
            $filesCount = $remaining
        }
        #SQL parameters
        [string] $SQLServer= "SQLServer"
        [string] $SQLDatabase = "externalMedia"
        [string] $SQLStoredProcName = "[dbo].[usp_InsertExternalMedia]"
        $Connection = New-Object System.Data.SQLClient.SQLConnection
        $Connection.ConnectionString = "Server = $SQLServer;Database = $SQLDatabase;Integrated Security=true;"
        $Connection.Open()

        #Command section
        $Command = New-Object System.Data.SQLClient.SQLCommand
        $Command.CommandType = [System.Data.CommandType]::StoredProcedure
        $Command.CommandText = $SQLStoredProcName
        $Command.Connection = $Connection
 
        #Parameter section
        [string] $driveName = $driveInfo2.FileSystemLabel
        [string] $FileSystemType = ($driveInfo2).FileSystemType
        [string] $Size = ($driveInfo2).Size
        [string] $SizeRemaining = ($driveInfo2).SizeRemaining
        $Command.Parameters.AddWithValue("@driveName", $driveName) | Out-Null
        $Command.Parameters.AddWithValue("@FileSystemType", $FileSystemType) | Out-Null
        $Command.Parameters.AddWithValue("@Size", $Size) | Out-Null
        $Command.Parameters.AddWithValue("@SizeRemaining", $SizeRemaining) | Out-Null
        $Command.Parameters.AddWithValue("@ScanStart", $startime) | Out-Null
        $Command.Parameters.AddWithValue("@ScanEnd", $endtime) | Out-Null


        $parameter = New-Object('system.data.sqlclient.sqlparameter')
        $parameter.ParameterName = "dt"
        $parameter.SqlDBtype = [System.Data.SqlDbType]::Structured
        $parameter.Direction = [System.Data.ParameterDirection]::Input
        $parameter.value = $dttable
        $Command.parameters.add($parameter);
 
        #Open the connection, execute the query and close it afterwards
        try
                {
                    $Command.ExecuteNonQuery() | Out-Null
                }
                catch [Exception]
                {
                    Write-Warning $_.Exception.Message
                }
                finally
                {
                    $Connection.Dispose()
                    $Connection.Close()
                    $Command.Dispose()
                }

        $dttable.Clear()
        $counter = 1
        }
}
#$dttable


#Remove-Variable -name table


