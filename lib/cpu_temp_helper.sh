# shellcheck shell=bash

tp_cpu_temp_value() {
	local temp

	if tp_shell_is_macos; then
		temp=$(smctemp -c | bc -l)
	elif tp_shell_is_linux; then
		temp=$(sensors \
			| grep "$TMUX_POWERLINE_SEG_CPU_TEMP_SENSORS_LINE_MARKER" -m 1 \
			| sed -e 's/[^+]*+\([\s0-9\.]*\).*/\1/' | bc -l)
	fi

	tp_round "$temp" 0
}

tp_cpu_temp_at_least() {
	local threshold_temp="$1"

	echo "$(tp_cpu_temp_value) >= $threshold_temp" | bc -l
}

