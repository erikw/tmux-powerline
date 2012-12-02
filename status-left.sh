#!/usr/bin/env bash

export TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
  "tmux_session_info 148 234" \
  "hostname 0 33" \
  "lan_ip 255 24" \
  "wan_ip 255 24" \
  "vcs_branch 88 29" \
  "vcs_compare 255 60" \
  "vcs_staged 255 64" \
  "vcs_modified 255 9" \
  "vcs_others 0 245" \
)

export TMUX_POWERLINE_HOME=$(dirname $0)

source "$TMUX_POWERLINE_HOME/config/default.sh"
source "$TMUX_POWERLINE_HOME/lib/muting.sh"
source "$TMUX_POWERLINE_HOME/lib/text_marquee.sh"
source "$TMUX_POWERLINE_HOME/lib/powerline.sh"

# Mute this statusbar?
mute_status_check "left"

# Print the status line in the order of registration above.
print_status_line_left

exit 0;
