Set-NetIPInterface -InterfaceAlias "Wired" -Dhcp Enabled
Set-DnsClientServerAddress -InterfaceAlias "Wired" -ResetServerAddresses