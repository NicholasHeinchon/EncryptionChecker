Two PowerShell scripts, to check disk encryption on Windows and macOS. Mainly for remote checks with CrowdStrike Real-Time Response (RTR), especially if laptops are lost or stolen.

Scripts

1. BitLocker Status Checker (Windows Only)

This script specifically checks if BitLocker encryption is enabled on Windows computers.

Uses built-in Windows metadata (System.Volume.BitLockerProtection).

No admin privileges needed.

Returns statuses like Encrypted, Not Encrypted, Encrypting, etc.

2. Extended Encryption Checker

This script checks if built in or third-party encryption (BitLocker, FileVault, VeraCrypt) is used on either Windows or macOS.

Checks Performed:

Windows:

BitLocker using the Get-BitLockerVolume cmdlet or fallback to manage-bde -status.

Detects VeraCrypt by checking if the VeraCrypt process (veracrypt.exe) is running.

macOS:

FileVault encryption status via the fdesetup status command.

Detects VeraCrypt by checking if a VeraCrypt process is running.

How the Scripts Work

Both scripts detect encryption differently:

BitLocker Checker: Directly queries Windows system properties (System.Volume.BitLockerProtection) to report the BitLocker status on all drives.

Extended Encryption Checker: First identifies the operating system:
Then try's the built in BitLocker cmdlet (Get-BitLockerVolume). If unavailable, it parses plaintext output from the manage-bde -status command to look through encryption details.

macOS: It runs the built-in command fdesetup status to check if FileVault is active.

VeraCrypt Detection: On both systems, it checks if the VeraCrypt process is actively running, VeraCrypt being open-source encryption.

BitLocker Status Checker Output
-BitLocker Status Checker: Reports only BitLocker encryption status per volume.

Windows and MacOS Encryption Checker Output:
-Volume (Drive letter or mount point).
-Protection Status (Encrypted, Not Encrypted, Container Mounted, etc).
-Encryption Method (specific method such as AES, XtsAes128 when available; otherwise, indicates the encryption vendor).
-Vendor (Microsoft BitLocker, Apple FileVault, VeraCrypt).

Limitations
-BitLocker Status Checker: Only works on Windows.
-Cross-Platform Checker: Supports Windows and macOS.
