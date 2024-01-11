# Name: FixWinREKB5034441.ps1
# Description: Script designed to fix WinRe error for KB5034441
# Copyright (C) 2024 Action1 Corporation
# Documentation: https://github.com/Action1Corp/PSAction1/
# Use Action1 Roadmap system (https://roadmap.action1.com/) to submit feedback or enhancement requests.

# WARNING: Carefully study the provided scripts and components before using them. Test in your non-production lab first.

# LIMITATION OF LIABILITY. IN NO EVENT SHALL ACTION1 OR ITS SUPPLIERS, OR THEIR RESPECTIVE 
# OFFICERS, DIRECTORS, EMPLOYEES, OR AGENTS BE LIABLE WITH RESPECT TO THE WEBSITE OR
# THE COMPONENTS OR THE SERVICES UNDER ANY CONTRACT, NEGLIGENCE, TORT, STRICT 
# LIABILITY OR OTHER LEGAL OR EQUITABLE THEORY (I)FOR ANY AMOUNT IN THE AGGREGATE IN
# EXCESS OF THE GREATER OF FEES PAID BY YOU THEREFOR OR $100; (II) FOR ANY INDIRECT,
# INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES OF ANY KIND WHATSOEVER; (III) FOR
# DATA LOSS OR COST OF PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; OR (IV) FOR ANY
# MATTER BEYOND ACTION1’S REASONABLE CONTROL. SOME STATES DO NOT ALLOW THE
# EXCLUSION OR LIMITATION OF INCIDENTAL OR CONSEQUENTIAL DAMAGES, SO THE ABOVE
# LIMITATIONS AND EXCLUSIONS MAY NOT APPLY TO YOU.


#Gather data on if this can be done.
[string]$nfo = reagentc /info
if($nfo -match ".*Windows RE status:.*Enabled.*"){ #Verify if WINRE is enabled, if so proceed.
$nfo -match ".*Windows RE location.*harddisk(\d+)" | Out-Null #Locate the disk number it is on.
$disk = $Matches[1]
$nfo -match ".*Windows RE location.*partition(\d+)" | Out-Null #Locate the partition it is on.
$partition = $Matches[1]
$disk_type = $(Get-Disk | Select-Object Number, PartitionStyle | ?{$_.Number -eq 0}).PartitionStyle #Determine disk partition style.
#Start building the script to pass to diskpart.
$Diskpart_Script =  "sel disk $disk`n" #Target disk with recovery partition.
$Diskpart_Script += "sel partition $($partition - 1)`n" #Target partition left adjacent to recovery partition.
$Diskpart_Script += "shrink desired=250 minimum=250`n" #Shrink by 250m.
$Diskpart_Script += "sel partition $partition`n" #Target recovery partition.
$Diskpart_Script += "delete partition override`n" #Remove it.
if ($disk_type = 'GPT'){ #Recreate partition based on partiton table layout.
$Diskpart_Script += "create partition primary id=de94bba4-06d1-4d40-a16a-bfd50179d6ac`n"
$Diskpart_Script += "gpt attributes=0x8000000000000001`n"
}else{
$Diskpart_Script += "create partition primary id=27`n"
}
$Diskpart_Script += "format fs=ntfs label=`"Windows RE tools`" quick`n" #Format the newly created partition.
$Diskpart_Script | Out-File .\DiskScript.txt -Encoding ascii #Write the script.
#Do it!
reagentc /disable
diskpart /s .\DiskScript.txt
reagentc /enable
Remove-Item .\DiskScript.txt
}