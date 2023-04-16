#!/bin/bash

# get_binding(user_bind, fallback_bind) -> bind_to_use
get_binding() {
	local option_value
	option_value=$(tmux show-option -gqv "$1")
	if [ -z "$option_value" ]; then
		local key="$2"
	else
		local key="$option_value"
	fi
	echo "$key"
}

tmux bind "$(get_binding "@powerline-mute-left" "$TMUX_POWERLINE_MUTE_LEFT_BINDING_DEFAULT")" run "$TMUX_POWERLINE_DIR_HOME/mute_powerline.sh left"
tmux bind "$(get_binding "@powerline-mute-right" "$TMUX_POWERLINE_MUTE_RIGHT_BINDING_DEFAULT")" run "$TMUX_POWERLINE_DIR_HOME/mute_powerline.sh right"
