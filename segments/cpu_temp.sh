# shellcheck shell=bash
# Prints CPU temperature
# Requirements:
#   lm_sensors (Linux only)
#   smctemp (Macos only)

TMUX_POWERLINE_SEG_CPU_TEMP_ICON_DEFAULT=" "
TMUX_POWERLINE_SEG_CPU_TEMP_SENSORS_LINE_MARKER_DEFAULT="Package id 0\|Physical id 0\|temp1"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# CPU temperature icon
export TMUX_POWERLINE_SEG_CPU_TEMP_ICON="${TMUX_POWERLINE_SEG_CPU_TEMP_ICON_DEFAULT}"
# Linux only. Regexp to indicate a line containing CPU temperature in 'sensors' output.
# Check the output of 'sensors' program, decide which line contains desired CPU temperature
# and store an unique part of that line in this variable. It will be used by 'grep' program
# to distinct the 'CPU temperature' line from the rest output lines.
export TMUX_POWERLINE_SEG_CPU_TEMP_SENSORS_LINE_MARKER="${TMUX_POWERLINE_SEG_CPU_TEMP_SENSORS_LINE_MARKER_DEFAULT}"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings

	local temp
	temp=$(tp_cpu_temp_value)

	if [ -n "$temp" ]; then
		echo "${TMUX_POWERLINE_SEG_CPU_TEMP_ICON}${temp}°"
		return 0
	else
		return 1
	fi
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_CPU_TEMP_ICON" ]; then
		export TMUX_POWERLINE_SEG_CPU_TEMP_ICON="${TMUX_POWERLINE_SEG_CPU_TEMP_ICON_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_CPU_TEMP_SENSORS_LINE_MARKER" ]; then
		export TMUX_POWERLINE_SEG_CPU_TEMP_SENSORS_LINE_MARKER="${TMUX_POWERLINE_SEG_CPU_TEMP_SENSORS_LINE_MARKER_DEFAULT}"
	fi
}
