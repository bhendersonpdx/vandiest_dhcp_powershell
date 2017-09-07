### Script to convert reservations from 192.168.x.x to 10.x.2.x
### It is written to be run on the DHCP server as admin.
### It is assumed that both the old and the new scopes exist.  

### Regular Expressions for searching 
[regex]$REGEXIP = "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"
[regex]$REGEXMAC = "\b\w{2}\w{2}\w{2}\w{2}\w{2}\w{2}\b"

$YARDNO = read-host "`nEnter the yard number that you want to transfer reservations from"

### Switch to determine the old scope and the new prefix 
switch ($YARDNO)
{
	2	{$OLDSCOPE = "192.168.2.0"; $NEWPRFX = "0.0.0"}
	3	{$OLDSCOPE = "192.168.3.0"; $NEWPRFX = ""}
	5	{$OLDSCOPE = "192.168.5.0"; $NEWPRFX = ""}
	6	{$OLDSCOPE = "192.168.6.0"; $NEWPRFX = ""}
	8	{$OLDSCOPE = "192.168.8.0"; $NEWPRFX = ""}
	9	{$OLDSCOPE = "192.168.9.0"; $NEWPRFX = ""}
	10	{$OLDSCOPE = "192.168.10.0"; $NEWPRFX = ""}
	11	{$OLDSCOPE = "192.168.11.0"; $NEWPRFX = ""}
	12	{$OLDSCOPE = "192.168.12.0"; $NEWPRFX = ""}
	14	{$OLDSCOPE = "192.168.14.0"; $NEWPRFX = ""}
	15	{$OLDSCOPE = "192.168.15.0"; $NEWPRFX = ""}
	18	{$OLDSCOPE = "192.168.18.0"; $NEWPRFX = ""}
	20	{$OLDSCOPE = "192.168.20.0"; $NEWPRFX = ""}
	21	{$OLDSCOPE = "192.168.21.0"; $NEWPRFX = ""}
	22	{$OLDSCOPE = "192.168.22.0"; $NEWPRFX = ""}
	23	{$OLDSCOPE = "192.168.23.0"; $NEWPRFX = ""}
	24	{$OLDSCOPE = "192.168.24.0"; $NEWPRFX = ""}
	25	{$OLDSCOPE = "192.168.25.0"; $NEWPRFX = ""}
	26	{$OLDSCOPE = "192.168.26.0"; $NEWPRFX = ""}
	27	{$OLDSCOPE = "192.168.27.0"; $NEWPRFX = ""}
	28	{$OLDSCOPE = "192.168.28.0"; $NEWPRFX = ""}
	29	{$OLDSCOPE = "192.168.29.0"; $NEWPRFX = ""}
	31	{$OLDSCOPE = "192.168.31.0"; $NEWPRFX = ""}
	85	{$OLDSCOPE = "192.168.85.0"; $NEWPRFX = ""}
	100 	{$OLDSCOPE = "10.0.101.0"; $NEWPRFX = ""}
	101	{$OLDSCOPE = "192.168.101.0"; $NEWPRFX = ""}
	102	{$OLDSCOPE = "192.168.102.0"; $NEWPRFX = ""}
	103	{$OLDSCOPE = "192.168.103.0"; $NEWPRFX = ""}
	104	{$OLDSCOPE = "10.0.104.0"; $NEWPRFX = ""}
	111	{$OLDSCOPE = "192.168.111.0"; $NEWPRFX = ""}
	112	{$OLDSCOPE = "192.168.112.0"; $NEWPRFX = ""}
	130	{$OLDSCOPE = "192.168.130.0"; $NEWPRFX = ""}
	201	{$OLDSCOPE = "10.0.5.0"; $NEWPRFX = ""}
	default	{write-host -foregroundcolor red "ERROR: This number is either not a valid location, or is outside of the scope of this script."; exit}
}

### Grabbing existing DHCP info from the server
$DUMP = netsh dhcp server scope $OLDSCOPE dump

	for ($i=0; $i -lt $DUMP.length; $i++)
		{	
			if ($DUMP[$i] -like "*reservedip 1*")
				{

				### Puts any line with "reservedip 1" in it into a variable
				$HIT = $DUMP[$i]

					### Seaches the line for the first 2 IP addresses and puts them into variables.
					### Since this is a netsh dump we can assume there are only 2 IPs, the scope
					### and the reservation.
					$IP1 = $REGEXIP.match($HIT)
					$LIO1 = $HIT.lastindexof("$IP1")
					$LIO1 += $IP1.length	
					$SUB1 = $HIT.Substring($LIO1)
					[string]$IP2 = $REGEXIP.match($SUB1)	

						### Searches the line for a mac address. 	
						$MAC = $REGEXMAC.match($HIT)

							### Searches for the first instance of a quotation mark and
							### puts everything after it into a variable.	
							$LIO2 = $Hit.indexof("`"")
							$DETAILS = $HIT.Substring($LIO2)

								### Translates the reservation to the new format
								$SUB2 = $IP2.lastindexof(".")
								$OLDOCT = $IP2.Substring($SUB2)
								$NEWIP = $NEWPRFX+$OLDOCT
								
									###Creates the new scope
									$NEWSCOPE = $NEWPRFX+".0"

					### Creates the converted reservation
					netsh dhcp server scope $NEWSCOPE add reservedip $NEWIP $MAC $DETAILS
				}

		}