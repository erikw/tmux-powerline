#!/bin/sh
# Prints the local network IP address.
nic0="eth0"
nic1="wlan0"
ip0=$(ifconfig ${nic0} | grep 'inet addr:')
ip1=$(ifconfig ${nic1} | grep 'inet addr:')
if [ -n "$ip0" ]; then
	ip="$ip0"
elif [ -n "$ip1" ]; then
	ip="$ip1"
fi

if [ -n "$ip" ]; then
	ip=$(echo "$ip" | cut -d: -f2 | awk '{ print $1}')

	echo "Ⓛ ${ip}"
	exit 0
else
	exit 1
fi
