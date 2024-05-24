# shellcheck shell=bash
# Prints the hostname.

TMUX_POWERLINE_SEG_HOSTNAME_FORMAT="${TMUX_POWERLINE_SEG_HOSTNAME_FORMAT:-short}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Use short or long format for the hostname. Can be {"short, long"}.
export TMUX_POWERLINE_SEG_HOSTNAME_FORMAT="${TMUX_POWERLINE_SEG_HOSTNAME_FORMAT}"
EORC
	echo "$rccontents"
}

run_segment() {
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
