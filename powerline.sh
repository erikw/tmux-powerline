#!/usr/bin/env bash

export TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
  "tmux_session_info 234 148" \
  "hostname 33 0" \
  "lan_ip 24 255" \
  "wan_ip 24 255" \
  "vcs_branch 29 88" \
  "vcs_compare 60 255" \
  "vcs_staged 64 255" \
  "vcs_modified 9 255" \
  "vcs_others 245 0" \
)

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

if ! powerline_muted $1; then
  print_powerline $1
fi

exit 0
