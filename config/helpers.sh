# shellcheck shell=bash
# Other settings and helper functions.

# shellcheck source=lib/util.sh
source "${TMUX_POWERLINE_DIR_LIB}/util.sh"

tp_debug_mode_enabled() {
	[ -n "$TMUX_POWERLINE_DEBUG_MODE_ENABLED" ] && [ "$TMUX_POWERLINE_DEBUG_MODE_ENABLED" != "false" ]
}

# deprecated, function will be removed in future release, use tp_patched_font_in_use instead
patched_font_in_use(){
	tp_err "config/helpers.sh" "Deprecated function \"patched_font_in_use\" will be removed in future release, update your theme and use \"tp_patched_font_in_use\" instead"
	tp_patched_font_in_use "$@"
}

tp_patched_font_in_use() {
	[ -z "$TMUX_POWERLINE_PATCHED_FONT_IN_USE" ] || [ "$TMUX_POWERLINE_PATCHED_FONT_IN_USE" != "false" ]
}
