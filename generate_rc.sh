#!/usr/bin/env bash
# Generate default rc file.

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

source "${TMUX_POWERLINE_DIR_HOME}/config/paths.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/defaults.sh"
source "${TMUX_POWERLINE_DIR_HOME}/config/shell.sh"
source "${TMUX_POWERLINE_DIR_LIB}/rcfile.sh"

generate_default_rc

exit 0
