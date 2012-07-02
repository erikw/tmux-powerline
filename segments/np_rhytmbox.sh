#!/usr/bin/env bash
# Prints now playing in Rhytmbox.

max_len=40	# Trim output to this length.

# Check if rhythmbox is playing and print that song
rhythmbox_pid=$(pidof rhythmbox)
if [ -n "$rhythmbox_pid" ]; then

	# TODO why are we interested in the DBUS-addr? Anyhow, it does not work on my system. There's no DBUS things in environ.
	# Get and set DBUS_SESSION_BUS_ADDRESS (Just in case)
	#DBUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$MYPID/environ 2> /dev/null| sed 's/DBUS/\nDBUS/g' | tail -n 1)
	#if [ "x$DBUS_ADDRESS" != "x" ]; then
		#export $DBUS_ADDRESS
	#fi

	rhythmbox_np=$(rhythmbox-client --no-start --print-playing)	# Does not tell if the music is playing or paused.
	rhythmbox_paused=$(xwininfo -root -tree | grep "$rhythmbox_np" | sed "s/${rhythmbox_np}//;s/ //g" | cut -f2 -d '"')
	# TODO I cant produce the output "Not playing", using rhythmbox 2.97.
	#STATUS=$(rhythmbox-client --no-start --print-playing)
	if [[ "$rhythmbox_paused" != "(Paused)" ]]; then
		echo "♫ ${rhythmbox_np}" | cut -c1-"$max_len"
	fi
fi
