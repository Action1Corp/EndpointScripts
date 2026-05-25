# Name: CustomAttribute-AutoUpdateStatus.ps1
# Description: Script is designed to set custom attribute detect Auto Update Key.  

# Documentation: https://www.action1.com/documentation/custom-attributes/
# Use Action1 Roadmap system (https://roadmap.action1.com/) to submit feedback or enhancement requests.

# WARNING: Carefully study the provided scripts and components before using them. Test in your non-production lab first.

# Action1 Public Repository Material
# Subject to TERMS_OF_USE.md (https://github.com/Action1Corp/PSAction1/blob/main/TERMS_OF_USE.md)
# Provided AS IS
# Use at your own risk
# Review and test before production deployment
# © Action1 Corporation

# Define the registry path and key
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
$registryKey = "NoAutoUpdate"

# Check if the registry path exists
if (Test-Path $registryPath) {
    # Get the value of NoAutoUpdate, if it exists
    $NoAutoUpdateValue = Get-ItemProperty -Path $registryPath -Name $registryKey -ErrorAction SilentlyContinue
    if ($NoAutoUpdateValue) {
        $Status = "NoAutoUpdate Value: " + $NoAutoUpdateValue.$registryKey
    } else {
        $Status = "NoAutoUpdate Key does not exist"
    }
} else {
    $Status = "Registry path does not exist"
}

# Output the status of Automatic Windows Updates
$OutputText = "Automatic Windows Updates Disabled: $Status"

Action1-Set-CustomAttribute 'Automatic Windows Updates Disabled' $OutputText;
