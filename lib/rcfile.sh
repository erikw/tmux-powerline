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
	export TMUX_POWERLINE_DIR_USER_THEMES=""
	# Overlay directory to look for segments. There you can put your own segments outside the repo. Fallback will still be the "segments" directory in the repo.
	export TMUX_POWERLINE_DIR_USER_SEGMENTS=""
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
