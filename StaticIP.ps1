$IP = "10.1.1.200"
$MaskBits = 24 # This means subnet mask = 255.255.255.0
$IPType = "IPv4"

 # Configure the IP address and default gateway
New-NetIPAddress `
    -InterfaceAlias "Wired" `
    -AddressFamily $IPType `
    -IPAddress $IP `
    -PrefixLength $MaskBits