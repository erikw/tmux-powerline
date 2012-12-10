#!/usr/bin/env bash
# Now playing for cmus.

trim_method="trim" 	# Can be {trim or roll).
max_len=40			# Trim output to this length.
roll_speed=2		# Roll speed in chraacters per second.

segment_path=$(dirname $0)
source "$segment_path/../lib.sh"

#cmus-remote returns EXIT_FAILURE/EXIT_SUCCESS depending on whether or
#not cmus is running.
if cmus-remote -Q > /dev/null 2>&1; then
    status=$(cmus-remote -Q | grep "status" | cut -d ' ' -f 2)
    artist=$(cmus-remote -Q | grep -m 1 "artist" | cut -d ' ' -f 3-)
    title=$(cmus-remote -Q | grep "title" | cut -d ' ' -f 3-)
    #The lines below works fine. Just uncomment them and add them
    # in np below if you want the track number or album name.
    #tracknumber=$(cmus-remote -Q | grep "tracknumber" | cut -d ' ' -f 3)
    #album=$(cmus-remote -Q | grep "album" | cut -d ' ' -f 3-)

    np=$(echo "${artist} - ${title}")

    if [ "$status" == "playing" ]; then
    	play_sym="⮀"
    elif [ "$status" == "paused" ]; then
    	play_sym="||"
    else
    	exit 0 # Not playing music.
    fi
 
    case "$trim_method" in
        "roll")
        	np=$(roll_text "${np}" ${max_len} ${roll_speed})
        	;;
        "trim")
			np=${np:0:max_len}
			;;
	esac
	echo "♫ ${play_sym} ${np}"
	exit 0
fi
