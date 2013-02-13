# Prints the hostname.

TMUX_POWERLINE_SEG_HOSTNAME_FORMAT_DEFAULT="short"

generate_segmentrc() {
	read -d '' rccontents  << EORC
# Use short or long format for the hostname. Can be {"short, long"}.
export TMUX_POWERLINE_SEG_HOSTNAME_FORMAT="${TMUX_POWERLINE_SEG_HOSTNAME_FORMAT_DEFAULT}"
EORC
	echo "$rccontents"
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_HOSTNAME_FORMAT" ]; then
		export TMUX_POWERLINE_SEG_HOSTNAME_FORMAT="${TMUX_POWERLINE_SEG_HOSTNAME_FORMAT_DEFAULT}"
	fi
}
run_segment() {
	__process_settings
	local opts=""
	if [ "$TMUX_POWERLINE_SEG_HOSTNAME_FORMAT" == "short" ]; then
		if shell_is_osx || shell_is_bsd; then
			opts="-s"
		else
			opts="--short"
		fi
	fi

	hostname ${opts}
	return 0
}
