#!/usr/bin/env bash

export TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
  "pwd 211 89" \
  "mail_count 255 9" \
  "np_mpd 37 234" \
  "cpu 136 240" \
  "load 167 237" \
  "battery 127 137" \
  "weather_yahoo 255 37" \
  "date_day 136 235" \
  "date_full 136 235" \
  "time 136 235" \
)

export TMUX_POWERLINE_HOME=$(dirname $0)

source "$TMUX_POWERLINE_HOME/config/default.sh"
source "$TMUX_POWERLINE_HOME/lib/muting.sh"
source "$TMUX_POWERLINE_HOME/lib/text_marquee.sh"
source "$TMUX_POWERLINE_HOME/lib/tmux_adapter.sh"
source "$TMUX_POWERLINE_HOME/lib/powerline.sh"

# Mute this statusbar?
mute_status_check "right"

# Print the status line in the order of registration above.
print_status_line_right

exit 0
