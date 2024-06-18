# Name: CustomAttributeSoftwareInstallStatus.ps1
# Description: Script is designed to set custom attribute to show if software is installed or not installed.  
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


# Insert software to check for here
$SoftwareName = "Google Chrome" #change to desired software

Function Test-SoftInstalled {
    Param ([string]$Name)
    $RegKeys = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*", 
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    $KeyExists = $false
    ForEach ($RegKey in $RegKeys) {
        $DisplayName = Get-ItemProperty -Path $RegKey -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "$($Name)*" }
        if ($null -ne $DisplayName) {
            $KeyExists = $true
            break
        }
    }

    Return $KeyExists
}

$SoftwareStatus = Test-SoftInstalled -Name $SoftwareName
$SoftwareStatusText = if ($SoftwareStatus) { 'Installed' } else { 'Not Installed' }

# Please set the "$SoftwareName Status" as your custom attribute in Action1

Action1-Set-CustomAttribute "$SoftwareName Status" $SoftwareStatusText;
