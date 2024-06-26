﻿# Name: SystemType.ps1
# Description: Script is designed to set custom attribute to show the form factor of an endpoint and if it is virtual.  
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

# Query for chassis type
$ChassisType = (Get-WmiObject Win32_SystemEnclosure).ChassisTypes
# Convert chassis type codes to readable format
$ChassisTypeText = switch ($ChassisType) {
    1 { "Other" }; 2 { "Unknown" }; 3 { "Desktop" }; 4 { "Low Profile Desktop" }
    5 { "Pizza Box" }; 6 { "Mini Tower" }; 7 { "Tower" }; 8 { "Portable" }
    9 { "Laptop" }; 10 { "Notebook" }; 11 { "Hand Held" }; 12 { "Docking Station" }
    13 { "All in One" }; 14 { "Sub Notebook" }; 15 { "Space-Saving" }; 16 { "Lunch Box" }
    17 { "Main System Chassis" }; 18 { "Expansion Chassis" }; 19 { "SubChassis" }
    20 { "Bus Expansion Chassis" }; 21 { "Peripheral Chassis" }; 22 { "Storage Chassis" }
    23 { "Rack Mount Chassis" }; 24 { "Sealed-Case PC" }
    default { "Custom/Other" }
}

# Check if the platform is physical or virtual.
$SysInfo = Get-ComputerInfo -Property CsManufacturer, CsModel
if ($SysInfo.CsManufacturer -match "Microsoft|VMware|Xen|QEMU|innotek|Parallels|Google" -or
    $SysInfo.CsModel -match "Virtual*|VMware*|KVM|Bochs|HVM*|Para*|bhyve") {
    $PlatformType = "Virtual"
} else {
    $PlatformType = "Physical"
}

# Output chassis type and VM platform.
$OutputText = "Chassis Type: $ChassisTypeText; Platform Type: $PlatformType"

Action1-Set-CustomAttribute 'System Type' $OutputText;