# Print current playing song in your music player of choice.

music_player="mpd"	# Music player to query.
trim_method="trim"	# Can be {trim or roll).
max_len=40			# Trim output to this length.
roll_speed=2		# Roll speed in chraacters per second.

lastfm_tmp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/np_lastfm.txt" # Cache file.
lastfm_username=""	# Your last.fm username
lastfm_update_period=30 # Update period in seconds.

run_segment() {
	#TODO sort
	local np
	case "$music_player" in
		"audacious")  np=$(__np_audacious) ;;
		"banshee")  np=$(__np_banshee) ;;
		"cmus")  np=$(__np_cmus) ;;
		"mpd")  np=$(__np_mpd) ;;
		"mpd_simple")  np=$(__np_mpd_simple) ;;
		"itunes")  np=$(__np_itunes) ;;
		"lastfm")  np=$(__np_lastfm) ;;
		"mocp")  np=$(__np_mocp) ;;
		"rdio")  np=$(__np_rdio) ;;
		"rhythmbox")  np=$(__np_rhythmbox) ;;
		"spotify")  np=$(__np_spotify) ;;
		"spotify_wine")  np=$(__np_spotify_native) ;;
	esac
	local exitcode="$?" # TODO works?
	if [ "$exitcode" -ne 0 ]; then
		return exitcode
	fi
	if [ -n "$np" ]; then
		case "$trim_method" in
			"roll")
				np=$(roll_text "${np}" ${max_len} ${roll_speed})
				;;
			"trim")
				np=${np:0:max_len}
				;;
		esac
		echo "♫ ${np}"
	fi
	return 0
}

__np_mpd() {
	# Source MPD environment variables (MPD_HOST and MPD_PORT). I refactored out this from ~/.bashrc and source this file there as well. This is not needed if you run your MPD server at localhost, no password and on the standard port.
	if [ -f $HOME/.mpd_env ]; then
		source $HOME/.mpd_env
	fi

	cd "$TMUX_POWERLINE_DIR_SEGMENTS"

	if [ ! -x "np_mpd" ]; then
		make clean np_mpd &>/dev/null
	fi
	np=$(./np_mpd)
	echo "$np"
}

__np_audacious() {
	audacious_pid=$(pidof audacious)
	if [ -n "$audacious_pid" ]; then
		if $(audtool playback-playing); then
			np=$(audtool current-song)
			echo "$np"
		fi
	fi
}

__np_banshee() {
	banshee_pid=$(pidof banshee)
	if [ -n "$banshee_pid" ]; then
		banshee_status=$(banshee --query-current-state 2> /dev/null)
		if [[ "$banshee_status" == "current-state: playing" ]]; then
			np=$(banshee --query-artist --query-title | cut  -d ":" -f2 | sed  -e 's/ *$//g' -e 's/^ *//g'| sed -e ':a;N;$!ba;s/\n/ - /g' )
			echo "$np"
		fi
	fi
}

__np_cmus() {
	#cmus-remote returns EXIT_FAILURE/EXIT_SUCCESS depending on whether or
	#not cmus is running.
	if cmus-remote -Q > /dev/null 2>&1; then
		status=$(cmus-remote -Q | grep "status" | cut -d ' ' -f 2)
		artist=$(cmus-remote -Q | grep -m 1 "artist" | cut -d ' ' -f 3-)
		title=$(cmus-remote -Q | grep "title" | cut -d ' ' -f 3-)
		#The lines below works fine. Just uncomment them and add them
		# in np below if you want the track number or album name.
		#tracknumber=$(cmus-remote -Q | grep "tracknumber" | cut -d ' ' -f 3)
		#album=$(cmus-remote -Q | grep "album" | cut -d ' ' -f 3-)

		np=$(echo "${artist} - ${title}")

		if [ "$status" == "playing" ]; then
			echo "$np"
		fi
	fi
}

__np_itunes() {
	[ ! shell_is_osx ] && return 1
	np=$(${TMUX_POWERLINE_DIR_SEGMENTS}/np_itunes.sh)
	echo "$np"
}

