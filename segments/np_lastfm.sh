#!/usr/bin/env bash
# Prints last scrobbled song on Last.fm
username=""	# Your last.fm username

segment_path=$(dirname $0)
source "$segment_path/../lib.sh"

# Update period in seconds.
update_period=30
# Cache file.
tmp_file="${tp_tmpdir}/np_lastfm.txt"

trim_method="trim" 	# Can be {trim or roll).
max_len=40			# Trim output to this length.
roll_speed=2		# Roll speed in chraacters per second.

if [ -f "$tmp_file" ]; then
	if [ "$PLATFORM" == "mac" ]; then
		last_update=$(stat -f "%m" ${tmp_file})
	else
		last_update=$(stat -c "%Y" ${tmp_file})
	fi
	time_now=$(date +%s)

	up_to_date=$(echo "(${time_now}-${last_update}) < ${update_period}" | bc)
	if [ "$up_to_date" -eq 1 ]; then
		np=$(cat ${tmp_file})
	fi
fi

if [ -z "$np" ]; then
	#np=$(wget -qO- http://ws.audioscrobbler.com/1.0/user/${username}/recenttracks.txt | head -n 1 | sed -e 's/^[0-9]*,//' | sed 's/\xe2\x80\x93/-/')
	np=$(curl --max-time 2 -s  http://ws.audioscrobbler.com/1.0/user/${username}/recenttracks.txt | head -n 1 | sed -e 's/^[0-9]*,//' | sed 's/\xe2\x80\x93/-/')
	if [ "$?" -eq "0" ] && [ -n "$np" ]; then
		echo "${np}" > $tmp_file
	fi
fi

if [ -n "$np" ]; then
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
else
	exit 1
fi
