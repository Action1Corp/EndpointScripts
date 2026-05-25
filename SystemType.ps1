﻿# Name: SystemType.ps1
# Description: Script is designed to set custom attribute to show the form factor of an endpoint and if it is virtual.  

# Documentation: https://github.com/Action1Corp/PSAction1/
# Use Action1 Roadmap system (https://roadmap.action1.com/) to submit feedback or enhancement requests.

# WARNING: Carefully study the provided scripts and components before using them. Test in your non-production lab first.

# Action1 Public Repository Material
# Subject to TERMS_OF_USE.md (https://github.com/Action1Corp/PSAction1/blob/main/TERMS_OF_USE.md)
# Provided AS IS
# Use at your own risk
# Review and test before production deployment
# © Action1 Corporation

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