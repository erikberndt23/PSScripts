$SecureBoot_Enabled = $false
$CA2023_Present     = $false
$Status             = 'Unknown'

try {
    $SecureBoot_Enabled = Confirm-SecureBootUEFI -ErrorAction Stop

    if (-not $SecureBoot_Enabled) {
        $Status = 'Secure Boot Disabled'
    } else {
        $dbBytes  = (Get-SecureBootUEFI db -ErrorAction Stop).bytes
        $dbString = [System.Text.Encoding]::ASCII.GetString($dbBytes)
        $CA2023_Present = $dbString -match 'Windows UEFI CA 2023'
        $Status = if ($CA2023_Present) { 'CA 2023 Present' } else { 'CA 2023 Missing' }
    }
}
catch [System.PlatformNotSupportedException] {
    $Status = 'Not Supported (non-UEFI or VM)'
}
catch [System.UnauthorizedAccessException] {
    $Status = 'Access Denied - Run as Admin'
}
catch {
    $Status = "Error: $($_.Exception.Message)"
}

[PSCustomObject]@{
    SecureBoot_Enabled = $SecureBoot_Enabled
    CA2023_Present     = $CA2023_Present
    Status             = $Status
}