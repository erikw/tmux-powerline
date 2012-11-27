#!/usr/bin/env sh
# Prints last scrobbled song on Last.fm
username=""	# Your last.fm username

trim_method="trim" 	# Can be {trim or roll).
max_len=40			# Trim output to this length.
roll_speed=2		# Roll speed in chraacters per second.

segment_path=$(dirname $0)
source "$segment_path/../lib.sh"

np=$(wget -qO- http://ws.audioscrobbler.com/1.0/user/${username}/recenttracks.txt | head -n 1 | sed -e 's/^[0-9]*,//' | sed 's/\xe2\x80\x93/-/')


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
else
	exit 1
fi
