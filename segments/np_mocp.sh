#!/usr/bin/env bash
# Prints now playing in Mocp

max_len=40 #Trim output to this length.

# Check if rhythmbox is playing and print that song.
mocp_pid=$(pidof mocp)
if [ -n "$mocp_pid" ]; then
    mocp_np=$(mocp -i | grep ^Title | sed "s/^Title://")
    mocp_paused=$(mocp -i | grep ^State | sed "s/^State: //")
    if [[ $mocp_np ]]; then
        if [[ "$mocp_paused" != "PAUSE" ]]; then
            echo "♫ ⮀ ${mocp_np}" | cut -c1-"$max_len"
        elif [[ "$mocp_paused" == "PAUSE" ]]; then
            echo "♫ || ${mocp_np}" | cut -c1-"$max_len"
        fi
    fi
fi
