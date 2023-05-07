#!/usr/bin/env bash

export TMUX_POWERLINE_DIR_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${TMUX_POWERLINE_DIR_HOME}/lib/headers.sh"

if ! powerline_muted "$1"; then
	process_settings
	check_arg_side "$1"
	if [ $1 == "init" ]; then
		init_powerline
	else
		print_powerline "$1"
	fi
fi

exit 0
