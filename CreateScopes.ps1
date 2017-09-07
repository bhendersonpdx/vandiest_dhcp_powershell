###################################################################################################
###This script requires the Microsoft.DHCP.PowerShell.Admin module:				###
###https://gallery.technet.microsoft.com/scriptcenter/05b1d766-25a6-45cd-a0f1-8741ff6c04ec      ###
###################################################################################################
###
###3/11/13 added vlan 6 and slightly altered the exclusion range. Also added a command to set the router IP for each vlan.
###
[string]$SERVER = ""
[string]$YARDNO = ""		#Yard number
[string]$ADDRESS = ""		#Scope Address
[string]$SUBNETMASK = '255.255.255.0'
[string]$VNAME = ""		#VLAN name
[string]$RANSTART = "1"	 	#Final octet of the beginning of the range IP
[string]$RANEND = "254"		#Final octet of the end of the range IP
[string]$EXCISTART = ""		#First variable for the beginning of the exclusion IP
[string]$EXCIEND = ""		#First variable for end of the exclusion IP
[string]$EXCIISTART = ""	#Second variable for the beginning of the exclusion IP
[string]$EXCIIEND = ""		#Second variable for end of the exclusion IP
[string]$EXCLUSIONIS = "" 	#Exclusion range one start
[string]$EXCLUSIONIE = ""	#Exclusion range one end
[string]$EXCLUSIONIIS = "" 	#Exclusion range two start
[string]$EXCLUSIONIIE = ""	#Exclusion range two end
[string]$RANGESTART = ""	#Full IP range start
[string]$RANGEEND = ""		#Full IP range end
[string]$YARDNAME = ""		#Yard name for superscope
$SSIPLIST = @(0,0,0,0,0,0,0)	#Array to hold the IP addresses to add to the superscope

$YARDNO = read-host "Enter the yard number of the scope you wish to create"

