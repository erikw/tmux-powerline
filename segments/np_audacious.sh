#!/usr/bin/env bash
# Print Audacious now playing.

max_len=40	# Trim output to this length.

# Check if audacious is playing and print that song.
audacious_pid=$(pidof audacious)
if [ -n "$audacious_pid" ]; then
	if $(audtool playback-playing); then
		echo "♫ $(audtool current-song)" | cut -c1-"$max_len"
	fi
fi
