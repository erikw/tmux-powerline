# shellcheck shell=bash
# Utilities for formatting content
#
# Dependencies:
#		- ./colors.sh

#######################################
# Returns a string coloring content using tmux's color formatting
#
# Arguments:
#   $1: a string of text to render
#   $2: the background color
#   $3: the foreground color color
#######################################
__print_colored_content() {
	bgcolor=$(__normalize_color "$2")
	fgcolor=$(__normalize_color "$3")

	echo -n "#[fg=${fgcolor},bg=${bgcolor}]"
	echo -n "$1"
	echo -n "#[default]"
}
