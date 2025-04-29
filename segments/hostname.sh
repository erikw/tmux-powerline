# shellcheck shell=bash
# Prints the hostname.

# shellcheck source=lib/util.sh
source "${TMUX_POWERLINE_DIR_LIB}/util.sh"

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
		if shell_is_macos || shell_is_bsd; then
			opts="-s"
		else
			opts="--short"
		fi
	fi

	if command_exists hostname; then
		hostname ${opts}
	elif command_exists hostnamectl; then
		hostnamectl hostname
	else
		echo 'Hostname could not be determined'
	fi

	return 0
}
