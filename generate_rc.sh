#!/usr/bin/env bash
# Generate default rc file.

export TMUX_POWERLINE_DIR_HOME="$(dirname $0)"
source "${TMUX_POWERLINE_DIR_HOME}/config/paths.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/defaults.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/shell.sh"
source "${TMUX_POWERLINE_DIR_LIB}/rcfile.sh"

generate_default_rc

exit 0
