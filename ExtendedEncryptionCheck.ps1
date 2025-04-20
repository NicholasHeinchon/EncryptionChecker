# Requires PowerShell Core (6+)
# Check-DriveEncryption.ps1

# Collect results in an array
$results = @()

function Add-Result {
    param($vol, $stat, $method, $vendor)
    $results += [PSCustomObject]@{
        Volume            = $vol
        ProtectionStatus  = $stat
        EncryptionMethod  = $method
        Vendor            = $vendor
    }
}

# PLATFORM BRANCHING
if ($IsWindows) {
    # Try the native BitLocker cmdlet
    try {
        Import-Module BitLocker -ErrorAction Stop
        $bl = Get-BitLockerVolume
        foreach ($v in $bl) {
            $stat = switch ($v.ProtectionStatus) {
                0 { 'Off' }
                1 { 'On' }
                default { "Unknown ($($v.ProtectionStatus))" }
            }
            Add-Result $v.MountPoint $stat $v.EncryptionMethod 'Microsoft BitLocker'
        }
    }
    catch {
        # Fallback: parse manage-bde text output
        $text = manage-bde -status 2>&1
        if ($text -match 'Volume\s+([A-Za-z]:)') {
            foreach ($drive in ($text -split "Volume [A-Za-z]:" | Where { $_ })) {
                if ($drive -match '([A-Za-z]:)\s+(.+?)\r') {
                    $mp = $matches[1]
                    $ps = if ($drive -match 'Protection On') { 'On' }
                          elseif ($drive -match 'Protection Off') { 'Off' }
                          else { 'Unknown' }
                    $enc = ($drive -match 'Encryption Method:\s+(.+)') | Out-Null; $em = $matches[1]
                    Add-Result $mp $ps $em 'Microsoft BitLocker'
                }
            }
        }
    }

    # Spot VeraCrypt if running
    if (Get-Process -Name veracrypt -ErrorAction SilentlyContinue) {
        Add-Result 'N/A' 'Container Mounted' 'VeraCrypt Volume' 'VeraCrypt'
    }
}
elseif ($IsMacOS) {
    # FileVault via fdesetup
    try {
        $fv = fdesetup status 2>&1
        $on = $fv -match 'On'
        Add-Result '/' ($on ? 'Encrypted' : 'Not Encrypted') 'Apple FileVault' 'Apple'
    } catch {
        Add-Result '/' 'Error' 'FileVault Check Failed' 'Apple'
    }

    # Spot VeraCrypt on Mac
    if (Get-Process -Name VeraCrypt -ErrorAction SilentlyContinue) {
        Add-Result 'N/A' 'Container Mounted' 'VeraCrypt Volume' 'VeraCrypt'
    }
}
else {
    Write-Output "Unsupported platform: $($PSVersionTable.PSPlatform)"
}

# OUTPUT
if ($results.Count) {
    $results | Format-Table -AutoSize
} else {
    Write-Output "No full‑disk encryption detected."
}

