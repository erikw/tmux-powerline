#!/bin/sh
# Prints the local network IP address.
ip=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

echo "Ⓛ ${ip}"

exit 0
