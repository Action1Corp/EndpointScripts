# Name: CustomAttribute-SoftwareInstallStatus.ps1
# Description: Script is designed to set custom attribute to show if software is installed or not installed.  

# Documentation: https://www.action1.com/documentation/custom-attributes/
# Use Action1 Roadmap system (https://roadmap.action1.com/) to submit feedback or enhancement requests.

# WARNING: Carefully study the provided scripts and components before using them. Test in your non-production lab first.

# Action1 Public Repository Material
# Subject to TERMS_OF_USE.md (https://github.com/Action1Corp/PSAction1/blob/main/TERMS_OF_USE.md)
# Provided AS IS
# Use at your own risk
# Review and test before production deployment
# © Action1 Corporation

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
