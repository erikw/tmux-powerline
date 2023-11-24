# Prints the current time.

TMUX_POWERLINE_SEG_TIME_FORMAT_DEFAULT="%H:%M"

generate_segmentrc() {
	read -d '' rccontents  << EORC
# date(1) format for the time. Americans might want to have "%I:%M %p".
export TMUX_POWERLINE_SEG_TIME_FORMAT="${TMUX_POWERLINE_SEG_TIME_FORMAT_DEFAULT}"
# Change this to display a different timezone than the system default.
# Use TZ Identifier like "America/Los_Angeles"
export TMUX_POWERLINE_SEG_TIME_TZ=""
EORC
	echo "$rccontents"
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_TIME_FORMAT" ]; then
		export TMUX_POWERLINE_SEG_TIME_FORMAT="${TMUX_POWERLINE_SEG_TIME_FORMAT_DEFAULT}"
	fi
}

run_segment() {
        __process_settings
	if [ -n "$TMUX_POWERLINE_SEG_TIME_TZ" ]; then
		TZ="$TMUX_POWERLINE_SEG_TIME_TZ" date +"$TMUX_POWERLINE_SEG_TIME_FORMAT"
	else
		date +"$TMUX_POWERLINE_SEG_TIME_FORMAT"
	fi
	return 0
}
