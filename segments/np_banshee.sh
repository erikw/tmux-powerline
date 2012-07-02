#!/usr/bin/env bash
# Prints now playing in Banshee.

max_len=40	# Trim output to this length.

# Check if banshee is playing and print that song.
banshee_pid=$(pidof banshee)
if [ -n "$banshee_pid" ]; then
	banshee_status=$(banshee --query-current-state 2> /dev/null)
	if [[ "$banshee_status" == "current-state: playing" ]]; then
		np=$(banshee --query-artist --query-title | cut  -d ":" -f2 | sed  -e 's/ *$//g' -e 's/^ *//g'| sed -e ':a;N;$!ba;s/\n/ - /g' )
		echo "♫ ${np}" | cut -c1-"$max_len"
	fi
fi
