#!/bin/bash

cmus_pid=$(ps -A | grep -m1 cmus | awk '{print $1}')
if [ -n "$cmus_pid" ]; then
    status=$(cmus-remote -Q | grep "status" | cut -d ' ' -f 2)
    artist=$(cmus-remote -Q | grep "artist" | cut -d ' ' -f 3-)
    title=$(cmus-remote -Q | grep "title" | cut -d ' ' -f 3-)

    np=$(echo "${artist} - ${title}")

    if [ "$status" == "playing" ]; then
        echo "♫  ${np}"
    fi
fi
