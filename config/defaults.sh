# shellcheck shell=bash
# Default values for non segment configuration options.

export TMUX_POWERLINE_DEBUG_MODE_ENABLED_DEFAULT="false"
export TMUX_POWERLINE_PATCHED_FONT_IN_USE_DEFAULT="true"
export TMUX_POWERLINE_THEME_DEFAULT="default"

export TMUX_POWERLINE_STATUS_VISIBILITY_DEFAULT="on"
export TMUX_POWERLINE_WINDOW_STATUS_LINE=0
export TMUX_POWERLINE_STATUS_INTERVAL_DEFAULT=1
export TMUX_POWERLINE_STATUS_JUSTIFICATION_DEFAULT="centre"

export TMUX_POWERLINE_STATUS_LEFT_LENGTH_DEFAULT=60
export TMUX_POWERLINE_STATUS_RIGHT_LENGTH_DEFAULT=90

export TMUX_POWERLINE_WINDOW_STATUS_SEPARATOR_DEFAULT=""

export TMUX_POWERLINE_MUTE_LEFT_KEYBINDING_DEFAULT=
export TMUX_POWERLINE_MUTE_RIGHT_KEYBINDING_DEFAULT=

# default tmux status-format, retrieve with:
#  tmux set-option -gu status-format
#  tmux show-option -g status-format
export TMUX_POWERLINE_STATUS_FORMAT_WINDOW_DEFAULT="#[list=on align=#{status-justify}]#[list=left-marker]<#[list=right-marker]>#[list=on]#{W:#[range=window|#{window_index} #{E:window-status-style}#{?#{&&:#{window_last_flag},#{!=:#{E:window-status-last-style},default}}, #{E:window-status-last-style},}#{?#{&&:#{window_bell_flag},#{!=:#{E:window-status-bell-style},default}}, #{E:window-status-bell-style},#{?#{&&:#{||:#{window_activity_flag},#{window_silence_flag}},#{!=:#{E:window-status-activity-style},default}}, #{E:window-status-activity-style},}}]#[push-default]#{T:window-status-format}#[pop-default]#[norange default]#{?window_end_flag,,#{window-status-separator}},#[range=window|#{window_index} list=focus #{?#{!=:#{E:window-status-current-style},default},#{E:window-status-current-style},#{E:window-status-style}}#{?#{&&:#{window_last_flag},#{!=:#{E:window-status-last-style},default}}, #{E:window-status-last-style},}#{?#{&&:#{window_bell_flag},#{!=:#{E:window-status-bell-style},default}}, #{E:window-status-bell-style},#{?#{&&:#{||:#{window_activity_flag},#{window_silence_flag}},#{!=:#{E:window-status-activity-style},default}}, #{E:window-status-activity-style},}}]#[push-default]#{T:window-status-current-format}#[pop-default]#[norange list=on default]#{?window_end_flag,,#{window-status-separator}}}"
export TMUX_POWERLINE_STATUS_FORMAT_LEFT_DEFAULT="#[align=left range=left #{E:status-left-style}]#[push-default]#{T;=/#{status-left-length}:status-left}#[pop-default]#[norange default]"
export TMUX_POWERLINE_STATUS_FORMAT_RIGHT_DEFAULT="#[nolist align=right range=right #{E:status-right-style}]#[push-default]#{T;=/#{status-right-length}:status-right}#[pop-default]#[norange default]"
