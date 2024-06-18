# Name: CustomAttributeWSUSEnabledorDisabled.ps1
# Description: Script is designed to set custom attribute to detect if WSUS is enabled on Endpoint.  
# Copyright (C) 2024 Action1 Corporation
# Documentation: https://www.action1.com/documentation/custom-attributes/
# Use Action1 Roadmap system (https://roadmap.action1.com/) to submit feedback or enhancement requests.

# WARNING: Carefully study the provided scripts and components before using them. Test in your non-production lab first.

# LIMITATION OF LIABILITY. IN NO EVENT SHALL ACTION1 OR ITS SUPPLIERS, OR THEIR RESPECTIVE 
# OFFICERS, DIRECTORS, EMPLOYEES, OR AGENTS BE LIABLE WITH RESPECT TO THE WEBSITE OR
# THE COMPONENTS OR THE SERVICES UNDER ANY CONTRACT, NEGLIGENCE, TORT, STRICT 
# LIABILITY OR OTHER LEGAL OR EQUITABLE THEORY (I)FOR ANY AMOUNT IN THE AGGREGATE IN
# EXCESS OF THE GREATER OF FEES PAID BY YOU THEREFOR OR $100; (II) FOR ANY INDIRECT,
# INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES OF ANY KIND WHATSOEVER; (III) FOR
# DATA LOSS OR COST OF PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; OR (IV) FOR ANY
# MATTER BEYOND ACTION1 S REASONABLE CONTROL. SOME STATES DO NOT ALLOW THE
# EXCLUSION OR LIMITATION OF INCIDENTAL OR CONSEQUENTIAL DAMAGES, SO THE ABOVE
# LIMITATIONS AND EXCLUSIONS MAY NOT APPLY TO YOU.

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
