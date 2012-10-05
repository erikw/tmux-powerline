#!/usr/bin/env bash
# Prints now playing in Mocp. If the output is too long it will scroll like a marquee tag.

max_len=40	#Trim output to this length.

# Check if rhythmbox is playing and print that song.
mocp_pid=$(pidof mocp)
if [ -n "$mocp_pid" ]; then
    mocp_np=$(mocp -i | grep ^Title | sed "s/^Title://")
    mocp_paused=$(mocp -i | grep ^State | sed "s/^State: //")
    if [[ $mocp_np ]]; then
        # Anything starting with 0 is a Octal number in shell,C or Perl,
        # so we must explicitly state the base of a number using base#number.
        offset=$((10#$(date +%S) * ${#mocp_np} / 60))
        # Truncate title.
        mocp_np=${mocp_np:offset:max_len}
        # How many spaces we need to fill to keep the length of status?
        fill_count=$((max_len - ${#mocp_np}))
        for (( i=0; i < fill_count; i++ )); do
          	mocp_np=$(echo "$mocp_np"" ")
        done
        if [[ "$mocp_paused" != "PAUSE" ]]; then
            echo "♫ ⮀ ${mocp_np}"
            #echo "♫ ⮀ ${mocp_np}" | cut -c1-"$max_len"
        elif [[ "$mocp_paused" == "PAUSE" ]]; then
            echo "♫ || ${mocp_np}"
            #echo "♫ || ${mocp_np}" | cut -c1-"$max_len"
        fi
    fi
fi
