# Muting Logic
# In all cases $1 is the side to be muted (eg left/right).

powerline_muted() {
	[ -e "$(__powerline_mute_file $1)" ];
}

toggle_powerline_mute_status() {
	if powerline_muted $1; then
		rm "$(__powerline_mute_file $1)"
	else
		touch "$(__powerline_mute_file $1)"
	fi
}

__powerline_mute_file() {
	local tmux_session=$(tmux display -p "#S")

	echo -n "${TMUX_POWERLINE_DIR_TEMPORARY}/mute_${tmux_session}_$1"
}
