# Name: CustomAttribute-FreeDiskSpace.ps1
# Description: Script is designed to set custom attribute to show how much free disk space there is.  

# Documentation: https://www.action1.com/documentation/custom-attributes/
# Use Action1 Roadmap system (https://roadmap.action1.com/) to submit feedback or enhancement requests.

# WARNING: Carefully study the provided scripts and components before using them. Test in your non-production lab first.

# Action1 Public Repository Material
# Subject to TERMS_OF_USE.md (https://github.com/Action1Corp/PSAction1/blob/main/TERMS_OF_USE.md)
# Provided AS IS
# Use at your own risk
# Review and test before production deployment
# © Action1 Corporation

# Query all disk drives for free space
$DiskDrives = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }

# Create a readable output of disk drives and their free space
$DiskStatusText = $DiskDrives | ForEach-Object {
    $FreeSpaceGB = [math]::Round($_.FreeSpace / 1GB, 2) # Convert free space to gigabytes and round to two decimals
    "$($_.DeviceID) - Free Space: $FreeSpaceGB GB"
}

# Output all disk drives and their free space
$OutputText = $DiskStatusText -join '; '

Action1-Set-CustomAttribute 'Disk Free Space' $OutputText;
