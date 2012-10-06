#!/usr/bin/env bash
# Prints now playing in Mocp

# source lib to get the function roll_stuff
segment_path=$(dirname $0)
source "$segment_path/../lib.sh"

max_len=40 #Trim output to this length.
speed=1 #Rolling speed

# Check if rhythmbox is playing and print that song.
mocp_pid=$(pidof mocp)
if [ -n "$mocp_pid" ]; then
    mocp_np=$(mocp -i | grep ^Title | sed "s/^Title://")
    mocp_paused=$(mocp -i | grep ^State | sed "s/^State: //")
    if [[ $mocp_np ]]; then
        mocp_np=$(roll_stuff "${mocp_np}" ${max_len} ${speed})
        if [[ "$mocp_paused" != "PAUSE" ]]; then
            echo "♫ ⮀ ${mocp_np}"
            #echo "♫ ⮀ ${mocp_np}" | cut -c1-"$max_len"
        elif [[ "$mocp_paused" == "PAUSE" ]]; then
            echo "♫ || ${mocp_np}"
            #echo "♫ || ${mocp_np}" | cut -c1-"$max_len"
        fi
    fi
fi
