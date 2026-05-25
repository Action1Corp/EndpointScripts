# Name: CustomAttribute-RegistryEntryFound.ps1
# Description: Script is designed to set custom attribute to show if registry entry is found or not.  

# Documentation: https://www.action1.com/documentation/custom-attributes/
# Use Action1 Roadmap system (https://roadmap.action1.com/) to submit feedback or enhancement requests.

# WARNING: Carefully study the provided scripts and components before using them. Test in your non-production lab first.

# Action1 Public Repository Material
# Subject to TERMS_OF_USE.md (https://github.com/Action1Corp/PSAction1/blob/main/TERMS_OF_USE.md)
# Provided AS IS
# Use at your own risk
# Review and test before production deployment
# © Action1 Corporation

# Define the registry path and value to check
$RegistryPath = "HKLM:\SOFTWARE\Example"
$RegistryValueName = "ExampleValue"

# Check if the registry value exists
$RegistryValue = Get-ItemProperty -Path $RegistryPath -Name $RegistryValueName -ErrorAction SilentlyContinue
$RegistryStatusText = if ($RegistryValue) { 'Found' } else { 'Not Found' }

# Set a custom attribute with the registry status
Action1-Set-CustomAttribute 'Registry Status' $RegistryStatusText;
