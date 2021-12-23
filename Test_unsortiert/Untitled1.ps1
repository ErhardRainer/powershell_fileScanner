$computer = ($env:computername)
Get-PhysicalDisk | Sort Size | FT deviceid ,FriendlyName, Size, MediaType, SpindleSpeed, HealthStatus, OperationalStatus -AutoSize
Get-PhysicalDisk