#!/bin/sh
# Prints the WAN IP address.
tmp_file="/tmp/wan_ip.txt"

wan_ip=""
if [ -f "$tmp_file" ]; then
	last_update=$(stat -c "%Y" ${tmp_file})
	time_now=$(date +%s)
	update_period=960

	up_to_date=$(echo "(${time_now}-${last_update}) < ${update_period}" | bc)
	if [ "$up_to_date" -eq 1 ]; then
		wan_ip=$(cat ${tmp_file})
	fi
fi

if [ -z "$wan_ip" ]; then
	#wan_ip=$(wget --timeout=1 --tries=1 -O - http://formyip.com/ 2>/dev/null | grep -Pzo "(?<=Your IP is )[^<]*")
	wan_ip=$(wget --timeout=2 --tries=1 -O - http://whatismyip.akamai.com/ 2>/dev/null)
	if [ "$?" -eq "0" ]; then
		echo "${wan_ip}" > /tmp/wan_ip.txt
	elif [ -f "${tmp_file}" ]; then
		wan_ip=$(cat ${tmp_file})
	fi
fi
	#echo "Ⓦ ${wan_ip} "
	echo "ⓦ ${wan_ip} "

exit 0
