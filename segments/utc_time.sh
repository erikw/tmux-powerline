# Prints the current time in UTC.

TMUX_POWERLINE_SEG_UTC_TIME_FORMAT_DEFAULT="%H:%M %Z"

generate_segmentrc() {
	read -d '' rccontents  << EORC
# date(1) format for the UTC time.
export TMUX_POWERLINE_SEG_UTC_TIME_FORMAT="${TMUX_POWERLINE_SEG_UTC_TIME_FORMAT_DEFAULT}"
EORC
	echo "$rccontents"
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_UTC_TIME_FORMAT" ]; then
		export TMUX_POWERLINE_SEG_UTC_TIME_FORMAT="${TMUX_POWERLINE_SEG_UTC_TIME_FORMAT_DEFAULT}"
	fi
}

run_segment() {
	__process_settings
	date -u +"$TMUX_POWERLINE_SEG_UTC_TIME_FORMAT"
	return 0
}
