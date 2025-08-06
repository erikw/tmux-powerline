# shellcheck shell=bash
# Prints tmux session info.
# Assumes that [ -n "$TMUX"].

TMUX_POWERLINE_SEG_TMUX_SESSION_INFO_FORMAT="${TMUX_POWERLINE_SEG_TMUX_SESSION_INFO_FORMAT:-#S:#I.#P}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Session info format to feed into the command: tmux display-message -p
# For example, if FORMAT is '[ #S ]', the command is: tmux display-message -p '[ #S ]'
export TMUX_POWERLINE_SEG_TMUX_SESSION_INFO_FORMAT="${TMUX_POWERLINE_SEG_TMUX_SESSION_INFO_FORMAT}"
EORC
	echo "$rccontents"
}

run_segment() {
	echo "${TMUX_POWERLINE_SEG_TMUX_SESSION_INFO_FORMAT}"
	return 0
}
