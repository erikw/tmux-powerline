#!/usr/bin/env sh
# Prints the CPU usage: user% sys% idle

if [ $PLATFORM == 'mac' ]; then
  top -l 1 | grep "CPU usage" | awk '{ print $3, $5, $7 }'
elif [ $PLATFORM == 'linux' ]; then
  top -n 1 | grep "Cpu(s)" | awk '{ print $2, $3, $5 }' | sed 's/\w\{2\},//g'
fi

exit 0
