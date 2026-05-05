# Discover hostnames for IPs in the 10.2.0.0/16 subnet

$ips = foreach ($third in 1..254) { foreach ($fourth in 1..254) { "10.2.$third.$fourth" } }

$ips | ForEach-Object -Parallel {
    $ip = $_
    try {
        $hostname = [System.Net.Dns]::GetHostEntry($ip).HostName
        "$ip`t$hostname"
    } catch {
        # skip if no match found
    }
} -ThrottleLimit 100 | Tee-Object -FilePath "C:\users\erikb\hostnames.txt"