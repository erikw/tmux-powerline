#!/usr/bin/env bash
# Print Spotify now playing for GNU/Linux running in wine.

max_len=40	# Trim output to this length.

## Check if Spotify is playing and print that song.
spotify_id=$(xwininfo -root -tree | grep '("spotify' | cut -f1 -d'"' | sed 's/ //g')
echo $spotify_id
if [ -n "$spotify_id" ]; then
	np=$(xwininfo -id "$spotify_id" | grep "xwininfo.*Spotify -" | grep -Po "(?<=\"Spotify - ).*(?=\"$)")
	if [ -n "$np" ]; then
		echo "♫ ${np}" | cut -c1-"$max_len"
	fi
fi
