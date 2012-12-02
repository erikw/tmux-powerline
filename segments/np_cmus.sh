#!/bin/env bash
# Now playing for cmus.

trim_method="trim" 	# Can be {trim or roll).
max_len=40			# Trim output to this length.
roll_speed=2		# Roll speed in chraacters per second.

segment_path=$(dirname $0)
source "$segment_path/../lib.sh"

cmus_pid=$(ps -A | grep -m1 cmus | awk '{print $1}')
if [ -n "$cmus_pid" ]; then
    status=$(cmus-remote -Q | grep "status" | cut -d ' ' -f 2)
    artist=$(cmus-remote -Q | grep "artist" | cut -d ' ' -f 3-)
    title=$(cmus-remote -Q | grep "title" | cut -d ' ' -f 3-)

    np=$(echo "${artist} - ${title}")

    if [ "$status" == "playing" ]; then
        case "$trim_method" in
            "roll")
        		np=$(roll_text "${np}" ${max_len} ${roll_speed})
        		;;
            "trim")
				np=${np:0:max_len}
				;;
		esac
		echo "♫ ${np}"
		exit 0
    fi
fi
