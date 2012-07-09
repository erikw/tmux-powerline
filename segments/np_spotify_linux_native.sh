#!/usr/bin/env bash
# Print Spotify now playing for GNU/Linux running the native client.
# List functions and properties with
#$ mdbus2 org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer

max_len=40	# Trim output to this length.
metadata=$(dbus-send --reply-timeout=42 --print-reply --dest=org.mpris.MediaPlayer2.spotify / org.freedesktop.MediaPlayer2.GetMetadata 2>/dev/null)
if [ "$?" -eq 0 ] && [ -n "$metadata" ]; then
	# TODO how do one express this with dbus-send? It works with qdbus but the problem is that it's probably not as common as dbus-send.
	state=$(qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player PlaybackStatus)
	if [[ $state == "Playing" ]]; then
		artist=$(echo "$metadata" | grep -PA2 "string\s\"xesam:artist\"" | tail -1 | grep -Po "(?<=\").*(?=\")")
		track=$(echo "$metadata" | grep -PA1 "string\s\"xesam:title\"" | tail -1 | grep -Po "(?<=\").*(?=\")")
		echo "♫ ${artist} - ${track}" | cut -c1-"$max_len"
	fi
fi
