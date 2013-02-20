# Prints the current time.

TMUX_POWERLINE_SEG_TIME_FORMAT_DEFAULT="%H:%M"

generate_segmentrc() {
	read -d '' rccontents  << EORC
# date(1) format for the time. Americans might want to have "%I:%M %p".
export TMUX_POWERLINE_SEG_TIME_FORMAT="${TMUX_POWERLINE_SEG_TIME_FORMAT_DEFAULT}"
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
	date +"$TMUX_POWERLINE_SEG_TIME_FORMAT"
	return 0
}
