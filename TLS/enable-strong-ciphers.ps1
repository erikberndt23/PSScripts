# View currently enabled cipher suites
Get-TlsCipherSuite

# Disable a weak cipher suite example
Disable-TlsCipherSuite -Name "TLS_RSA_WITH_3DES_EDE_CBC_SHA"

# Enable a strong one if not already present
Enable-TlsCipherSuite -Name "TLS_AES_256_GCM_SHA384" -Position 0