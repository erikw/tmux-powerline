# Source all needed libs and helpers, kind of like a main.h.

if [ -z "$TMUX_POWERLINE_DIR_HOME" ]; then
	lib_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	TMUX_POWERLINE_DIR_HOME="$(dirname "$lib_dir")" # step up to parent dir.

	export TMUX_POWERLINE_DIR_HOME
	unset lib_dir
fi

source "${TMUX_POWERLINE_DIR_HOME}/config/helpers.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/paths.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/shell.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/defaults.sh"

source "${TMUX_POWERLINE_DIR_LIB}/colors.sh"
source "${TMUX_POWERLINE_DIR_LIB}/arg_processing.sh"
source "${TMUX_POWERLINE_DIR_LIB}/formatting.sh"
source "${TMUX_POWERLINE_DIR_LIB}/muting.sh"
source "${TMUX_POWERLINE_DIR_LIB}/powerline.sh"
source "${TMUX_POWERLINE_DIR_LIB}/rcfile.sh"
