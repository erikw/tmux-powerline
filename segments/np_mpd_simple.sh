#!/usr/bin/env bash
# Simple np script for mpd. Works with streams!
# Only tested on OS X... should work the same way on other platforms though.

max_len=40	# Trim output to this length.
SYMBOL="♫"

NP=$(mpc current 2>&1)
if [ $? -eq 0 ] && [ -n "$NP" ]; then
    	mpc | grep "paused" > /dev/null
    	if [ $? -eq 0 ]; then
        	exit 1
    	fi

    	echo "${SYMBOL} ${NP}" | cut -c1-"$max_len"
    	exit 0
fi

exit 1
