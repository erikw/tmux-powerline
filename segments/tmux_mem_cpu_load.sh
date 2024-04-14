# shellcheck shell=bash
# Print out Memory, cpu and load using https://github.com/thewtex/tmux-mem-cpu-load

TMUX_POWERLINE_SEG_TMUX_MEM_CPU_LOAD_ARGS="${TMUX_POWERLINE_SEG_TMUX_MEM_CPU_LOAD_ARGS:--v}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Arguments passed to tmux-mem-cpu-load.
# See https://github.com/thewtex/tmux-mem-cpu-load for all available options.
# export TMUX_POWERLINE_SEG_TMUX_MEM_CPU_LOAD_ARGS="${TMUX_POWERLINE_SEG_TMUX_MEM_CPU_LOAD_ARGS}"
EORC
	echo "$rccontents"
}

run_segment() {
	read -r -a args <<<"$TMUX_POWERLINE_SEG_TMUX_MEM_CPU_LOAD_ARGS"
	stats=""
	if type "$TMUX_PLUGIN_MANAGER_PATH/tmux-mem-cpu-load/tmux-mem-cpu-load" >/dev/null 2>&1; then
		stats=$("$TMUX_PLUGIN_MANAGER_PATH/tmux-mem-cpu-load/tmux-mem-cpu-load" "${args[@]}")
	elif type tmux-mem-cpu-load >/dev/null 2>&1; then
		stats=$(tmux-mem-cpu-load "${args[@]}")
	else
		return
	fi

	if [ -n "$stats" ]; then
		echo "$stats"
	fi
	return 0
}
