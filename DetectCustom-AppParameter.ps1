# Name: DetectCustom-AppParameter.ps1
# Description: Use this script to assist in creation of your custom software repository packages in Action1.

# Documentation: https://www.action1.com/documentation/add-custom-packages-to-app-store/

# Use Action1 Roadmap system (https://roadmap.action1.com/) to submit feedback or enhancement requests.

# WARNING: Carefully study the provided scripts and components before using them. Test in your non-production lab first.

# Action1 Public Repository Material
# Subject to TERMS_OF_USE.md (https://github.com/Action1Corp/PSAction1/blob/main/TERMS_OF_USE.md)
# Provided AS IS
# Use at your own risk
# Review and test before production deployment
# © Action1 Corporation

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
    Select-Object 'Display Name', 'Version Number', Vendor, MachineWide |
    Out-GridView -Title "Select Application" -OutputMode Single

# Process the selected application.
if ($SelectedAppData) {
    if (-not $SelectedAppData.MachineWide) {
        Write-Output "Action1 does not support per-user app deployment for security and lack of manageability reasons. Please select an application installed machine-wide."
    } else {
        $AppName = $SelectedAppData.'Display Name'
        if ($AppName -match '(?:(\d+)\.)?(?:(\d+)\.)?(?:(\d+)\.\d+)') {
            $AppVersion = $Matches[0]
        } else {
            $AppVersion = $SelectedAppData.'Version Number'
        }

        # Determine the application architecture based on the path.
        $AppArchitecture = if ($SelectedAppData.PSPath -match "WOW6432Node") { "32-bit" } else { "64-bit" }

        # Output the application information line by line.
        Write-Output "Display Name:"
        Write-Output $AppName.Trim()
        Write-Output "Vendor:"
        Write-Output $SelectedAppData.Vendor
        Write-Output "Architecture:"
        Write-Output $AppArchitecture
        Write-Output "Version Number:"
        Write-Output $AppVersion

        Write-Output "`nFor step-by-step instructions on how to add custom Software Repository packages, please follow this guide: https://www.action1.com/documentation/add-custom-packages-to-app-store/"
    }
} else {
    Write-Output "No App Selected."
}
