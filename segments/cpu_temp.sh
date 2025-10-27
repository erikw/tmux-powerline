# shellcheck shell=bash
# Prints CPU temperature
# Requirements:
#   lm_sensors (Linux only)
#   smctemp (Macos only)

source "$TMUX_POWERLINE_DIR_LIB/cpu_temp_helper.sh"

TMUX_POWERLINE_SEG_CPU_TEMP_HIGH=${TMUX_POWERLINE_SEG_CPU_TEMP_HIGH:-60}
TMUX_POWERLINE_SEG_CPU_TEMP_ICON="${TMUX_POWERLINE_SEG_CPU_TEMP_ICON:- }"
TMUX_POWERLINE_SEG_CPU_TEMP_SENSORS_LINE_MARKER="${TMUX_POWERLINE_SEG_CPU_TEMP_SENSORS_LINE_MARKER:-Package id 0\|Physical id 0\|temp1}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# The minimum temperature considered "high" by tp_cpu_temp_is_high function
export TMUX_POWERLINE_SEG_CPU_TEMP_HIGH=${TMUX_POWERLINE_SEG_CPU_TEMP_HIGH}
# CPU temperature icon
export TMUX_POWERLINE_SEG_CPU_TEMP_ICON="${TMUX_POWERLINE_SEG_CPU_TEMP_ICON}"
# Regexp to indicate a line containing CPU temperature in sensors output
export TMUX_POWERLINE_SEG_CPU_TEMP_SENSORS_LINE_MARKER="${TMUX_POWERLINE_SEG_CPU_TEMP_SENSORS_LINE_MARKER}"
EORC
	echo "$rccontents"
}

run_segment() {
	local temp=$(tp_cpu_temp_value)

	if [ -n "$temp" ]; then
		echo "${TMUX_POWERLINE_SEG_CPU_TEMP_ICON}${temp}°"
		return 0
	else
		return 1
	fi
}

