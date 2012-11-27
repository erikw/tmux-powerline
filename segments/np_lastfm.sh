#!/bin/bash
USERNAME=lastfm_username
wget -qO- http://ws.audioscrobbler.com/1.0/user/$USERNAME/recenttracks.txt|head -n 1|sed -e 's/^[0-9]*,//'|sed 's/\xe2\x80\x93/-/'
