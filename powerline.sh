#!/usr/bin/env bash

export TMUX_POWERLINE_DIR_HOME="$(dirname $0)"

source "${TMUX_POWERLINE_DIR_HOME}/config/helpers.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/paths.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/shell.sh"

source "${TMUX_POWERLINE_DIR_HOME}/lib/arg_processing.sh"
source "${TMUX_POWERLINE_DIR_HOME}/lib/formatting.sh"
source "${TMUX_POWERLINE_DIR_HOME}/lib/muting.sh"
source "${TMUX_POWERLINE_DIR_HOME}/lib/powerline.sh"
source "${TMUX_POWERLINE_DIR_HOME}/lib/rcfile.sh"

if ! powerline_muted "$1"; then
	process_settings
	check_arg_side "$1"
	print_powerline "$1"
fi

exit 0
