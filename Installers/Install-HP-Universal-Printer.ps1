# Printer variables

$pdqPath = "$env:windir\AdminArsenal\Printers\M631"
$printerIP = "<printer_ip_address>"
$printerName = "<printer_name>"
$driverINFPath = Join-Path $pdqPath "*.inf"
$DriverName = "HP Universal Printing PCL 6"
$portName = "$printerIP"

# Install HP Universal Printing PCL 6 driver

if (Test-Path $driverINFPath) {
    Write-Host "Adding HP driver to driver store..."
    pnputil /add-driver $driverINFPath /install /subdirs
} else {
    Write-Host "ERROR: Driver INF not found at $driverINFPath"
    exit 1
}

# Add print driver to driver store

try {
    Write-Host "Adding printer driver: $driverName"
    Add-PrinterDriver -Name $driverName -ErrorAction Stop
}
catch {
    Write-Host "Driver may already exist. Continuing..."
}

# Create TCP port if it doesn't exist

if (-not (Get-PrinterPort -Name $portName -ErrorAction SilentlyContinue)) {
    Write-Host "Creating TCP/IP port $portName ..."
    Add-PrinterPort -Name $portName -PrinterHostAddress $printerIP
} else {
    Write-Host "TCP/IP port $portName already exists."
}

# Add printer if it doesn't exist

if (-not (Get-Printer -Name $printerName -ErrorAction SilentlyContinue)) {
    Write-Host "Creating printer $printerName..."
    Add-Printer -Name $printerName -DriverName $driverName -PortName $portName
} else {
    Write-Host "Printer $printerName already exists."
}

Write-Host "Printer installation complete."