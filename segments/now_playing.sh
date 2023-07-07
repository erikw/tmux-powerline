# Print current playing song in your music player of choice.

source "${TMUX_POWERLINE_DIR_LIB}/text_roll.sh"

TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN_DEFAULT="40"
TMUX_POWERLINE_SEG_NOW_PLAYING_TRIM_METHOD_DEFAULT="trim"
TMUX_POWERLINE_SEG_NOW_PLAYING_ROLL_SPEED_DEFAULT="2"
TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_HOST_DEFAULT="localhost"
TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_PORT_DEFAULT="6600"
TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_UPDATE_PERIOD_DEFAULT="30"
TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_SIMPLE_FORMAT_DEFAULT="%artist% - %title%"
TMUX_POWERLINE_SEG_NOW_PLAYING_PLAYERCTL_FORMAT_DEFAULT="{{ artist }} - {{ title }}"
TMUX_POWERLINE_SEG_NOW_PLAYING_RHYTHMBOX_FORMAT_DEFAULT="%aa - %tt"
TMUX_POWERLINE_SEG_NOW_PLAYING_NOTE_CHAR_DEFAULT="♫"
TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER_DEFAULT="spotify"

generate_segmentrc() {
	read -d '' rccontents  << EORC
# Music player to use. Can be any of {audacious, banshee, cmus, itunes, lastfm, mocp, mpd, mpd_simple, pithos, playerctl, rdio, rhythmbox, spotify, spotify_wine, file}.
export TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER="${TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER_DEFAULT}"
# File to be read in case the song is being read from a file
export TMUX_POWERLINE_SEG_NOW_PLAYING_FILE_NAME=""
# Maximum output length.
export TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN="${TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN_DEFAULT}"
# How to handle too long strings. Can be {trim, roll}.
export TMUX_POWERLINE_SEG_NOW_PLAYING_TRIM_METHOD="${TMUX_POWERLINE_SEG_NOW_PLAYING_TRIM_METHOD_DEFAULT}"
# Charcters per second to roll if rolling trim method is used.
export TMUX_POWERLINE_SEG_NOW_PLAYING_ROLL_SPEED="${TMUX_POWERLINE_SEG_NOW_PLAYING_ROLL_SPEED_DEFAULT}"

# Hostname for MPD server in the format "[password@]host"
export TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_HOST="${TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_HOST_DEFAULT}"
# Port the MPD server is running on.
export TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_PORT="${TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_PORT_DEFAULT}"
# Song display format for mpd_simple. See mpc(1) for delimiters.
export TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_SIMPLE_FORMAT="${TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_SIMPLE_FORMAT_DEFAULT}"
# Song display format for playerctl. see "Format Strings" in playerctl(1).
export TMUX_POWERLINE_SEG_NOW_PLAYING_PLAYERCTL_FORMAT="${TMUX_POWERLINE_SEG_NOW_PLAYING_PLAYERCTL_FORMAT_DEFAULT}"
# Song display format for rhythmbox. see "FORMATS" in rhythmbox-client(1).
export TMUX_POWERLINE_SEG_NOW_PLAYING_RHYTHMBOX_FORMAT="${TMUX_POWERLINE_SEG_NOW_PLAYING_RHYTHMBOX_FORMAT_DEFAULT}"

# Last.fm
# Set up steps for Last.fm
# 1. Make sure jq(1) is installed on the system.
# 2. Create a new API application at https://www.last.fm/api/account/create (name it tmux-powerline) and copy the API key and insert it below in the setting TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_API_KEY
# 3. Make sure the API can access your recently played song by going to you user privacy settings https://www.last.fm/settings/privacy and make sure "Hide recent listening information" is UNCHECKED.
# Username for Last.fm if that music player is used.
export TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_USERNAME=""
# API Key for the API.
export TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_API_KEY=""
# How often in seconds to update the data from last.fm.
export TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_UPDATE_PERIOD_DEFAULT}"
# Fancy char to display before now playing track
export TMUX_POWERLINE_SEG_NOW_PLAYING_NOTE_CHAR="${TMUX_POWERLINE_SEG_NOW_PLAYING_NOTE_CHAR_DEFAULT}"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings

	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER" ]; then
		return 1
	fi

	local np
	local app_exit
	IFS=',' read -ra PLAYERS <<< "$TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER"
	for i in "${PLAYERS[@]}"; do
		case "$i" in
			"audacious")  np=$(__np_audacious) ;;
			"banshee")  np=$(__np_banshee) ;;
			"cmus")  np=$(__np_cmus) ;;
			"itunes")  np=$(__np_itunes) ;;
			"lastfm")  np=$(__np_lastfm) ;;
			"mocp")  np=$(__np_mocp) ;;
			"mpd")  np=$(__np_mpd) ;;
			"mpd_simple")  np=$(__np_mpd_simple) ;;
			"pithos") np=$(__np_pithos) ;;
			"rdio")  np=$(__np_rdio) ;;
			"playerctl")  np=$(__np_playerctl) ;;
			"rhythmbox")  np=$(__np_rhythmbox) ;;
			"spotify")  np=$(__np_spotify) ;;
			"file")  np=$(__np_file) ;;
			"spotify_wine")  np=$(__np_spotify_native) ;;
			*)
				echo "Unknown music player type [${TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER}]";
				return 1
		esac
		app_exit="$?"
		[ -n "$np" ] && break
	done

	local exitcode="$app_exit"
	if [ "${exitcode}" -ne 0 ]; then
		return ${exitcode}
	fi
	if [ -n "$np" ]; then
		case "$TMUX_POWERLINE_SEG_NOW_PLAYING_TRIM_METHOD" in
			"roll")
				np=$(roll_text "${np}" ${TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN} ${TMUX_POWERLINE_SEG_NOW_PLAYING_ROLL_SPEED_DEFAULT})
				;;
			"trim")
				np=${np:0:TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN}
				;;
		esac
		echo "${TMUX_POWERLINE_SEG_NOW_PLAYING_NOTE_CHAR} ${np}"
	fi
	return 0
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER="${TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN="${TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_TRIM_METHOD" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_TRIM_METHOD="${TMUX_POWERLINE_SEG_NOW_PLAYING_TRIM_METHOD_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_ROLL_SPEED" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_ROLL_SPEED="${TMUX_POWERLINE_SEG_NOW_PLAYING_ROLL_SPEED_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_HOST" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_HOST="${TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_HOST_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_PORT" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_PORT="${TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_PORT_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_SIMPLE_FORMAT" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_SIMPLE_FORMAT="${TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_SIMPLE_FORMAT_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_UPDATE_PERIOD" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_UPDATE_PERIOD_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_NOTE_CHAR" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_NOTE_CHAR="${TMUX_POWERLINE_SEG_NOW_PLAYING_NOTE_CHAR_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_PLAYERCTL_FORMAT" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_PLAYERCTL_FORMAT="${TMUX_POWERLINE_SEG_NOW_PLAYING_PLAYERCTL_FORMAT_DEFAULT}"
	fi;
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_RHYTHMBOX_FORMAT" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_RHYTHMBOX_FORMAT="${TMUX_POWERLINE_SEG_NOW_PLAYING_RHYTHMBOX_FORMAT_DEFAULT}"
	fi;
}

__np_mpd() {
	cd "$TMUX_POWERLINE_DIR_SEGMENTS"

	if [ ! -x "np_mpd" ]; then
		make clean np_mpd &>/dev/null
	fi

	if [ ! -x "np_mpd" ]; then
		return 2
	fi

	np=$(MPD_HOST="$TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_HOST" MPD_PORT="$TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_PORT" ./np_mpd)
	echo "$np"
}

__np_file() {
	np=$(cat $TMUX_POWERLINE_SEG_NOW_PLAYING_FILE_NAME | tr '\n' '|')
	echo "$np"
}


__np_mpd_simple() {
	np=$(MPD_HOST="$TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_HOST" MPD_PORT="$TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_PORT" mpc current -f "$TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_SIMPLE_FORMAT" 2>&1)
	if [ $? -eq 0 ] && [ -n "$np" ]; then
		mpc | grep "paused" > /dev/null
		if [ $? -eq 0 ]; then
			return 1
		fi
		echo "$np"
	fi
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
	#cmus-remote returns EXIT_FAILURE/EXIT_SUCCESS depending on whether or not cmus is running.
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
	np=$(${TMUX_POWERLINE_DIR_SEGMENTS}/np_itunes.script)
	echo "$np"
}

__np_lastfm() {
	local TMP_FILE="${TMUX_POWERLINE_DIR_TEMPORARY}/np_lastfm.txt"
	# API docs: https://www.last.fm/api/show/user.getRecentTracks
	local ENDPOINT_FMT="http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&format=json&limit=1&user=%s&api_key=%s"

	if [ -f "$TMP_FILE" ]; then
		if shell_is_osx || shell_is_bsd; then
			last_update=$(stat -f "%m" ${TMP_FILE})
		elif shell_is_linux; then
			last_update=$(stat -c "%Y" ${TMP_FILE})
		fi
		time_now=$(date +%s)

		up_to_date=$(echo "(${time_now}-${last_update}) < ${TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_UPDATE_PERIOD}" | bc)
		if [ "$up_to_date" -eq 1 ]; then
			np=$(cat ${TMP_FILE})
		fi
	fi

	if [ -z "$np" ]; then
		local url=$(printf $ENDPOINT_FMT $TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_USERNAME $TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_API_KEY)
		np=$(curl --silent "$url" | jq --raw-output '.recenttracks.track[0] | "\(.artist."#text") - \(.name)"')
		if [ "$?" -eq "0" ] && [ -n "$np" ]; then
			echo "${np}" > $TMP_FILE
		fi
	fi
	echo "$np"
}

__np_pithos() {
	if [ "$(dbus-send --reply-timeout=10 --print-reply --dest=net.kevinmehall.Pithos /net/kevinmehall/Pithos net.kevinmehall.Pithos.IsPlaying 2>/dev/null | grep boolean | cut -d' ' -f5)" == "true" ]; then
		np=$(${TMUX_POWERLINE_DIR_SEGMENTS}/np_pithos.py)
		echo "$np"
	fi
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

__np_rdio() {
	[ ! shell_is_osx ] && return 1
	np=$(osascript ${TMUX_POWERLINE_DIR_SEGMENTS}/np_rdio_mac.script)
	echo "$np"
}

__np_rhythmbox() {
	rhythmbox_pid=$(pidof rhythmbox)
	if [ -n "$rhythmbox_pid" ]; then
		np=$(rhythmbox-client --no-start --print-playing-format="$TMUX_POWERLINE_SEG_NOW_PLAYING_RHYTHMBOX_FORMAT")
		rhythmbox_paused=$(xwininfo -root -tree | grep "$np" | sed "s/${np}//;s/ //g" | cut -f2 -d '"')
		# TODO I cant produce the output "Not playing", using rhythmbox 2.97.
		#STATUS=$(rhythmbox-client --no-start --print-playing)
		if [[ "$rhythmbox_paused" != "(Paused)" ]]; then
			echo "$np"
		fi
	fi
}

__np_playerctl() {
	if [ "$(playerctl status)" = "Playing" ]; then
		np=$(playerctl metadata --format="$TMUX_POWERLINE_SEG_NOW_PLAYING_PLAYERCTL_FORMAT")
		echo "$np"
	fi
}

__np_spotify() {
	if shell_is_linux; then
		if type tasklist.exe >/dev/null 2>&1; then # WSL
			np=$(tasklist.exe /fo list /v /fi "IMAGENAME eq Spotify.exe" | grep " - "  | cut -d" " -f3-)
			np="${np//[$'\t\r\n']}"
		else
			metadata=$(dbus-send --reply-timeout=42 --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' 2>/dev/null)
			if [ "$?" -eq 0 ] && [ -n "$metadata" ]; then
				state=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'PlaybackStatus'|grep -E -A 1 "string"|cut -b 26-|cut -d '"' -f 1|grep -E -v ^$)
				if [[ $state == "Playing" ]]; then
					artist=$(echo "$metadata" | grep -PA2 "string\s\"xesam:artist\"" | tail -1 | grep -Po "(?<=\").*(?=\")")
					track=$(echo "$metadata" | grep -PA1 "string\s\"xesam:title\"" | tail -1 | grep -Po "(?<=\").*(?=\")")
					np=$(echo "${artist} - ${track}")
				fi
			fi
		fi
	elif shell_is_osx; then
		np=$(${TMUX_POWERLINE_DIR_SEGMENTS}/np_spotify_mac.script)
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
