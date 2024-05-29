# Name: Local Admin Solution
# Description: Maintains a local admin account for remote access.
# Copyright (C) 2024 Action1 Corporation
# Documentation: https://github.com/Action1Corp/EndpointScripts
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


Function rpw
{
    param([int]$len = 10)
    $Chars = @{
            lc   = (97..122) | Get-Random -Count 10 | % {[char]$_}
            uc   = (65..90)  | Get-Random -Count 10 | % {[char]$_}
            n     = (48..57)  | Get-Random -Count 10 | % {[char]$_}
    }
    $Set = $Chars.uc + $Chars.lc + $Chars.n # + $Chars.s
    -join(Get-Random -Count $len -InputObject $Set)
}

$U="A1Admin"
$P="$(rpw 4)-$(rpw 4)-$(rpw 4)"


if (Get-LocalUser -Name $U -ErrorAction SilentlyContinue){
        Write-Host "Account is already present, Action: Password Reset/Enable"
        Get-LocalUser -Name $U | Set-LocalUser -Password $(ConvertTo-SecureString -String $P -AsPlainText -Force)
        Enable-LocalUser -Name $U
    }else{
        Write-Host "Account is not present, Action: Create account and maintenance tasks."
        New-LocalUser -Name $U -Password $(ConvertTo-SecureString -String $P -AsPlainText -Force) -Description "Action1 remote access admin account." | Out-Null
        Add-LocalGroupMember -Group "Administrators" -Member $U
        $T=New-ScheduledTaskTrigger -AtLogon -User $U
        $T2=New-ScheduledTaskTrigger -AtStartup
        $A=New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument " -ExecutionPolicy bypass -NoProfile -WindowStyle hidden -NonInteractive -NoLogo -Command `"& {Disable-LocalUser -Name $($U); Get-LocalUser -Name $U `| Set-LocalUser -Password `$(ConvertTo-SecureString -String `$( -join ((32..126) | Get-Random -C 16 | %{[char]$_})) -AsPlainText -Force)}`""
        $S=New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
        Register-ScheduledTask -TaskName "LADMIN_DISABLE_OnLogon" -Trigger $T -Action $A -User $U -RunLevel Highest -Settings $S | Out-Null # At logon of named user.
        Register-ScheduledTask -TaskName "LADMIN_DISABLE_OnStart" -Trigger $T2 -Action $A -User 'System' -RunLevel Highest -Settings $S | Out-Null # At startup in case system was rebooted before watchdog expired.
    }
    Write-Host "`nTemp PW assigned: $P"
    Start-Process "cmd" -ArgumentList "/c timeout /t 300 /nobreak & powershell -ExecutionPolicy bypass -NoProfile -WindowStyle hidden -NonInteractive -NoLogo -Command `"& {Disable-LocalUser -Name $($U);Get-LocalUser -Name $U | Set-LocalUser -Password `$(ConvertTo-SecureString -String `$( -join ((32..126) | Get-Random -C 16 | %{[char]$_})) -AsPlainText -Force)}"
