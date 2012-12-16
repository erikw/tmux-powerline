# Print the current working directory (trimmed to max length).
# NOTE The trimming code's stolen from the web. Courtesy to who ever wrote it.

TMUX_POWERLINE_SEG_PWD_MAX_LEN_DEFAULT="40"

generate_segmentrc() {
	read -d '' rccontents  << EORC
# Maximum length of output.
export TMUX_POWERLINE_SEG_PWD_MAX_LEN="${TMUX_POWERLINE_SEG_PWD_MAX_LEN_DEFAULT}"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	# Truncate from the left.
	tcwd=$(get_tmux_cwd)
	trunc_symbol=".."
	dir=${tcwd##*/}
	max_len=$(( ( max_len < ${#dir} ) ? ${#dir} : max_len ))
	ttcwd=${tcwd/#$HOME/\~}
	pwdoffset=$(( ${#ttcwd} - max_len ))
	if [ ${pwdoffset} -gt "0" ]; then
		ttcwd=${ttcwd:$pwdoffset:$max_len}
		ttcwd=${trunc_symbol}/${ttcwd#*/}
	fi
	echo "$ttcwd"
	return 0
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_PWD_MAX_LEN" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER="${TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER_DEFAULT}"
	fi
}
