#!/usr/bin/env sh
# Prints the CPU usage: user% sys% idle

top -l1 | grep "CPU usage" | awk '{ print $3, $5, $7 }'

exit 0
