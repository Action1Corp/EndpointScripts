# Name: DetectCustomAppParameters.ps1
# Description: Use this script to assist in creation of your custom software repository packages in Action1.
# Copyright (C) 2024 Action1 Corporation
# Documentation: https://www.action1.com/documentation/add-custom-packages-to-app-store/

# Use Action1 Roadmap system (https://roadmap.action1.com/) to submit feedback or enhancement requests.

# WARNING: Carefully study the provided scripts and components before using them. Test in your non-production lab first.

# LIMITATION OF LIABILITY. IN NO EVENT SHALL ACTION1 OR ITS SUPPLIERS, OR THEIR RESPECTIVE
# OFFICERS, DIRECTORS, EMPLOYEES, OR AGENTS BE LIABLE WITH RESPECT TO THE WEBSITE OR
# THE COMPONENTS OR THE SERVICES UNDER ANY CONTRACT, NEGLIGENCE, TORT, STRICT
# LIABILITY OR OTHER LEGAL OR EQUITABLE THEORY (I)FOR ANY AMOUNT IN THE AGGREGATE IN
# EXCESS OF THE GREATER OF FEES PAID BY YOU THEREFOR OR $100; (II) FOR ANY INDIRECT,
# INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES OF ANY KIND WHATSOEVER; (III) FOR
# DATA LOSS OR COST OF PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; OR (IV) FOR ANY
# MATTER BEYOND ACTION1'S REASONABLE CONTROL. SOME STATES DO NOT ALLOW THE
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
    Where-Object { ($_.DisplayName -ne $null) -and ($_.SystemComponent -ne 1) } |
    Select-Object @{Name='Display Name'; Expression={$_.DisplayName}},
                  @{Name='Version Number'; Expression={$_.DisplayVersion}},
                  @{Name='Vendor'; Expression={$_.Publisher}},
                  @{Name='MachineWide'; Expression={$_.PSPath -match "HKEY_LOCAL_MACHINE"}},
                  PSPath
}

# Present the application data to the user for selection.
$SelectedAppData = $AppsData | Sort-Object MachineWide, 'Display Name' |
    Out-GridView -Title "Select Application" -OutputMode Single

# Process the selected application.
if ($SelectedAppData) {
    if (-not $SelectedAppData.MachineWide) {
        Write-Error "Action1 does not support per-user app deployment for security and lack of manageability reasons. Please select an application installed machine-wide."
        exit 1
    }

    $AppName = $SelectedAppData.'Display Name'
    $AppVersion = if ($AppName -match '(?:(\d+)\.)?(?:(\d+)\.)?(?:(\d+)\.\d+)') { $Matches[0] } else { $SelectedAppData.'Version Number' }

    # Determine the application architecture based on the path.
    $AppArchitecture = if ($SelectedAppData.PSPath -match "WOW6432Node") { "32-bit" } else { "64-bit" }

    # Compile the application information into a custom object.
    $AppInfo = [PSCustomObject]@{
        'Display Name' = $AppName.Trim()
        Vendor = $SelectedAppData.Vendor
        Architecture = $AppArchitecture
        'Version Number' = $AppVersion
    }

    # Output the application information.
    $AppInfo
} else {
    Write-Output "No App Selected. Exiting."
}
