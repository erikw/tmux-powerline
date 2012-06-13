#!/bin/bash
# Print a simple line of NP in mpd.
#
# Previously I used something as simple as
#mpc --format "%artist%\n%title%" | grep -Pzo '^(.|\n)*?(?=\[)' | sed ':a;N;$!ba;s/\n/ - /g' | sed 's/\s*-\s$//' | cut -c1-50
# But I decided that I don't want any info about songs if there is nothing playing. Unfortunately I did not find a way of expressing this with mpc (I'm sure there is with idle/idleloop) but I did found a useful library: libmpdclient. I've used version 2.7 when developing my small program. Download the latest version here: http://sourceforge.net/projects/musicpd/files/libmpdclient/
 
cd "$(dirname $0)"

if [ ! -x "mpd_np" ]; then
	make clean all &>/dev/null
fi
if [ -x "mpd_np" ]; then
	np=$(mpd_np)
	if [ -n "$np" ]; then
		echo "♫ ${np}" | cut -c1-50
	fi
	exit 0
else
	exit 1
fi
