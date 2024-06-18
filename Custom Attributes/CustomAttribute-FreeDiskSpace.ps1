# Name: CustomAttributeFreeDiskSpace.ps1
# Description: Script is designed to set custom attribute to show how much free disk space there is.  
# Copyright (C) 2024 Action1 Corporation
# Documentation: https://www.action1.com/documentation/custom-attributes/
# Use Action1 Roadmap system (https://roadmap.action1.com/) to submit feedback or enhancement requests.

# WARNING: Carefully study the provided scripts and components before using them. Test in your non-production lab first.

# LIMITATION OF LIABILITY. IN NO EVENT SHALL ACTION1 OR ITS SUPPLIERS, OR THEIR RESPECTIVE 
# OFFICERS, DIRECTORS, EMPLOYEES, OR AGENTS BE LIABLE WITH RESPECT TO THE WEBSITE OR
# THE COMPONENTS OR THE SERVICES UNDER ANY CONTRACT, NEGLIGENCE, TORT, STRICT 
# LIABILITY OR OTHER LEGAL OR EQUITABLE THEORY (I)FOR ANY AMOUNT IN THE AGGREGATE IN
# EXCESS OF THE GREATER OF FEES PAID BY YOU THEREFOR OR $100; (II) FOR ANY INDIRECT,
# INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES OF ANY KIND WHATSOEVER; (III) FOR
# DATA LOSS OR COST OF PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; OR (IV) FOR ANY
# MATTER BEYOND ACTION1 S REASONABLE CONTROL. SOME STATES DO NOT ALLOW THE
# EXCLUSION OR LIMITATION OF INCIDENTAL OR CONSEQUENTIAL DAMAGES, SO THE ABOVE
# LIMITATIONS AND EXCLUSIONS MAY NOT APPLY TO YOU.

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
