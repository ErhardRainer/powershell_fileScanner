$currentDrive = 'E' #((get-location).Drive.Name)
$startdir = $currentDrive + ":\"
Write-Host "Analyse folder: $startdir"

#Files einlesen
$startime = (get-Date)
$files = Get-ChildItem -Path $startdir -Recurse -ErrorAction SilentlyContinue
$endtime = (get-Date)

Write-Host $startime
Write-Host $endtime
Write-Host ($files).Count()
