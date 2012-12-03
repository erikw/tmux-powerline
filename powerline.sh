#!/usr/bin/env bash

export TMUX_POWERLINE_HOME="$(dirname $0)"

source "$TMUX_POWERLINE_HOME/config/default.sh"
source "$TMUX_POWERLINE_HOME/config/paths.sh"
source "$TMUX_POWERLINE_HOME/config/shell.sh"

source "$TMUX_POWERLINE_HOME/themes/default.sh"

source "$TMUX_POWERLINE_HOME/lib/muting.sh"
source "$TMUX_POWERLINE_HOME/lib/text_marquee.sh"
source "$TMUX_POWERLINE_HOME/lib/tmux_adapter.sh"
source "$TMUX_POWERLINE_HOME/lib/formatting.sh"
source "$TMUX_POWERLINE_HOME/lib/powerline.sh"

if ! powerline_muted $1; then
  print_powerline $1
fi

exit 0
