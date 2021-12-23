# A simple PowerShell script for retrieving the RAID status of volumes with help of diskpart.
# The nicer solution would be using WMI (which does not contain the RAID status in the Status field of Win32_DiskDrive, Win32_LogicalDisk or Win32_Volume for unknown reason)
# or using the new PowerShell API introduced with Windows 8 (wrong target system as our customer uses a Windows 7 architecture).
# 
# diskpart requires administrative privileges so this script must be executed under an administrative account if it is executed standalone.
# check_mk has this privileges and therefore this script must only be copied to your check_mk/plugins directory and you are done.
#
# Christopher Klein <ckl[at]neos-it[dot]de>
# This script is distributed under the GPL v2 license.

$dp = "list volume" | diskpart | ? { $_ -match "^  [^-]" }

echo `<`<`<local`>`>`>
foreach ($row in $dp) {
	# skip first line
	if (!$row.Contains("Volume ###")) {
		# best match RegExp from http://www.eventlogblog.com/blog/2012/02/how-to-make-the-windows-softwa.html
		if ($row -match "\s\s(Volume\s\d)\s+([A-Z])\s+(.*)\s\s(NTFS|FAT)\s+(Mirror|RAID-5|Stripe|Spiegel|Spiegelung|Übergreifend|Spanned)\s+(\d+)\s+(..)\s\s([A-Za-z]*\s?[A-Za-z]*)(\s\s)*.*")  {
			$disk = $matches[2] 
			# 0 = OK, 1 = WARNING, 2 = CRITICAL
			$statusCode = 1
			$status = "WARNING"
			$text = "Could not parse line: $row"
			$line = $row
			
			if ($line -match "Fehlerfre |OK|Healthy") {
				$statusText = "is healthy"
				$statusCode = 0
				$status = "OK"
			}
			elseif ($line -match "Rebuild") {
				$statusText = "is rebuilding"
				$statusCode = 1
			}
			elseif ($line -match "Failed|At Risk|Fehlerhaf") {
				$statusText = "failed"
				$statusCode = 2
				$status = "CRITICAL"
			}
		
			echo "$statusCode microsoft_software_raid - $status - Software RAID on disk ${disk}:\ $statusText"
		}
	}
}