﻿# Name: RDPEnabled.ps1
# Description: Script is designed to set custom attribute to show if RDP is enabled on the endpoint.  

# Documentation: https://github.com/Action1Corp/PSAction1/
# Use Action1 Roadmap system (https://roadmap.action1.com/) to submit feedback or enhancement requests.

# WARNING: Carefully study the provided scripts and components before using them. Test in your non-production lab first.

# Action1 Public Repository Material
# Subject to TERMS_OF_USE.md (https://github.com/Action1Corp/PSAction1/blob/main/TERMS_OF_USE.md)
# Provided AS IS
# Use at your own risk
# Review and test before production deployment
# © Action1 Corporation

$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server"
$registryKey = "fDenyTSConnections"

try{
    $RdpEnabled = Get-ItemProperty -Path $registryPath -Name $registryKey -ErrorAction Stop
    $Status = $RdpEnabled.$registryKey
    $OutputText = $(if($status-eq 0){'True'}else{'False'})
}
catch{
    $OutputText = "Error: $_"
}

$OutputText

Action1-Set-CustomAttribute 'RDP Enabled' $OutputText