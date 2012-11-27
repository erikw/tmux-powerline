#!/usr/bin/env sh

trim_method="trim" 	# Can be {trim or roll).
max_len=40			# Trim output to this length.
roll_speed=2

segment_path=$(dirname $0)
source "$segment_path/../lib.sh"

np=$(osascript $segment_path/np_rdio_mac.script) 



if [ -n "$np" ]; then
    case "$trim_method" in
        "roll")
        	np=$(roll_stuff "${np}" ${max_len} ${roll_speed})
        	;;
        "trim")
			np=$(echo "${np}" | cut -c1-"$max_len")
			;;
	esac
	echo "♫ ${np}"
    exit 0
fi
