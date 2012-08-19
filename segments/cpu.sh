#!/usr/bin/env sh
# Prints the CPU usage: user% sys% idle


if [ "$PLATFORM" == "mac" ]; then
  	cpu=$(top -l 1 | grep "CPU usage" | awk '{ print $3, $5, $7 }')
elif [ "$PLATFORM" == "linux" ]; then
	cpu=$(top -b -n 1 | grep "Cpu(s)" | awk '{ print $2, $3, $5 }' | sed 's/\w\{2\},//g')
fi

if [ -n "$cpu" ]; then
	echo "$cpu"
fi

exit 0
