# Print out Memory and CPU using https://github.com/creaktive/rainbarf

run_segment() {
	type rainbarf >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi

	stats=$(rainbarf --tmux $TMUX_POWERLINE_SEG_RAINBARF_PARAMS)
	if [ -n "$stats" ]; then
		echo "$stats";
	fi
	return 0
}
