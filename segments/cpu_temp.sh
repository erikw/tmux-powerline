# shellcheck shell=bash
# Prints CPU temperature
# Requirements:
#   lm_sensors (Linux only)
#   smctemp (Macos only)

TMUX_POWERLINE_SEG_CPU_TEMP_ICON="${TMUX_POWERLINE_SEG_CPU_TEMP_ICON:- }"
TMUX_POWERLINE_SEG_CPU_TEMP_SENSORS_LINE_MARKER="${TMUX_POWERLINE_SEG_CPU_TEMP_SENSORS_LINE_MARKER:-Package id 0\|Physical id 0\|temp1}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# CPU temperature icon
export TMUX_POWERLINE_SEG_CPU_TEMP_ICON="${TMUX_POWERLINE_SEG_CPU_TEMP_ICON}"
# Regexp to indicate a line containing CPU temperature in sensors output
export TMUX_POWERLINE_SEG_CPU_TEMP_SENSORS_LINE_MARKER="${TMUX_POWERLINE_SEG_CPU_TEMP_SENSORS_LINE_MARKER}"
EORC
	echo "$rccontents"
}

run_segment() {
	local temp
	temp=$(tp_cpu_temp_value)

	if [ -n "$temp" ]; then
		echo "${TMUX_POWERLINE_SEG_CPU_TEMP_ICON}${temp}°"
		return 0
	else
		return 1
	fi
}

