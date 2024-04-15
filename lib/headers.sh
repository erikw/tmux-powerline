# shellcheck shell=bash
# Source all needed libs and helpers, kind of like a main.h.

if [ -z "$TMUX_POWERLINE_DIR_HOME" ]; then
	lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	TMUX_POWERLINE_DIR_HOME="$(dirname "$lib_dir")" # step up to parent dir.

	export TMUX_POWERLINE_DIR_HOME
	unset lib_dir
fi

source "${TMUX_POWERLINE_DIR_HOME}/config/helpers.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/paths.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/shell.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/defaults.sh"

# shellcheck source=lib/colors.sh
source "${TMUX_POWERLINE_DIR_LIB}/colors.sh"
# shellcheck source=lib/arg_processing.sh
source "${TMUX_POWERLINE_DIR_LIB}/arg_processing.sh"
# shellcheck source=lib/formatting.sh
source "${TMUX_POWERLINE_DIR_LIB}/formatting.sh"
# shellcheck source=lib/muting.sh
source "${TMUX_POWERLINE_DIR_LIB}/muting.sh"
# shellcheck source=lib/powerline.sh
source "${TMUX_POWERLINE_DIR_LIB}/powerline.sh"
# shellcheck source=lib/config_file.sh
source "${TMUX_POWERLINE_DIR_LIB}/config_file.sh"
