#!/usr/bin/env bash

export TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
  'pwd'
  'mail_count'
  'np_mpd'
  'cpu'
  'load'
  'battery'
  'weather_yahoo'
  'date_day'
  'date_full'
  'time'
)

export TMUX_POWERLINE_HOME=$(dirname $0)

source "$TMUX_POWERLINE_HOME/config/default.sh"
source "$TMUX_POWERLINE_HOME/lib/muting.sh"
source "$TMUX_POWERLINE_HOME/lib/powerline.sh"

# Mute this statusbar?
mute_status_check "right"

# Print the status line in the order of registration above.
print_status_line_right

exit 0
