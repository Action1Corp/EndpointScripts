# Name: CustomAttribute-WSUSEnabledorDisabled.ps1
# Description: Script is designed to set custom attribute to detect if WSUS is enabled on Endpoint.  

# Documentation: https://www.action1.com/documentation/custom-attributes/
# Use Action1 Roadmap system (https://roadmap.action1.com/) to submit feedback or enhancement requests.

# WARNING: Carefully study the provided scripts and components before using them. Test in your non-production lab first.

# Action1 Public Repository Material
# Subject to TERMS_OF_USE.md (https://github.com/Action1Corp/PSAction1/blob/main/TERMS_OF_USE.md)
# Provided AS IS
# Use at your own risk
# Review and test before production deployment
# © Action1 Corporation

# Define the registry path
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

# Check if the registry path exists
if (Test-Path $registryPath) {
    # Get the value of UseWUServer, if it exists
    $UseWUServerValue = Get-ItemProperty -Path $registryPath -Name "UseWUServer" -ErrorAction SilentlyContinue
    $WUServerValue = Get-ItemProperty -Path $registryPath -Name "WUServer" -ErrorAction SilentlyContinue
    
    if ($UseWUServerValue -and $WUServerValue) {
        $Status = "UseWUServer Value: " + $UseWUServerValue.UseWUServer + "; WUServer Value: " + $WUServerValue.WUServer
    } elseif ($UseWUServerValue) {
        $Status = "UseWUServer Value: " + $UseWUServerValue.UseWUServer + "; WUServer Key does not exist"
    } elseif ($WUServerValue) {
        $Status = "UseWUServer Key does not exist; WUServer Value: " + $WUServerValue.WUServer
    } else {
        $Status = "No WSUS configuration found"
    }
} else {
    $Status = "Registry path does not exist"
}

# Output the status of WSUS configuration
$OutputText = "WSUS Configuration Status: $Status"

Action1-Set-CustomAttribute 'WSUS Configuration Status' $OutputText;
