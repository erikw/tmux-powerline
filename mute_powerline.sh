#!/usr/bin/env bash

export TMUX_POWERLINE_DIR_HOME="$(dirname $0)"
source "${TMUX_POWERLINE_DIR_HOME}/config/paths.sh"
source "${TMUX_POWERLINE_DIR_LIB}/muting.sh"
source "${TMUX_POWERLINE_DIR_LIB}/arg_processing.sh"

side="$1"
check_arg_side "$side"
toggle_powerline_mute_status "$side"