switch ($YARDNO) #switch to determine yard number and set the name of the superscope
{
	2	{$YARDNO = "2"; $YARDNAME = ""}
	3	{$YARDNO = "3"; $YARDNAME = ""}
	5	{$YARDNO = "5"; $YARDNAME = ""}	
	6	{$YARDNO = "6"; $YARDNAME = ""}
	8	{$YARDNO = "8"; $YARDNAME = ""}
	9	{$YARDNO = "9"; $YARDNAME = ""}
	10	{$YARDNO = "10"; $YARDNAME = ""}
	11	{$YARDNO = "11"; $YARDNAME = ""}
	12	{$YARDNO = "12"; $YARDNAME = ""}
	14	{$YARDNO = "14"; $YARDNAME = ""}
	15	{$YARDNO = "15"; $YARDNAME = ""}
	18	{$YARDNO = "18"; $YARDNAME = ""}
	20	{$YARDNO = "20"; $YARDNAME = ""}
	21	{$YARDNO = "21"; $YARDNAME = ""}
	22	{$YARDNO = "22"; $YARDNAME = ""}
	23	{$YARDNO = "23"; $YARDNAME = ""}
	24	{$YARDNO = "24"; $YARDNAME = ""}
	25	{$YARDNO = "25"; $YARDNAME = ""}
	26	{$YARDNO = "26"; $YARDNAME = ""}
	27	{$YARDNO = "27"; $YARDNAME = ""}
	28	{$YARDNO = "28"; $YARDNAME = ""}
	29	{$YARDNO = "29"; $YARDNAME = ""}
	31	{$YARDNO = "31"; $YARDNAME = ""}
	32	{$YARDNO = "32"; $YARDNAME = ""}
	default	{$YARDNO = ""; write-host -foregroundcolor red "ERROR: Invalid yard number!"; exit}
}


	for ($VLAN=2; $VLAN -le 6; $VLAN++) #Loop to create Scopes
	{
		switch ($VLAN) #switch to determine vlan and set exclusion ranges
		{
			1 {$VNAME = [string]$YARDNO+[string]$VLAN+"phones"; $EXCISTART = "1"; $EXCIEND = "99"; $EXCIISTART = "229"; $EXCIIEND = "254"}
			2 {$VNAME = [string]$YARDNO+[string]$VLAN+"clients-printers"; $EXCISTART = "1"; $EXCIEND = "99"; $EXCIISTART = "229"; $EXCIIEND = "254"}
			3 {$VNAME = [string]$YARDNO+[string]$VLAN+"pci"; $EXCISTART = "1"; $EXCIEND = "99"; $EXCIISTART = "229"; $EXCIIEND = "254"}
			4 {$VNAME = [string]$YARDNO+[string]$VLAN+"wifi-corp"; $EXCISTART = "1"; $EXCIEND = "99"; $EXCIISTART = "229"; $EXCIIEND = "254"}
			5 {$VNAME = [string]$YARDNO+[string]$VLAN+"wifi-rf"; $EXCISTART = "1"; $EXCIEND = "99"; $EXCIISTART = "229"; $EXCIIEND = "254"}
			6 {$VNAME = [string]$YARDNO+[string]$VLAN+"wifi-guest"; $EXCISTART = "1"; $EXCIEND = "99"; $EXCIISTART = "229"; $EXCIIEND = "254"}

		}
 
		
		$ADDRESS = "10."+[string]$YARDNO+"."+[string]$VLAN+".0"
		$SSIPLIST[$VLAN] = $ADDRESS
		$RANGESTART = "10."+[string]$YARDNO+"."+[string]$VLAN+"."+[string]$RANSTART
  		$RANGEEND = "10."+[string]$YARDNO+"."+[string]$VLAN+"."+[string]$RANEND
		$EXCLUSIONIS = "10."+[string]$YARDNO+"."+[string]$VLAN+"."+[string]$EXCISTART
		$EXCLUSIONIE = "10."+[string]$YARDNO+"."+[string]$VLAN+"."+[string]$EXCIEND
		$EXCLUSIONIIS = "10."+[string]$YARDNO+"."+[string]$VLAN+"."+[string]$EXCIISTART
		$EXCLUSIONIIE = "10."+[string]$YARDNO+"."+[string]$VLAN+"."+[string]$EXCIIEND
		$ROUTER = "10."+[string]$YARDNO+"."+[string]$VLAN+".1"
		
		write-host "`nCreating new DHCP Scope: " $VNAME " " $ADDRESS
		new-DHCPScope -server $SERVER -address $ADDRESS -subnetmask $SUBNETMASK -name $VNAME

		write-host "`nSetting scope to Inactive."
		netsh dhcp server \\$SERVER scope $ADDRESS set state 0

		write-host "`nSetting lease time to 5400 seconds"
		netsh dhcp server \\$SERVER scope $ADDRESS set optionvalue 51 DWORD 691200
		
		write-host "`nSetting IP Range."
		add-DHCPIPRange -Server $SERVER -Scope $ADDRESS -StartAddress $RANGESTART -EndAddress $RANGEEND 

		write-host "`nAdding exclusions."
		add-DHCPExclusionRange -Server $SERVER -Scope $ADDRESS -StartAddress $EXCLUSIONIS -EndAddress $EXCLUSIONIE
		add-DHCPExclusionRange -Server $SERVER -Scope $ADDRESS -StartAddress $EXCLUSIONIIS -EndAddress $EXCLUSIONIIE

		write-host "`nSpecifying Router IP."
		netsh dhcp server \\$SERVER scope $ADDRESS set optionvalue 003 IPADDRESS $ROUTER
			
	}
	for ($i=1; $i -le $VLAN; $i++) #Loop to create superscope and add scopes to it
		{
		write-host "`nAdding scope " $SSIPLIST[$i] "to superscope " $YARDNAME
		netsh dhcp server \\$SERVER scope $SSIPLIST[$i] set superscope $YARDNAME 1
		}



#Notes and order of commands:
#
#New-DHCPScope -server -address -subnetmask -name 
#
#Add-DHCPIPRange -Server -Scope -StartAddress -EndAddress 
#
#Add-DHCPExclusionRange -Server -Scope -StartAddress -EndAddress 
#
#Add-DHCPExclusionRange -Server -Scope -StartAddress -End Address 
#
# netsh dhcp server scope set superscope "Building 5" 1