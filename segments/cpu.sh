#!/usr/bin/env sh
# Prints the CPU usage

idle=`top -l 1 | grep "CPU usage" | awk '{ print $7 }' | sed 's/%//'`
used=`echo "100.00 - $idle" | bc`

echo "$used%"

exit 0

