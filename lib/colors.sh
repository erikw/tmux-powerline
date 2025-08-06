# shellcheck shell=bash
# Utilities for working with colors
#
# Dependencies:
#		- none

# shellcheck source=lib/util.sh
source "${TMUX_POWERLINE_DIR_LIB}/util.sh"

#######################################
# Accepts a single argument containing a color, returning a normalized color based
# on the input
#
# If an integer between 1 and 3 characters long is provided, returns `colour[$1]`
# otherwise returns the input unaltered
#
# Arguments:
#   $1: The color to normalize
#######################################
__normalize_color() {
	local input="$1"
	local result

	case "$input" in
	[0-9] | [0-9][0-9] | [0-9][0-9][0-9]) # handle 1 to 3 digits
		result="colour$input"
		;;
	*) # Catch-all
		result=$input
		;;
	esac

	echo -n "$result"
}

# deprecated, function will be removed in future release, use tp_air_color instead
air_color(){
	tp_err "lib/colors.sh" "Deprecated function \"air_color\" will be removed in future release, update your theme and use \"tp_air_color\" instead"
	tp_air_color "$@"
}

tp_air_color() {
	TMUX_POWERLINE_DIR_TEMPORARY="/tmp/tmux-powerline_${USER}"
	air_temp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/temp_air_file.txt"

	if [ -n "$air_temp_file" ] && [ -f "$air_temp_file" ]; then
		TMUX_POWERLINE_SEG_AIR_COLOR=$(awk '{print $NF}' "$air_temp_file")
	fi

	echo "${TMUX_POWERLINE_SEG_AIR_COLOR:-'37'}"
}
