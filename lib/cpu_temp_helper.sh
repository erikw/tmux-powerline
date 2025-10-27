# shellcheck shell=bash

tp_cpu_temp_value() {
	if tp_shell_is_macos; then
		smctemp -c | bc -l
	elif tp_shell_is_linux; then
		sensors \
			| grep "$TMUX_POWERLINE_SEG_CPU_TEMP_SENSORS_LINE_MARKER" -m 1 \
			| sed -e 's/[^+]*+\([\s0-9\.]*\).*/\1/' | bc -l
	fi
}

tp_cpu_temp_is_high() {
	echo "$(tp_cpu_temp_value) >= $TMUX_POWERLINE_SEG_CPU_TEMP_HIGH" | bc -l
}

