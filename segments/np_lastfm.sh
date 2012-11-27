#!/bin/bash
USERNAME=lastfm_username
UPDATE_INTERVAL=30	# In seconds

###############

if [ ! -d /tmp/tmux-powerline ]; then
	mkdir -p /tmp/tmux-powerline
fi

if [ ! -f /tmp/tmux-powerline/lastfm.txt ]; then
	LAST_UPDATE=0
else
	LAST_UPDATED=$(stat -c %X /tmp/tmux-powerline/lastfm.txt)
fi

INTERVAL_AGO=$(date --date="$UPDATE_INTERVAL second ago" +%s)

if [ $LAST_UPDATED -le $INTERVAL_AGO ]; then
	touch /tmp/tmux-powerline/lastfm.txt
	wget -qO- http://ws.audioscrobbler.com/1.0/user/$USERNAME/recenttracks.txt|head -n 1|sed -e 's/^[0-9]*,//'|sed 's/\xe2\x80\x93/-/' | tee /tmp/tmux-powerline/lastfm.txt
else
	cat /tmp/tmux-powerline/lastfm.txt
fi
