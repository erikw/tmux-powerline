#!/usr/bin/env bash

export TMUX_POWERLINE_DIR_HOME="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

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

export TMUX_POWERLINE_DIR_HOME="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"


source "${TMUX_POWERLINE_DIR_HOME}/config/helpers.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/paths.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/shell.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/defaults.sh"

source "${TMUX_POWERLINE_DIR_LIB}/arg_processing.sh"
source "${TMUX_POWERLINE_DIR_LIB}/formatting.sh"
source "${TMUX_POWERLINE_DIR_LIB}/muting.sh"
source "${TMUX_POWERLINE_DIR_LIB}/powerline.sh"
source "${TMUX_POWERLINE_DIR_LIB}/rcfile.sh"

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
