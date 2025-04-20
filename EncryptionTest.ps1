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
