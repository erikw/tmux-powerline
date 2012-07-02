!/usr/bin/env bash
# Prints now playing in Banshee.

# Check if banshee is playing and print that song.
banshee_pid=$(pidof banshee)
if [ -n "$banshee_pid" ]; then
	banshee_status=$(banshee --query-current-state 2> /dev/null)
	if [[ "$banshee_status" == "current-state: playing" ]]; then
		#info=$(banshee --query-album --query-artist --query-title 2> /dev/null)
		#album=$(echo "$INFO" | head -n 1 | tail -n 1 | cut -f2- -d' ')
		info=$(banshee --query-artist --query-title 2> /dev/null)
		artist=$(echo "$INFO" | head -n 2 | tail -n 1 | cut -f2- -d' ')
		title=$(echo "$INFO" | head -n 3 | tail -n 1 | cut -f2- -d' ')
		echo "♫ ${ARTIST} - ${TITLE}"
	fi
fi

## Check if Spotify is playing and print that song
#ID=`xwininfo -root -tree | grep '("spotify' | cut -f1 -d'"' | sed 's/ //g'`
#if [[ "x$ID" != "x" ]]; then
	#TITLE=`xwininfo -id $ID | grep Spotify | cut -f7- -d' ' | sed 's/"$//'`
	#if [[ "x$TITLE" != "x" ]]; then
		#echo np: $TITLE
	#fi
#fi

## Check if audacious is playing and print that song
#MYPID=$(pidof audacious)
#if [[ "x$MYPID" != "x" ]]; then
	## Get and set DBUS_SESSION_BUS_ADDRESS (Just in case)
	#DBUS_ADDRESS=`grep -z DBUS_SESSION_BUS_ADDRESS /proc/$MYPID/environ 2> /dev/null| sed 's/DBUS/\nDBUS/g' | tail -n 1`
	#if [ "x$DBUS_ADDRESS" != "x" ]; then
		#export $DBUS_ADDRESS
	#fi

	#if $(audtool playback-playing); then
		#echo np: $(audtool current-song)
	#fi
#fi

