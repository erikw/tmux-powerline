#!/usr/bin/env bash

export TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
  "pwd 234 255" \
  "mail_count 33 255" \
  "np_mpd 234 37" \
  "cpu 24 255" \
  "load 29 255" \
  "battery 60 255" \
  "weather_yahoo 37 255" \
  "date_day 9 255" \
  "date_full 37 255" \
  "time 235 255" \
)

export TMUX_POWERLINE_HOME=$(dirname $0)

source "$TMUX_POWERLINE_HOME/config/default.sh"

source "$TMUX_POWERLINE_HOME/lib/muting.sh"
source "$TMUX_POWERLINE_HOME/lib/text_marquee.sh"
source "$TMUX_POWERLINE_HOME/lib/tmux_adapter.sh"
source "$TMUX_POWERLINE_HOME/lib/formatting.sh"
source "$TMUX_POWERLINE_HOME/lib/powerline.sh"

# Mute this statusbar?
mute_status_check "right"

# Print the status line in the order of registration above.
print_powerline "right"

exit 0
