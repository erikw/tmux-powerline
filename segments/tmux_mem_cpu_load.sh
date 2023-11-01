# Print out Memory, cpu and load using https://github.com/thewtex/tmux-mem-cpu-load

run_segment() {
	stats=""
	if type $TMUX_PLUGIN_MANAGER_PATH/tmux-mem-cpu-load/tmux-mem-cpu-load > /dev/null 2>&1; then
		stats=$($TMUX_PLUGIN_MANAGER_PATH/tmux-mem-cpu-load/tmux-mem-cpu-load)
	elif type tmux-mem-cpu-load >/dev/null 2>&1; then
		stats=$(tmux-mem-cpu-load)
	else
		return
	fi

	if [ -n "$stats" ]; then
		echo "$stats";
	fi
	return 0
}
