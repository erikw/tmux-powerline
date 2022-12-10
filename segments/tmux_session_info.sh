# Prints tmux session info.
# Assumes that [ -n "$TMUX"].

TMUX_POWERLINE_SEG_TMUX_SESSION_INFO_FORMAT_DEFAULT='#S:#I.#P'

generate_segmentrc() {
	read -d '' rccontents  << EORC
# Session info format to feed into the command: tmux display-message -p
# For example, if FORMAT is '[ #S ]', the command is: tmux display-message -p '[ #S ]'
export TMUX_POWERLINE_SEG_TMUX_SESSION_INFO_FORMAT="${TMUX_POWERLINE_SEG_TMUX_SESSION_INFO_FORMAT_DEFAULT}"
EORC
	echo "$rccontents"
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_TMUX_SESSION_INFO_FORMAT" ]; then
		export TMUX_POWERLINE_SEG_TMUX_SESSION_INFO_FORMAT="${TMUX_POWERLINE_SEG_TMUX_SESSION_INFO_FORMAT_DEFAULT}"
	fi
}

run_segment() {
	__process_settings
	tmux display-message -p "$TMUX_POWERLINE_SEG_TMUX_SESSION_INFO_FORMAT"
	return 0
}
