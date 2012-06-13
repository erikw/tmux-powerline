#!/bin/sh
# Prints the WAN IP address.
ip=$(wget --timeout=1 --tries=1 -O - http://formyip.com/ 2>/dev/null | grep -Pzo "(?<=Your IP is )[^<]*")
if [ "$?" -eq 0 ]; then 
	echo "${ip}" > /tmp/ext_ip.txt
elif [ -f "/tmp/ext_ip.txt" ]; then
	ip=$(cat /tmp/ext_ip.txt)	
fi
echo "Ⓦ $ip "

exit 0
