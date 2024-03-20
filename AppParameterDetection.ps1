# Name: AppParameterDetection.ps1
# Description: Script is designed to list all installed apps on system and their parameters
# Copyright (C) 2024 Action1 Corporation
# Documentation: https://github.com/Action1Corp/PSAction1/
# Use Action1 Roadmap system (https://roadmap.action1.com/) to submit feedback or enhancement requests.

# WARNING: Carefully study the provided scripts and components before using them. Test in your non-production lab first.

# LIMITATION OF LIABILITY. IN NO EVENT SHALL ACTION1 OR ITS SUPPLIERS, OR THEIR RESPECTIVE 
# OFFICERS, DIRECTORS, EMPLOYEES, OR AGENTS BE LIABLE WITH RESPECT TO THE WEBSITE OR
# THE COMPONENTS OR THE SERVICES UNDER ANY CONTRACT, NEGLIGENCE, TORT, STRICT 
# LIABILITY OR OTHER LEGAL OR EQUITABLE THEORY (I)FOR ANY AMOUNT IN THE AGGREGATE IN
# EXCESS OF THE GREATER OF FEES PAID BY YOU THEREFOR OR $100; (II) FOR ANY INDIRECT,
# INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES OF ANY KIND WHATSOEVER; (III) FOR
# DATA LOSS OR COST OF PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; OR (IV) FOR ANY
# MATTER BEYOND ACTION1’S REASONABLE CONTROL. SOME STATES DO NOT ALLOW THE
# EXCLUSION OR LIMITATION OF INCIDENTAL OR CONSEQUENTIAL DAMAGES, SO THE ABOVE
# LIMITATIONS AND EXCLUSIONS MAY NOT APPLY TO YOU.


# Define uninstallation paths for both 32-bit and 64-bit applications, and for both current user and local machine scopes.
$UninstallPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\",
    "HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"
)

# Gather application data from the uninstallation paths.
$AppsData = foreach ($Path in $UninstallPaths) {
    Get-ChildItem $Path -ErrorAction SilentlyContinue | Get-ItemProperty |
    Where-Object { $_.DisplayName -ne $null } |
    Select-Object @{Name='Display Name Match'; Expression={$_.DisplayName}},
                  @{Name='Version Number'; Expression={$_.DisplayVersion}},
                  Version, WindowsInstaller, SystemComponent, UninstallString, 
                  QuietUninstallString, Publisher, URLInfoAbout, InstallLocation, 
                  InstallSource, PSPath
}

# Present the application data to the user for selection.
$SelectedAppData = $AppsData | Sort-Object WindowsInstaller, 'Display Name Match', SystemComponent |
                   Out-GridView -Title "Select Application" -OutputMode Single

# Process the selected application.
if ($SelectedAppData) {
    $AppName = $SelectedAppData.'Display Name Match'
    $AppVersion = if ($AppName -match '(?:(\d+)\.)?(?:(\d+)\.)?(?:(\d+)\.\d+)') { $Matches[0] } else { $SelectedAppData.'Version Number' }
    
    # Determine the application architecture based on the path.
    $AppArchitecture = if ($SelectedAppData.PSPath -match "WOW6432Node") { "32-bit" } else { "64-bit" }
    
    # Determine the installation context based on the registry path.
    $InstallationContext = if ($SelectedAppData.PSPath -match "HKEY_LOCAL_MACHINE") { "System" } else { "User" }

    # Compile the application information into a custom object.
    $AppInfo = [PSCustomObject]@{
        'Display Name Match' = $AppName.Trim()
        Publisher = $SelectedAppData.Publisher
        Architecture = $AppArchitecture
        'Version Number' = $AppVersion
        InstallContext = $InstallationContext
    }

    # Output the application information.
    $AppInfo
} else {
    Write-Output "No App Selected. Exiting."
}
