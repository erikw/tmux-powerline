#!/usr/bin/env bash

TMUX_POWERLINE_DIR_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TMUX_POWERLINE_DIR_HOME

source "${TMUX_POWERLINE_DIR_HOME}/config/paths.sh"
# shellcheck source=lib/muting.sh
source "${TMUX_POWERLINE_DIR_LIB}/muting.sh"
# shellcheck source=lib/arg_processing.sh
source "${TMUX_POWERLINE_DIR_LIB}/arg_processing.sh"

side="$1"
check_arg_segment "$side"
toggle_powerline_mute_status "$side"
