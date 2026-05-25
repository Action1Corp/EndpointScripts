# Name: CustomAttribute-Timezone.ps1
# Description: Script is designed to set custom attribute to show the timezone of the endpoint.  

# Documentation: https://www.action1.com/documentation/custom-attributes/
# Use Action1 Roadmap system (https://roadmap.action1.com/) to submit feedback or enhancement requests.

# WARNING: Carefully study the provided scripts and components before using them. Test in your non-production lab first.

# Action1 Public Repository Material
# Subject to TERMS_OF_USE.md (https://github.com/Action1Corp/PSAction1/blob/main/TERMS_OF_USE.md)
# Provided AS IS
# Use at your own risk
# Review and test before production deployment
# © Action1 Corporation

# Retrieve the current timezone information
$TimeZoneInfo = Get-TimeZone

# Convert the timezone information to a string
$TimeZoneText = if ($TimeZoneInfo) { $TimeZoneInfo.Id } else { 'unknown' }

# Set the custom attribute with the timezone information
Action1-Set-CustomAttribute 'Timezone' $TimeZoneText
