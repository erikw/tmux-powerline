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

export TMUX_POWERLINE_HOME=$(dirname $0)

source "$TMUX_POWERLINE_HOME/config/default.sh"

source "$TMUX_POWERLINE_HOME/lib/muting.sh"
source "$TMUX_POWERLINE_HOME/lib/text_marquee.sh"
source "$TMUX_POWERLINE_HOME/lib/tmux_adapter.sh"
source "$TMUX_POWERLINE_HOME/lib/formatting.sh"
source "$TMUX_POWERLINE_HOME/lib/powerline.sh"

# Mute this statusbar?
mute_status_check "left"

# Print the status line in the order of registration above.
print_powerline "left"

exit 0
