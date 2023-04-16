# Source all neede libs and helpers, kind of like a main.h.

# macOS doesn't ship with realpath.
# Bash implementation from https://stackoverflow.com/a/18443300/265508
realpath() (
  OURPWD=$PWD
  cd "$(dirname "$1")"
  LINK=$(readlink "$(basename "$1")")
  while [ "$LINK" ]; do
    cd "$(dirname "$LINK")"
    LINK=$(readlink "$(basename "$1")")
  done
  REALPATH="$PWD/$(basename "$1")"
  cd "$OURPWD"
  echo "$REALPATH"
)

if [ -z "$TMUX_POWERLINE_DIR_HOME" ]; then
	lib_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
	export TMUX_POWERLINE_DIR_HOME="$(dirname "${lib_dir}")" # step up to parent dir.
	unset lib_dir
fi

source "${TMUX_POWERLINE_DIR_HOME}/config/helpers.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/paths.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/shell.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/defaults.sh"

source "${TMUX_POWERLINE_DIR_LIB}/options.sh"
source "${TMUX_POWERLINE_DIR_LIB}/arg_processing.sh"
source "${TMUX_POWERLINE_DIR_LIB}/formatting.sh"
source "${TMUX_POWERLINE_DIR_LIB}/muting.sh"
source "${TMUX_POWERLINE_DIR_LIB}/powerline.sh"
source "${TMUX_POWERLINE_DIR_LIB}/rcfile.sh"
