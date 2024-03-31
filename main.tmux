#!/usr/bin/env bash
# Entry point for this TPM plugin.

set -o errexit
set -o pipefail

export TMUX_POWERLINE_DIR_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Obtain the left/right status length settings by reading the tmux-powerline config.
source "${TMUX_POWERLINE_DIR_HOME}/lib/headers.sh"
process_settings

# Configure tmux to use tmux-powerline.
# It's assumed that this will override these setting if already set in tmux.conf, as TPM is recommended to be loaded last in the tmux.conf. Ref: https://github.com/tmux-plugins/tpm
tmux set-option -g status "$TMUX_POWERLINE_STATUS_VISIBILITY"
tmux set-option -g status-interval "$TMUX_POWERLINE_STATUS_INTERVAL"
tmux set-option -g status-justify "$TMUX_POWERLINE_STATUS_JUSTIFICATION"
tmux set-option -g status-style "$TMUX_POWERLINE_STATUS_STYLE"
tmux set-option -g message-style "$TMUX_POWERLINE_STATUS_STYLE"

tmux set-option -g status-left-length $TMUX_POWERLINE_STATUS_LEFT_LENGTH
tmux set-option -g status-right-length $TMUX_POWERLINE_STATUS_RIGHT_LENGTH

if [ "$TMUX_POWERLINE_STATUS_VISIBILITY" = "on" ]; then
	tmux set-option -g  status-format[0] "#[align=left]#(${TMUX_POWERLINE_DIR_HOME}/powerline.sh left)"
	tmux set-option -ag status-format[0] "#[align=centre]#{W:#{E:window-status-format} ,#{E:window-status-current-format} }"
	tmux set-option -ag status-format[0] "#[align=right]#(${TMUX_POWERLINE_DIR_HOME}/powerline.sh right)"
elif [ "$TMUX_POWERLINE_STATUS_VISIBILITY" = "2" ]; then
	# handle TMUX_POWERLINE_WINDOW_STATUS_LINE=0 and fallback for misconfiguration
	if [ "$TMUX_POWERLINE_WINDOW_STATUS_LINE" != "1" ]; then
		window_status=0
		left_right_status=1
	else
		window_status=1
		left_right_status=0
	fi
	tmux set-option -g  status-format[$window_status] "#[align=centre]#{W:#{E:window-status-format} ,#{E:window-status-current-format} }"
	tmux set-option -g  status-format[$left_right_status] "#[align=left]#(${TMUX_POWERLINE_DIR_HOME}/powerline.sh left)"
	tmux set-option -ag status-format[$left_right_status] "#[align=right]#(${TMUX_POWERLINE_DIR_HOME}/powerline.sh right)"
fi

tmux set-option -g window-status-current-format "#(${TMUX_POWERLINE_DIR_HOME}/powerline.sh window-current-format)"
tmux set-option -g window-status-format "#(${TMUX_POWERLINE_DIR_HOME}/powerline.sh window-format)"
tmux set-option -g window-status-separator "$TMUX_POWERLINE_WINDOW_STATUS_SEPARATOR"

if [ -n "$TMUX_POWERLINE_MUTE_LEFT_KEYBINDING" ]; then
	tmux bind "$TMUX_POWERLINE_MUTE_LEFT_KEYBINDING" run "$TMUX_POWERLINE_DIR_HOME/mute_powerline.sh left"
fi

if [ -n "$TMUX_POWERLINE_MUTE_RIGHT_KEYBINDING" ]; then
	tmux bind "$TMUX_POWERLINE_MUTE_RIGHT_KEYBINDING" run "$TMUX_POWERLINE_DIR_HOME/mute_powerline.sh right"
fi
