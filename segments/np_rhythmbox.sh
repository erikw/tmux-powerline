#!/usr/bin/env bash
# Prints now playing in Rhytmbox.

max_len=40	# Trim output to this length.

# Check if rhythmbox is playing and print that song.
rhythmbox_pid=$(pidof rhythmbox)
if [ -n "$rhythmbox_pid" ]; then
	rhythmbox_np=$(rhythmbox-client --no-start --print-playing)	# Does not tell if the music is playing or paused.
	rhythmbox_paused=$(xwininfo -root -tree | grep "$rhythmbox_np" | sed "s/${rhythmbox_np}//;s/ //g" | cut -f2 -d '"')
	# TODO I cant produce the output "Not playing", using rhythmbox 2.97.
	#STATUS=$(rhythmbox-client --no-start --print-playing)
	if [[ "$rhythmbox_paused" != "(Paused)" ]]; then
		echo "♫ ${rhythmbox_np}" | cut -c1-"$max_len"
	fi
fi
