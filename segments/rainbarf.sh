# shellcheck shell=bash
# Print out Memory and CPU using https://github.com/creaktive/rainbarf

run_segment() {
	if ! type rainbarf >/dev/null 2>&1; then
		echo 'rainbarf was not found'
		return
	fi

	# Customize via ~/.rainbarf.conf
	stats=$(rainbarf --tmux)
	if [ -n "$stats" ]; then
		echo "$stats"
	fi
	return 0
}
