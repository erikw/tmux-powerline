# shellcheck shell=bash
# Prints the hostname.

# shellcheck source=lib/util.sh
source "${TMUX_POWERLINE_DIR_LIB}/util.sh"

TMUX_POWERLINE_SEG_HOSTNAME_FORMAT="${TMUX_POWERLINE_SEG_HOSTNAME_FORMAT:-short}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Use short, long or custom format for the hostname. Can be {"short", "long", "custom"}.
export TMUX_POWERLINE_SEG_HOSTNAME_FORMAT="${TMUX_POWERLINE_SEG_HOSTNAME_FORMAT}"
# Custom name to be used when format is "custom"
export TMUX_POWERLINE_SEG_HOSTNAME_CUSTOM="${TMUX_POWERLINE_SEG_HOSTNAME_CUSTOM}"
EORC
	echo "$rccontents"
}

run_segment() {
	if [ "$TMUX_POWERLINE_SEG_HOSTNAME_FORMAT" == "short" ]; then
		_get_hostname short || return 1
	elif [ "$TMUX_POWERLINE_SEG_HOSTNAME_FORMAT" == "long" ]; then
		_get_hostname long || return 1
	elif [ "$TMUX_POWERLINE_SEG_HOSTNAME_FORMAT" == "custom" ]; then
		if [ -z "$TMUX_POWERLINE_SEG_HOSTNAME_CUSTOM" ]; then
			tp_err_seg "Err: TMUX_POWERLINE_SEG_HOSTNAME_CUSTOM is unset. Please set it if you want to use the custom format."
			return 1
		fi
		echo "$TMUX_POWERLINE_SEG_HOSTNAME_CUSTOM"
	else
		tp_err_seg "Err: Invalid hostname format: $TMUX_POWERLINE_SEG_HOSTNAME_FORMAT {\"short\", \"long\", \"custom\"}"
		return 1
	fi
	return 0
}

_get_hostname() {
	local format=$1
	local hname=""

	if tp_command_exists hostname; then
		hname=$(hostname)
	elif tp_command_exists hostnamectl; then
		hname=$(hostnamectl hostname)
	else
		tp_err_seg 'Err: Hostname could not be determined (neither hostname nor hostnamectl command available)'
		return 1
	fi

	if [ "$format" == "short" ]; then
		echo "${hname/.*/}"
	elif [ "$format" == "long" ]; then
		echo "${hname}"
	fi
}
