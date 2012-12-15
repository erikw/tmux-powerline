# Read user rc file.
# TODO functions for generating default rcfile from all segments to stdout (or ${TMUX_POWERLINE_RCFILE}.defult).

process_settings() {
	__read_rcfile

	if [ -z "$TMUX_POWERLINE_THEME" ]; then
		TMUX_POWERLINE_THEME="default"
	fi
	source "${TMUX_POWERLINE_THEMES_DIRECTORY}/${TMUX_POWERLINE_THEME}.sh"

}

__read_rcfile() {
	if [ !  -f "$TMUX_POWERLINE_RCFILE" ]; then
		source "$TMUX_POWERLINE_RCFILE"
	fi
}
