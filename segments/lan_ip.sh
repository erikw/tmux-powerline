#!/usr/bin/env bash
# Prints the local network IP address for a staticly defined NIC or search for an IP address on all active NICs.

# TODO fix the mac part so it also can search for interfaces like the Linux one can.
if [ "$PLATFORM" == "mac" ]; then
	nic0="en0"
	nic1="en1"
	ip0=$(/sbin/ifconfig ${nic0} 2>/dev/null | grep 'inet ')
	ip1=$(/sbin/ifconfig ${nic1} 2>/dev/null | grep 'inet ')
else
	#nic=eth0		# Use this NIC.
	nic="USE_FIRST_FOUND"	# Find the first IP address on all active NICs.

	if [ "$nic" == "USE_FIRST_FOUND" ]; then
		all_nics=$(ifconfig | cut -d ' ' -f1)
		nics=(${all_nics[@]//lo/}) 	# Remove lo interface.

		for nic in ${nics[@]}; do
			lan_ip=$(ifconfig "$nic" |  grep -Po "(?<=inet addr:)[^ ]+")
			[ -n "$lan_ip" ] && break
		done
	else
		lan_ip=$(ifconfig "$nic" | grep -Po "(?<=inet addr:)[^ ]+")
	fi
fi

if [ -n "$lan_ip" ]; then

	#echo "Ⓛ ${lan_ip}"
	echo "ⓛ ${lan_ip}"
	exit 0
else
	exit 1
fi
