Import-Module ActiveDirectory
Import-Module DnsServer

$zone = "1.10.in-addr.arpa"
$dnsServer = "10.12.1.12"

Get-ADComputer -Filter * -Properties IPv4Address, DNSHostName | 
Where-Object { $_.IPv4Address -ne $null -and $_.IPv4Address -like "10.1.10*" } | 
ForEach-Object {
    $octets = $_.IPv4Address.Split(".")
    $ptr = "$($octets[3]).$($octets[2])"
    $fqdn = $_.DNSHostName

    try {
        # Check if record exists
        $existing = Get-DnsServerResourceRecord -ZoneName $zone -Name $ptr -RRType Ptr -ComputerName $dnsServer -ErrorAction SilentlyContinue

        if ($existing) {
            if ($existing.RecordData.PtrDomainName -eq $fqdn) {
                Write-Host "Skipped (correct): $($_.IPv4Address) -> $fqdn"
            } else {
                # Update if record exists but points to wrong name
                Remove-DnsServerResourceRecord -ZoneName $zone -Name $ptr -RRType Ptr -Force -ComputerName $dnsServer
                Add-DnsServerResourceRecordPtr -ZoneName $zone -Name $ptr -PtrDomainName $fqdn -ComputerName $dnsServer
                Write-Host "Updated (stale): $($_.IPv4Address) -> $fqdn"
            }
        } else {
            # If no record exists create it
            Add-DnsServerResourceRecordPtr -ZoneName $zone -Name $ptr -PtrDomainName $fqdn -ComputerName $dnsServer
            Write-Host "Added (new): $($_.IPv4Address) -> $fqdn"
        }
    } catch {
        Write-Host "Error $($_.IPv4Address): $_"
    }
}