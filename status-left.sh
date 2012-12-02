#!/usr/bin/env bash

export TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
  'tmux_session_info'
  'hostname'
  'lan_ip'
  'wan_ip'
  'vcs_branch'
  'vcs_compare'
  'vcs_staged'
  'vcs_modified'
  'vcs_others'
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
