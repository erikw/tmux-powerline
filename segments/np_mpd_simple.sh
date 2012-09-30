#!/usr/bin/env bash
# np_mpd_simple.sh
# Simple np script for mpd. Works with streams!
# Only tested on OS X... should work the same way on other platforms though.

NP=`mpc current 2>&1`
if [ $? -eq 0 ] && [ -n "$NP" ]
then
    echo "♫  $NP" 
    exit 0
fi

exit 1

