﻿# Name: AutoUpdateStatus.ps1
# Description: Script is designed to set custom attribute to show if Windows Autoupdate registry key is set.  

# Documentation: https://github.com/Action1Corp/PSAction1/
# Use Action1 Roadmap system (https://roadmap.action1.com/) to submit feedback or enhancement requests.

# WARNING: Carefully study the provided scripts and components before using them. Test in your non-production lab first.

# Action1 Public Repository Material
# Subject to TERMS_OF_USE.md (https://github.com/Action1Corp/PSAction1/blob/main/TERMS_OF_USE.md)
# Provided AS IS
# Use at your own risk
# Review and test before production deployment
# © Action1 Corporation

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
$registryKey = "NoAutoUpdate"

try{
    $NoAutoUpdateValue = Get-ItemProperty -Path $registryPath -Name $registryKey -ErrorAction Stop
    $Status = $NoAutoUpdateValue.$registryKey
    $OutputText = $(if($status-ne 0){'True'}else{'False'})
}
catch{
    $OutputText = "Error: $_"
}

Action1-Set-CustomAttribute 'Automatic Windows Updates Disabled' $OutputText


