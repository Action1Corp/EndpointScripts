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
# MATTER BEYOND ACTION1’S REASONABLE CONTROL. SOME STATES DO NOT ALLOW THE
# EXCLUSION OR LIMITATION OF INCIDENTAL OR CONSEQUENTIAL DAMAGES, SO THE ABOVE
# LIMITATIONS AND EXCLUSIONS MAY NOT APPLY TO YOU.



Function rpw
{
    param([int]$len = 10)
    $Chars = @{
            lc   = (97..122) | Get-Random -Count 10 | % {[char]$_}
            uc   = (65..90)  | Get-Random -Count 10 | % {[char]$_}
            n     = (48..57)  | Get-Random -Count 10 | % {[char]$_}
            s = (33..47)+(58..64)+(91..96)+(123..126) | Get-Random -Count 10 | % {[char]$_}
    }
    $Set = $Chars.uc + $Chars.lc + $Chars.n + $Chars.s
    -join(Get-Random -Count $len -InputObject $Set)
}

$U="A1Admin"
$P=$(rpw -len 12)


if (Get-LocalUser -Name $U -ErrorAction SilentlyContinue){
        Write-Host "Account is already present, Action: Password Reset/Enable"
        Get-LocalUser -Name $U | Set-LocalUser -Password $(ConvertTo-SecureString -String $P -AsPlainText -Force)
        Enable-LocalUser -Name $U
        Write-Host "`nTemp PW assigned: $P"
    }else{
        Write-Host "Account is not present, Action: Create account and Task."
        New-LocalUser -Name $U -Password $(ConvertTo-SecureString -String $P -AsPlainText -Force) -Description "Action1 remote access admin account." | Out-Null
        Add-LocalGroupMember -Group "Administrators" -Member $U
        $T=New-ScheduledTaskTrigger -AtLogon -User $U
        $A=New-ScheduledTaskAction -Execute "net" -Argument "user $U /active:no"
        Register-ScheduledTask -TaskName "DisableSupportAccount" -Trigger $T -Action $A -User $U -RunLevel Highest  | Out-Null
        Write-Host "`nTemp PW assigned: $P"
    }
    

