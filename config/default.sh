#!/bin/sh

debug_mode_enabled  () {
  [ -n "$TMUX_POWERLINE_DEBUG_MODE_ENABLED" -a "$TMUX_POWERLINE_DEBUG_MODE_ENABLED" != "false" ];
}

patched_font_in_use () {
  [ -z "$TMUX_POWERLINE_PATCHED_FONT_IN_USE" -o "$TMUX_POWERLINE_PATCHED_FONT_IN_USE" != "false" ];
}

if [ -z "$PLATFORM" ]; then
	# You platform \in {linux,bsd,mac}.
	export PLATFORM="linux"
fi
