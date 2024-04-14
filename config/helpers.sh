# shellcheck shell=bash
# Other settings and helper functions.

debug_mode_enabled() {
	[ -n "$TMUX_POWERLINE_DEBUG_MODE_ENABLED" ] && [ "$TMUX_POWERLINE_DEBUG_MODE_ENABLED" != "false" ]
}

patched_font_in_use() {
	[ -z "$TMUX_POWERLINE_PATCHED_FONT_IN_USE" ] || [ "$TMUX_POWERLINE_PATCHED_FONT_IN_USE" != "false" ]
}
