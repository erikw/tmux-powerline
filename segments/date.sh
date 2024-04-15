# shellcheck shell=bash
# Print the current date.

TMUX_POWERLINE_SEG_DATE_FORMAT="${TMUX_POWERLINE_SEG_DATE_FORMAT:-%F}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# date(1) format for the date. If you don't, for some reason, like ISO 8601 format you might want to have "%D" or "%m/%d/%Y".
export TMUX_POWERLINE_SEG_DATE_FORMAT="${TMUX_POWERLINE_SEG_DATE_FORMAT}"
EORC
	echo "$rccontents"
}

run_segment() {
	date +"$TMUX_POWERLINE_SEG_DATE_FORMAT"
	return 0
}
