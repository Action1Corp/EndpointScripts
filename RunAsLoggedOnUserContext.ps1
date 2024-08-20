# Name: RunAsLoggedOnUserContext.ps1
# Description: Script is designed to set allow for running scripts under the context of the currently logged on user.   
# Copyright (C) 2024 Action1 Corporation
# Documentation: https://www.action1.com/documentation/run-scripts-remotely/
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



# Insert Script between @'...'@

$customScriptContent = @'  
$ProgressPreference = "SilentlyContinue" # Keep this in place

# Your custom script goes here - example script below

(New-Object -ComObject Wscript.Shell).Popup("Hello", 5, "Message From Your IT Team", 64)
   
'@

# Define all necessary Windows API functions and structures
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class NativeMethods
{
    [StructLayout(LayoutKind.Sequential)]
    public struct PROCESS_INFORMATION
    {
        public IntPtr hProcess;
        public IntPtr hThread;
        public uint dwProcessId;
        public uint dwThreadId;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct STARTUPINFO
    {
        public uint cb;
        public string lpReserved;
        public string lpDesktop;
        public string lpTitle;
        public uint dwX;
        public uint dwY;
        public uint dwXSize;
        public uint dwYSize;
        public uint dwXCountChars;
        public uint dwYCountChars;
        public uint dwFillAttribute;
        public uint dwFlags;
        public short wShowWindow;
        public short cbReserved2;
        public IntPtr lpReserved2;
        public IntPtr hStdInput;
        public IntPtr hStdOutput;
        public IntPtr hStdError;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct WTS_SESSION_INFO
    {
        public uint SessionID;
        [MarshalAs(UnmanagedType.LPStr)]
        public string pWinStationName;
        public uint State;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct LUID
    {
        public uint LowPart;
        public int HighPart;
    }

    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct LUID_AND_ATTRIBUTES
    {
        public LUID Luid;
        public uint Attributes;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct TOKEN_PRIVILEGES
    {
        public uint PrivilegeCount;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 1)]
        public LUID_AND_ATTRIBUTES[] Privileges;
    }

    [DllImport("wtsapi32.dll", SetLastError = true)]
    public static extern bool WTSEnumerateSessions(
        IntPtr hServer,
        int Reserved,
        int Version,
        ref IntPtr ppSessionInfo,
        ref int pCount);

    [DllImport("wtsapi32.dll")]
    public static extern void WTSFreeMemory(IntPtr pMemory);

    [DllImport("wtsapi32.dll", SetLastError = true)]
    public static extern bool WTSQueryUserToken(uint sessionId, out IntPtr phToken);

    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern bool CreateProcessAsUser(
        IntPtr hToken,
        string lpApplicationName,
        string lpCommandLine,
        IntPtr lpProcessAttributes,
        IntPtr lpThreadAttributes,
        bool bInheritHandles,
        uint dwCreationFlags,
        IntPtr lpEnvironment,
        string lpCurrentDirectory,
        ref STARTUPINFO lpStartupInfo,
        out PROCESS_INFORMATION lpProcessInformation);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool CloseHandle(IntPtr hObject);

    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool GetTokenInformation(
        IntPtr TokenHandle,
        TOKEN_INFORMATION_CLASS TokenInformationClass,
        IntPtr TokenInformation,
        uint TokenInformationLength,
        out uint ReturnLength);

    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool LookupPrivilegeValue(string lpSystemName, string lpName, ref LUID lpLuid);

    [DllImport("advapi32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool AdjustTokenPrivileges(IntPtr TokenHandle, bool DisableAllPrivileges, ref TOKEN_PRIVILEGES NewState, uint BufferLength, IntPtr PreviousState, IntPtr ReturnLength);

    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool DuplicateTokenEx(
        IntPtr hExistingToken,
        uint dwDesiredAccess,
        IntPtr lpTokenAttributes,
        int ImpersonationLevel,
        int TokenType,
        out IntPtr phNewToken);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern uint WaitForSingleObject(IntPtr hHandle, uint dwMilliseconds);

    public enum TOKEN_INFORMATION_CLASS
    {
        TokenUser = 1,
        TokenGroups,
        TokenPrivileges,
        // ... other token information classes ...
    }

    public const uint NORMAL_PRIORITY_CLASS = 0x0020;
    public const uint CREATE_UNICODE_ENVIRONMENT = 0x00000400;
    public const int WTS_CURRENT_SERVER_HANDLE = 0;
    public const uint SE_PRIVILEGE_ENABLED = 0x00000002;
    public const uint INFINITE = 0xFFFFFFFF;
    public const uint WAIT_ABANDONED = 0x00000080;
    public const uint WAIT_OBJECT_0 = 0x00000000;
    public const uint WAIT_TIMEOUT = 0x00000102;
}

public class WtsApi32
{
    [DllImport("wtsapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern bool WTSQuerySessionInformation(
        IntPtr hServer,
        uint sessionId,
        WTS_INFO_CLASS wtsInfoClass,
        out IntPtr ppBuffer,
        out uint pBytesReturned);

    [DllImport("wtsapi32.dll")]
    public static extern void WTSFreeMemory(IntPtr pMemory);

    public enum WTS_INFO_CLASS
    {
        WTSUserName = 5
    }
}

public class UserEnv
{
    [DllImport("userenv.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern bool CreateEnvironmentBlock(out IntPtr lpEnvironment, IntPtr hToken, bool bInherit);

    [DllImport("userenv.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool DestroyEnvironmentBlock(IntPtr lpEnvironment);
}
"@

function Convert-ScriptBlockToBase64 {
    param (
        [ScriptBlock]$ScriptBlock
    )
    $scriptString = $ScriptBlock.ToString()
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($scriptString)
    return [Convert]::ToBase64String($bytes)
}

function Get-ActiveUserSession {
    try {
        $pSessionInfo = [IntPtr]::Zero
        $sessionCount = 0

        $result = [NativeMethods]::WTSEnumerateSessions(
            [NativeMethods]::WTS_CURRENT_SERVER_HANDLE,
            0,
            1,
            [ref]$pSessionInfo,
            [ref]$sessionCount)

        if (-not $result) {
            throw "WTSEnumerateSessions failed with error: $([System.Runtime.InteropServices.Marshal]::GetLastWin32Error())"
        }

        $dataSize = [System.Runtime.InteropServices.Marshal]::SizeOf([Type][NativeMethods+WTS_SESSION_INFO])
        $current = $pSessionInfo

        for ($i = 0; $i -lt $sessionCount; $i++) {
            $sessionInfo = [System.Runtime.InteropServices.Marshal]::PtrToStructure($current, [Type][NativeMethods+WTS_SESSION_INFO])
            if ($sessionInfo.State -eq 0) {  # WTSActive
                return $sessionInfo.SessionID
            }
            $current = [IntPtr]::Add($current, $dataSize)
        }

        throw "No active user session found"
    }
    finally {
        if ($pSessionInfo -ne [IntPtr]::Zero) {
            [NativeMethods]::WTSFreeMemory($pSessionInfo)
        }
    }
}

function Get-UserToken {
    param (
        [Parameter(Mandatory=$true)]
        [uint32]$SessionId
    )
    $userToken = [IntPtr]::Zero
    try {
        $result = [NativeMethods]::WTSQueryUserToken($SessionId, [ref]$userToken)
        if (-not $result) {
            $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
            throw "WTSQueryUserToken failed. Error code: $errorCode"
        }
        return $userToken
    }
    catch {
        throw
    }
}

function Get-UserName {
    param (
        [uint32]$SessionId
    )
    $buffer = [IntPtr]::Zero
    $bytesReturned = 0

    try {
        $result = [WtsApi32]::WTSQuerySessionInformation(
            [IntPtr]::Zero,
            $SessionId,
            [WtsApi32+WTS_INFO_CLASS]::WTSUserName,
            [ref]$buffer,
            [ref]$bytesReturned)

        if (-not $result) {
            $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
            throw "WTSQuerySessionInformation failed. Error code: $errorCode"
        }

        $username = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($buffer)
        return $username
    }
    finally {
        if ($buffer -ne [IntPtr]::Zero) {
            [WtsApi32]::WTSFreeMemory($buffer)
        }
    }
}

function Enable-TokenPrivilege {
    param ([IntPtr]$TokenHandle, [string]$Privilege)
    
    $luid = New-Object NativeMethods+LUID
    if (-not [NativeMethods]::LookupPrivilegeValue($null, $Privilege, [ref]$luid)) {
        $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
        throw "LookupPrivilegeValue failed. Error code: $errorCode"
    }
    
    $tp = New-Object NativeMethods+TOKEN_PRIVILEGES
    $tp.PrivilegeCount = 1
    $tp.Privileges = New-Object NativeMethods+LUID_AND_ATTRIBUTES[] 1
    $tp.Privileges[0] = New-Object NativeMethods+LUID_AND_ATTRIBUTES
    $tp.Privileges[0].Luid = $luid
    $tp.Privileges[0].Attributes = [NativeMethods]::SE_PRIVILEGE_ENABLED
    
    if (-not [NativeMethods]::AdjustTokenPrivileges($TokenHandle, $false, [ref]$tp, 0, [IntPtr]::Zero, [IntPtr]::Zero)) {
        $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
        throw "AdjustTokenPrivileges failed. Error code: $errorCode"
    }
}

function Create-EnvironmentBlock {
    param ([IntPtr]$TokenHandle)
    
    $envBlock = [IntPtr]::Zero
    if (-not [UserEnv]::CreateEnvironmentBlock([ref]$envBlock, $TokenHandle, $false)) {
        $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
        throw "CreateEnvironmentBlock failed. Error code: $errorCode"
    }
    return $envBlock
}

function Convert-ScriptBlockToBase64 {
    param (
        [ScriptBlock]$ScriptBlock
    )
    $scriptString = $ScriptBlock.ToString()
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($scriptString)
    return [Convert]::ToBase64String($bytes)
}

function Start-ProcessAsUserWithScript {
    param ([ScriptBlock]$ScriptBlock)
    
    $userToken = $null
    $duplicateToken = [IntPtr]::Zero
    $envBlock = [IntPtr]::Zero
    $startupInfo = New-Object NativeMethods+STARTUPINFO
    $processInfo = New-Object NativeMethods+PROCESS_INFORMATION

    try {
        $sessionId = Get-ActiveUserSession
        
        $userToken = Get-UserToken $sessionId
        
        $username = Get-UserName -SessionId $sessionId
        
        # Duplicate token to modify it
        $result = [NativeMethods]::DuplicateTokenEx(
            $userToken,
            0xF01FF, # TOKEN_ALL_ACCESS
            [IntPtr]::Zero,
            2, # SecurityImpersonation
            1, # TokenPrimary
            [ref]$duplicateToken)
        
        if (-not $result) {
            $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
            throw "DuplicateTokenEx failed. Error code: $errorCode"
        }
        
        # Enable specific privileges
        Enable-TokenPrivilege $duplicateToken "SeAssignPrimaryTokenPrivilege"
        Enable-TokenPrivilege $duplicateToken "SeIncreaseQuotaPrivilege"
        
        $envBlock = Create-EnvironmentBlock $duplicateToken
        
        $encodedScript = Convert-ScriptBlockToBase64 $ScriptBlock
        
        $powershellPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
        
        $commandLine = "`"$powershellPath`" -NoProfile -ExecutionPolicy Bypass -EncodedCommand $encodedScript"
        
        $startupInfo.cb = [System.Runtime.InteropServices.Marshal]::SizeOf($startupInfo)
        $startupInfo.lpDesktop = "winsta0\default"
        
        $workingDirectory = $env:SystemRoot
        
        $result = [NativeMethods]::CreateProcessAsUser(
            $duplicateToken,
            $powershellPath,
            $commandLine,
            [IntPtr]::Zero,
            [IntPtr]::Zero,
            $false,
            [NativeMethods]::CREATE_UNICODE_ENVIRONMENT,
            $envBlock,
            $workingDirectory,
            [ref]$startupInfo,
            [ref]$processInfo)
        
        if (-not $result) {
            $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
            throw "CreateProcessAsUser failed. Error code: $errorCode"
        }
        
        [NativeMethods]::WaitForSingleObject($processInfo.hProcess, [NativeMethods]::INFINITE)
    }
    catch {
        throw
    }
    finally {
        if ($userToken -ne $null) { [NativeMethods]::CloseHandle($userToken) }
        if ($duplicateToken -ne [IntPtr]::Zero) { [NativeMethods]::CloseHandle($duplicateToken) }
        if ($envBlock -ne [IntPtr]::Zero) { [UserEnv]::DestroyEnvironmentBlock($envBlock) }
        if ($processInfo.hProcess -ne [IntPtr]::Zero) { [NativeMethods]::CloseHandle($processInfo.hProcess) }
        if ($processInfo.hThread -ne [IntPtr]::Zero) { [NativeMethods]::CloseHandle($processInfo.hThread) }
    }
}

# Main script execution
try {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $isSystem = $currentUser -eq "NT AUTHORITY\SYSTEM"
    if (-not $isSystem) {
        throw "Script is not running as SYSTEM. This script is designed to run in the SYSTEM context."
    }
    
    # Create the embedded script using the custom script content
    $embeddedScript = [ScriptBlock]::Create($customScriptContent)
    
    # Execute the embedded script as the logged-on user
    Start-ProcessAsUserWithScript -ScriptBlock $embeddedScript | Out-Null
}
catch {
    throw
}
