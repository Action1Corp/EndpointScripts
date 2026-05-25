# Name: CustomAttribute-PowerSettings.ps1
# Description: Script is designed to set custom attribute to what power setting is in place.  

# Documentation: https://www.action1.com/documentation/custom-attributes/
# Use Action1 Roadmap system (https://roadmap.action1.com/) to submit feedback or enhancement requests.

# WARNING: Carefully study the provided scripts and components before using them. Test in your non-production lab first.

# Action1 Public Repository Material
# Subject to TERMS_OF_USE.md (https://github.com/Action1Corp/PSAction1/blob/main/TERMS_OF_USE.md)
# Provided AS IS
# Use at your own risk
# Review and test before production deployment
# © Action1 Corporation

# Retrieve the current power plan
$PowerPlanOutput = powercfg /getactivescheme

# Extract the power plan GUID and name
if ($PowerPlanOutput -match "Power Scheme GUID: ([\w-]+)  \((.+)\)") {
    $PowerPlanGuid = $matches[1]
    $PowerPlanName = $matches[2]
    $PowerPlanText = "$PowerPlanName ($PowerPlanGuid)"
} else {
    $PowerPlanText = 'unknown'
}

# Set the custom attribute with the power plan information
Action1-Set-CustomAttribute 'Power Plan' $PowerPlanText
