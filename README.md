BitLocker Encryption Status Checker

This PowerShell script checks if BitLocker is enabled on all available drives, including USB drives, on a Windows computer. It's useful for remote checks using CrowdStrike Real-Time Response (RTR), especially if a laptop is reported missing.

Other Simple Command for Bitlocker check (gives version of bde Bitlocker Drive Encryption, more info if admin):

manage-bde -status

CrowdStrike RCE PowerShell Check (No admin needed):

try {
    $shell = New-Object -ComObject Shell.Application
    $drives = Get-PSDrive -PSProvider FileSystem
        foreach ($drive in $drives) {
        $path = $drive.Root
        $bitlockerStatus = $shell.NameSpace($path).Self.ExtendedProperty('System.Volume.BitLockerProtection')
        $statusDescription = switch ($bitlockerStatus) {
            0 { "Unencryptable" }
            1 { "Encrypted" }
            2 { "Not Encrypted" }
            3 { "Encrypting" }
            4 { "Encryption Paused" }
            5 { "Decryption in Progress" }
            default { "Unknown Status ($bitlockerStatus)" }
        }
        Write-Output "$path BitLocker: $statusDescription"
      }
} catch {
    Write-Output "Error retrieving BitLocker status: $_"
}

How It Works
The script checks each file system drive available and reports whether BitLocker encryption is enabled, disabled, in progress, or paused. 
Through the Shell COM object. BitLocker gives predefined numbers that represent encryption statuses, like encrypted, or encrypting.
The script then matches the numbers to descriptions using a switch statement, for a more readable status for each drive.

Limitations
-Only checks for BitLocker encryption.
-Works on Windows OS only.
