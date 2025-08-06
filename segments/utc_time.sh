# shellcheck shell=bash
# Prints the current time in UTC.

TMUX_POWERLINE_SEG_UTC_TIME_FORMAT="${TMUX_POWERLINE_SEG_UTC_TIME_FORMAT:-%H:%M %Z}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# date(1) format for the UTC time.
export TMUX_POWERLINE_SEG_UTC_TIME_FORMAT="${TMUX_POWERLINE_SEG_UTC_TIME_FORMAT}"
EORC
	echo "$rccontents"
}

run_segment() {
	date -u +"$TMUX_POWERLINE_SEG_UTC_TIME_FORMAT"
	return 0
}
