﻿Get-NaDisk | select raidgroup,aggregate,name,shelf,bay,status,physicalspace,RPM,FW,model,pool | ?{$_.raidgroup -match "rg0"} | select name | Measure-Object