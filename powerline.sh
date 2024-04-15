#!/usr/bin/env bash

TMUX_POWERLINE_DIR_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TMUX_POWERLINE_DIR_HOME

# shellcheck source=lib/headers.sh
source "${TMUX_POWERLINE_DIR_HOME}/lib/headers.sh"

if ! powerline_muted "$1"; then
	process_settings
	check_arg_segment "$1"
	if [ "$1" == "window-current-format" ]; then
		print_powerline_window_status_current_format
	elif [ "$1" == "window-format" ]; then
		print_powerline_window_status_format
	else
		print_powerline_side "$1"
	fi
fi

exit 0
