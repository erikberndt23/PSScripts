# Reset Computer Machine Password (run from affected machine.) Username can be changed but must be a domain admin. Enter password at prompt.
Reset-ComputerMachinePassword -Server spc-dc01 -Credential DOMAIN\DomainAdministrator
# Repair SChannel Communication with DC 
Test-ComputerSecureChannel -Repair -Credential DOMAIN\DomainAdministrator
# Test SChannel Communication with DC
nltest /sc_verify:domain.tld