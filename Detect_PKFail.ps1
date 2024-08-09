# Name: Detect_PKFail.ps1
# Description: Detects use of the compromised AMI trusted root anchor keys in system's UEFI firmware.
# Copyright (C) 2024 Action1 Corporation
# Documentation: https://github.com/Action1Corp/ReportDataSources
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

try
{
    $SecureBootUEFI = [System.Text.Encoding]::ASCII.GetString((Get-SecureBootUEFI PK -ErrorAction Stop).bytes) -match "DO NOT TRUST|DO NOT SHIP"
  }catch{
    $SecureBootUEFI="Error getting SecureBootUEFI information."
  }

  New-Object -Type PSCustomObject -Property $([ordered]@{
                     ISVulnerable=$SecureBootUEFI
                     A1_Key = "$($env:COMPUTERNAME)_SecureBootUEFI"
                    })