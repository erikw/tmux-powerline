# Read user rc file.

process_settings() {
	__read_rcfile

	if [ -z "$TMUX_POWERLINE_DEBUG_MODE_ENABLED" ]; then
		export TMUX_POWERLINE_DEBUG_MODE_ENABLED="${TMUX_POWERLINE_DEBUG_MODE_ENABLED_DEFAULT}"
	fi

	if [ -z "$TMUX_POWERLINE_PATCHED_FONT_IN_USE" ]; then
		export TMUX_POWERLINE_PATCHED_FONT_IN_USE="${TMUX_POWERLINE_PATCHED_FONT_IN_USE_DEFAULT}"
	fi

	if [ -z "$TMUX_POWERLINE_THEME" ]; then
		export TMUX_POWERLINE_THEME="${TMUX_POWERLINE_THEME_DEFAULT}"
	fi

	if [ -z "$TMUX_POWERLINE_STATUS_VISIBILITY" ]; then
		export TMUX_POWERLINE_STATUS_VISIBILITY="${TMUX_POWERLINE_STATUS_VISIBILITY_DEFAULT}"
	fi

	if [ -z "$TMUX_POWERLINE_STATUS_INTERVAL" ]; then
		export TMUX_POWERLINE_STATUS_INTERVAL="${TMUX_POWERLINE_STATUS_INTERVAL_DEFAULT}"
	fi

	if [ -z "$TMUX_POWERLINE_STATUS_JUSTIFICATION" ]; then
		export TMUX_POWERLINE_STATUS_JUSTIFICATION="${TMUX_POWERLINE_STATUS_JUSTIFICATION_DEFAULT}"
	fi

	if [ -z "$TMUX_POWERLINE_STATUS_LEFT_LENGTH" ]; then
		export TMUX_POWERLINE_STATUS_LEFT_LENGTH="${TMUX_POWERLINE_STATUS_LEFT_LENGTH_DEFAULT}"
	fi

	if [ -z "$TMUX_POWERLINE_STATUS_RIGHT_LENGTH" ]; then
		export TMUX_POWERLINE_STATUS_RIGHT_LENGTH="${TMUX_POWERLINE_STATUS_RIGHT_LENGTH_DEFAULT}"
	fi

	if [ -z "$TMUX_POWERLINE_MUTE_LEFT_KEYBINDING" ]; then
		export TMUX_POWERLINE_MUTE_LEFT_KEYBINDING="${TMUX_POWERLINE_MUTE_LEFT_KEYBINDING_DEFAULT}"
	fi

	if [ -z "$TMUX_POWERLINE_MUTE_RIGHT_KEYBINDING" ]; then
		export TMUX_POWERLINE_MUTE_RIGHT_KEYBINDING="${TMUX_POWERLINE_MUTE_RIGHT_KEYBINDING_DEFAULT}"
	fi

	eval TMUX_POWERLINE_DIR_USER_SEGMENTS="$TMUX_POWERLINE_DIR_USER_SEGMENTS"
	eval TMUX_POWERLINE_DIR_USER_THEMES="$TMUX_POWERLINE_DIR_USER_THEMES"
	if [ -n "$TMUX_POWERLINE_DIR_USER_THEMES" ] && [ -f "${TMUX_POWERLINE_DIR_USER_THEMES}/${TMUX_POWERLINE_THEME}.sh" ]; then
		source "${TMUX_POWERLINE_DIR_USER_THEMES}/${TMUX_POWERLINE_THEME}.sh"
	else
		source "${TMUX_POWERLINE_DIR_THEMES}/${TMUX_POWERLINE_THEME}.sh"
	fi

}

generate_default_rc() {
	read -d '' rccontents  << EORC
# Default configuration file for tmux-powerline.
# Modeline {
#	 vi: foldmarker={,} foldmethod=marker foldlevel=0 tabstop=4 filetype=sh
# }

# General {
	# Show which segment fails and its exit code.
	export TMUX_POWERLINE_DEBUG_MODE_ENABLED="${TMUX_POWERLINE_DEBUG_MODE_ENABLED_DEFAULT}"
	# Use patched font symbols.
	export TMUX_POWERLINE_PATCHED_FONT_IN_USE="${TMUX_POWERLINE_PATCHED_FONT_IN_USE_DEFAULT}"

	# The theme to use.
	export TMUX_POWERLINE_THEME="${TMUX_POWERLINE_THEME_DEFAULT}"
	# Overlay directory to look for themes. There you can put your own themes outside the repo. Fallback will still be the "themes" directory in the repo.
	export TMUX_POWERLINE_DIR_USER_THEMES="\${XDG_CONFIG_HOME:-\$HOME/.config}/tmux-powerline/themes"
	# Overlay directory to look for segments. There you can put your own segments outside the repo. Fallback will still be the "segments" directory in the repo.
	export TMUX_POWERLINE_DIR_USER_SEGMENTS="\${XDG_CONFIG_HOME:-\$HOME/.config}/tmux-powerline/segments"

	# The initial visibility of the status bar. Can be {"on, off"}.
	export TMUX_POWERLINE_STATUS_VISIBILITY="${TMUX_POWERLINE_STATUS_VISIBILITY_DEFAULT}"
	# The status bar refresh interval in seconds.
	# Note that events that force-refresh the status bar (such as window renaming) will ignore this.
	export TMUX_POWERLINE_STATUS_INTERVAL="${TMUX_POWERLINE_STATUS_INTERVAL_DEFAULT}"
	# The location of the window list. Can be {"absolute-centre, centre, left, right"}.
	export TMUX_POWERLINE_STATUS_JUSTIFICATION="${TMUX_POWERLINE_STATUS_JUSTIFICATION_DEFAULT}"

	# The maximum length of the left status bar.
	export TMUX_POWERLINE_STATUS_LEFT_LENGTH="${TMUX_POWERLINE_STATUS_LEFT_LENGTH_DEFAULT}"
	# The maximum length of the right status bar.
	export TMUX_POWERLINE_STATUS_RIGHT_LENGTH="${TMUX_POWERLINE_STATUS_RIGHT_LENGTH_DEFAULT}"

	# Uncomment these if you want to enable tmux bindings for muting (hiding) one of the status bars.
	# E.g. this example binding would mute the left status bar when pressing <prefix> followed by Ctrl-[
	#export TMUX_POWERLINE_MUTE_LEFT_KEYBINDING="C-["
	#export TMUX_POWERLINE_MUTE_RIGHT_KEYBINDING="C-]"
# }
EORC

	for segment in ${TMUX_POWERLINE_DIR_SEGMENTS}/*.sh; do
		source "$segment"
		if declare -f generate_segmentrc >/dev/null; then
			segmentrc=$(generate_segmentrc | sed -e 's/^/\\t/g')
			unset -f generate_segmentrc
			local seg_name="${segment##*/}"
			rccontents="${rccontents}\n\n# ${seg_name} {\n${segmentrc}\n# }"
		fi
	done

	echo -e "$rccontents" > "$TMUX_POWERLINE_RCFILE_DEFAULT"
	echo "Default configuration file generated to: ${TMUX_POWERLINE_RCFILE_DEFAULT}"
	echo "Copy/move it to \"${TMUX_POWERLINE_RCFILE}\" and make your changes."
}

__read_rcfile() {
	if [  -f "$TMUX_POWERLINE_RCFILE" ]; then
		source "$TMUX_POWERLINE_RCFILE"
	fi
}
