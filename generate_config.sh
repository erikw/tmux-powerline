#!/usr/bin/env bash
# Generate default config file.

TMUX_POWERLINE_DIR_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TMUX_POWERLINE_DIR_HOME

source "${TMUX_POWERLINE_DIR_HOME}/config/paths.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/defaults.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/shell.sh"
# shellcheck source=lib/config_file.sh
source "${TMUX_POWERLINE_DIR_LIB}/config_file.sh"

generate_default_config

exit 0