__np_lastfm() {
	if [ -f "$tmp_file" ]; then
		if shell_is_osx; then
			last_update=$(stat -f "%m" ${tmp_file})
		else
			last_update=$(stat -c "%Y" ${tmp_file})
		fi
		time_now=$(date +%s)

		up_to_date=$(echo "(${time_now}-${last_update}) < ${update_period}" | bc)
		if [ "$up_to_date" -eq 1 ]; then
			np=$(cat ${tmp_file})
		fi
	fi

	if [ -z "$np" ]; then
		np=$(curl --max-time 2 -s  http://ws.audioscrobbler.com/1.0/user/${username}/recenttracks.txt | head -n 1 | sed -e 's/^[0-9]*,//' | sed 's/\xe2\x80\x93/-/')
		if [ "$?" -eq "0" ] && [ -n "$np" ]; then
			echo "${np}" > $tmp_file
		fi
	fi
	echo "$np"
}

__np_mocp() {
	mocp_pid=$(pidof mocp)
	if [ -n "$mocp_pid" ]; then
    	np=$(mocp -i | grep ^Title | sed "s/^Title://")
    	mocp_paused=$(mocp -i | grep ^State | sed "s/^State: //")
		if [ -n "$np" -a "$mocp_paused" != "PAUSE" ]; then
        	echo "$np"
    	fi
	fi
}

# Simple np script for mpd. Works with streams!
# Only tested on OS X... should work the same way on other platforms though.
__np_mpd_simple() {
	np=$(mpc current 2>&1)
	if [ $? -eq 0 ] && [ -n "$np" ]; then
		mpc | grep "paused" > /dev/null
		if [ $? -eq 0 ]; then
			return 1
		fi
		echo "$np"
	fi
	return 1
}

__np_rdio() {
	[ ! shell_is_osx ] && return 1
	np=$(osascript ${TMUX_POWERLINE_DIR_SEGMENTS}/np_rdio_mac.script) 
	echo "$np"
}

__np_rhythmbox() {
	rhythmbox_pid=$(pidof rhythmbox)
	if [ -n "$rhythmbox_pid" ]; then
		np=$(rhythmbox-client --no-start --print-playing)		# Does not tell if the music is playing or paused.
		rhythmbox_paused=$(xwininfo -root -tree | grep "$np" | sed "s/${np}//;s/ //g" | cut -f2 -d '"')
		# TODO I cant produce the output "Not playing", using rhythmbox 2.97.
		#STATUS=$(rhythmbox-client --no-start --print-playing)
		if [[ "$rhythmbox_paused" != "(Paused)" ]]; then
			echo "$np"
		fi
	fi
}

__spotify() {
	if shell_is_linux; then
		metadata=$(dbus-send --reply-timeout=42 --print-reply --dest=org.mpris.MediaPlayer2.spotify / org.freedesktop.MediaPlayer2.GetMetadata 2>/dev/null)
		if [ "$?" -eq 0 ] && [ -n "$metadata" ]; then
			# TODO how do one express this with dbus-send? It works with qdbus but the problem is that it's probably not as common as dbus-send.
			state=$(qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player PlaybackStatus)
			if [[ $state == "Playing" ]]; then
				artist=$(echo "$metadata" | grep -PA2 "string\s\"xesam:artist\"" | tail -1 | grep -Po "(?<=\").*(?=\")")
				track=$(echo "$metadata" | grep -PA1 "string\s\"xesam:title\"" | tail -1 | grep -Po "(?<=\").*(?=\")")
				np=$(echo "${artist} - ${track}")
			fi
		fi
	elif shell_is_osx
		np=$(${TMUX_POWERLINE_DIR_SEGMENTS}/np_spotify_mac.sh)
	fi
	echo "$np"
}

__np_spotify_wine() {
	[ ! shell_is_linux ] && return 1
	spotify_id=$(xwininfo -root -tree | grep '("spotify' | cut -f1 -d'"' | sed 's/ //g')
	echo $spotify_id
	if [ -n "$spotify_id" ]; then
		np=$(xwininfo -id "$spotify_id" | grep "xwininfo.*Spotify -" | grep -Po "(?<=\"Spotify - ).*(?=\"$)")
		echo "$np"
	fi
}
