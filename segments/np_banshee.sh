#!/usr/bin/env bash
# Prints now playing in Banshee.

## Check if banshee is playing and print that song
#MYPID=$(pidof banshee)
#if [[ "x$MYPID" != "x" ]]; then
	## Get and set DBUS_SESSION_BUS_ADDRESS (Just in case)
	#DBUS_ADDRESS=`grep -z DBUS_SESSION_BUS_ADDRESS /proc/$MYPID/environ 2> /dev/null| sed 's/DBUS/\nDBUS/g' | tail -n 1`
	#if [ "x$DBUS_ADDRESS" != "x" ]; then
		#export $DBUS_ADDRESS
	#fi

	#STATUS=$(banshee --query-current-state 2> /dev/null)
	#if [[ "$STATUS" == "current-state: playing" ]]; then
		#INFO=$(banshee --query-album --query-artist --query-title 2> /dev/null)
		#ALBUM=$(echo "$INFO" | head -n 1 | tail -n 1 | cut -f2- -d' ')
		#ARTIST=$(echo "$INFO" | head -n 2 | tail -n 1 | cut -f2- -d' ')
		#TITLE=$(echo "$INFO" | head -n 3 | tail -n 1 | cut -f2- -d' ')
		#echo np: "[$ALBUM] - $ARTIST - $TITLE"
	#fi
#fi

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

