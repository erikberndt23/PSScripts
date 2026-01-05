$services = @(
    "PDQInventory",
    "PDQDeploy"
)

foreach ($svc in $services) {
    if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
        Restart-Service -Name $svc -Force
    }
}