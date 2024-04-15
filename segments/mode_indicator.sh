# shellcheck shell=bash
# Segment that indicates status of various tmux modes. The list of supported
# modes & a brief description of each is as follows:
#
# - Normal mode: The default mode when you are simply using tmux.
#
# - Prefix mode: The mode when the tmux prefix key is pressed.
#
# - Mouse mode: While not definitionally a mode according to `man tmux`, this is
#   a mode in the sense that it changes the behavior of tmux, & can be toggled
#   on & off via the `tmux set-option -g mouse {on,off}` command; see `man tmux`
#   for more details.
#
# - Copy mode: The mode when text is being copied. By default this is triggered
#   by pressing the prefix key followed by '['; see `man tmux` for more details.
#
# - Suspend mode: A custom mode by https://github.com/MunifTanjim/tmux-suspend/
#   This suspends prefix processing, allowing prefix keys to directly reach a
#   nested tmux.
#
# Normal & prefix modes toggle between each other, so they occupy the same
# section of this segment. The other modes are independent of each other, so
# they each have their own part of the segment. By default, all modes are
# enabled, the text color for each node defaults to whatever foreground color is
# set in the user's theme, & the below list defines the default text for each
# mode & separator. These can all be overridden in `config.sh`.

# Default values for the settings that this segment supports.
NORMAL_AND_PREFIX_MODE_ENABLED_DEFAULT="true"

NORMAL_MODE_TEXT_DEFAULT="normal"
NORMAL_MODE_TEXT_COLOR_DEFAULT="$TMUX_POWERLINE_CUR_SEGMENT_FG"

PREFIX_MODE_TEXT_DEFAULT="prefix"
PREFIX_MODE_TEXT_COLOR_DEFAULT="$TMUX_POWERLINE_CUR_SEGMENT_FG"

MOUSE_MODE_ENABLED_DEFAULT="true"

MOUSE_MODE_TEXT_DEFAULT="mouse"
MOUSE_MODE_TEXT_COLOR_DEFAULT="$TMUX_POWERLINE_CUR_SEGMENT_FG"

COPY_MODE_ENABLED_DEFAULT="true"

COPY_MODE_TEXT_DEFAULT="copy"
COPY_MODE_TEXT_COLOR_DEFAULT="$TMUX_POWERLINE_CUR_SEGMENT_FG"

SUSPEND_MODE_TEXT_DEFAULT="SUSPEND"
SUSPEND_MODE_TEXT_COLOR_DEFAULT="$TMUX_POWERLINE_CUR_SEGMENT_FG"

SEPARATOR_TEXT_DEFAULT=" • "

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Whether the normal & prefix mode section should be enabled. Should be {"true, "false"}.
export TMUX_POWERLINE_SEG_MODE_INDICATOR_NORMAL_AND_PREFIX_MODE_ENABLED="${NORMAL_AND_PREFIX_MODE_ENABLED_DEFAULT}"
# Normal mode text & color overrides. Defaults to "normal" & the segment foreground color set in the theme used.
export TMUX_POWERLINE_SEG_MODE_INDICATOR_NORMAL_MODE_TEXT="${NORMAL_MODE_TEXT_DEFAULT}"
export TMUX_POWERLINE_SEG_MODE_INDICATOR_NORMAL_MODE_TEXT_COLOR=""
# Prefix mode text & color overrides. Defaults to "prefix" & the segment foreground color set in the theme used.
export TMUX_POWERLINE_SEG_MODE_INDICATOR_PREFIX_MODE_TEXT="${PREFIX_MODE_TEXT_DEFAULT}"
export TMUX_POWERLINE_SEG_MODE_INDICATOR_PREFIX_MODE_TEXT_COLOR=""
# Whether the mouse mode section should be enabled. Should be {"true, "false"}.
export TMUX_POWERLINE_SEG_MODE_INDICATOR_MOUSE_MODE_ENABLED="${MOUSE_MODE_ENABLED_DEFAULT}"
# Mouse mode text & color overrides. Defaults to "mouse" & the segment foreground color set in the theme used.
export TMUX_POWERLINE_SEG_MODE_INDICATOR_MOUSE_MODE_TEXT="${MOUSE_MODE_TEXT_DEFAULT}"
export TMUX_POWERLINE_SEG_MODE_INDICATOR_MOUSE_MODE_TEXT_COLOR=""
# Whether the copy mode section should be enabled. Should be {"true, "false"}.
export TMUX_POWERLINE_SEG_MODE_INDICATOR_COPY_MODE_ENABLED="${COPY_MODE_ENABLED_DEFAULT}"
# Copy mode text & color overrides. Defaults to "copy" & the segment foreground color set in the theme used.
export TMUX_POWERLINE_SEG_MODE_INDICATOR_COPY_MODE_TEXT="${COPY_MODE_TEXT_DEFAULT}"
export TMUX_POWERLINE_SEG_MODE_INDICATOR_COPY_MODE_TEXT_COLOR=""
# Suspend mode text & color overrides. Defaults to "SUSPEND" & the segment foreground color set in the theme used.
export TMUX_POWERLINE_SEG_MODE_INDICATOR_SUSPEND_MODE_TEXT="${SUSPEND_MODE_TEXT_DEFAULT}"
export TMUX_POWERLINE_SEG_MODE_INDICATOR_SUSPEND_MODE_TEXT_COLOR=""
# Separator text override. Defaults to " • ".
export TMUX_POWERLINE_SEG_MODE_INDICATOR_SEPARATOR_TEXT="${SEPARATOR_TEXT_DEFAULT}"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings

	# Colors.
	normal_text_color="#[fg=$TMUX_POWERLINE_SEG_MODE_INDICATOR_NORMAL_MODE_TEXT_COLOR]"
	prefix_text_color="#[fg=$TMUX_POWERLINE_SEG_MODE_INDICATOR_PREFIX_MODE_TEXT_COLOR]"
	mouse_text_color="#[fg=$TMUX_POWERLINE_SEG_MODE_INDICATOR_MOUSE_MODE_TEXT_COLOR]"
	copy_text_color="#[fg=$TMUX_POWERLINE_SEG_MODE_INDICATOR_COPY_MODE_TEXT_COLOR]"
	suspend_text_color="#[fg=$TMUX_POWERLINE_SEG_MODE_INDICATOR_SUSPEND_MODE_TEXT_COLOR]"

	# Separator.
	separator="#[fg=$TMUX_POWERLINE_CUR_SEGMENT_FG]$TMUX_POWERLINE_SEG_MODE_INDICATOR_SEPARATOR_TEXT"

	# Populate segment.
	segment=""
	__normal_and_prefix_mode_indicator
	__mouse_mode_indicator
	# Copy mode should always be populated last; see comments in
	# __copy_mode_indicator for more details.
	__copy_mode_indicator

	echo "$segment"
	return 0
}

__normal_and_prefix_mode_indicator() {
	if [ "$TMUX_POWERLINE_SEG_MODE_INDICATOR_NORMAL_AND_PREFIX_MODE_ENABLED" != "true" ]; then
		return 0
	fi

	normal_mode="$normal_text_color$TMUX_POWERLINE_SEG_MODE_INDICATOR_NORMAL_MODE_TEXT"
	prefix_mode="$prefix_text_color$TMUX_POWERLINE_SEG_MODE_INDICATOR_PREFIX_MODE_TEXT"
	suspend_mode="$suspend_text_color$TMUX_POWERLINE_SEG_MODE_INDICATOR_SUSPEND_MODE_TEXT"

	if [ "$(tmux show-option -qv key-table)" = "suspended" ]; then
		normal_and_prefix_indicator="$suspend_mode"
	else
		normal_and_prefix_indicator="#{?client_prefix,$prefix_mode,$normal_mode}"
	fi

	if [ -z "$segment" ]; then
		segment+="$normal_and_prefix_indicator"
	else
		segment+="$separator$normal_and_prefix_indicator"
	fi
}

__mouse_mode_indicator() {
	if [ "$TMUX_POWERLINE_SEG_MODE_INDICATOR_MOUSE_MODE_ENABLED" != "true" ]; then
		return 0
	fi

	# Mouse mode status - check window, then session, then global settings.
	mouse_mode_status=$(tmux show-options -w | grep mouse | cut -d ' ' -f2) # Window-level options
	if [ -z "$mouse_mode_status" ]; then
		mouse_mode_status=$(tmux show-options | grep mouse | cut -d ' ' -f2) # Session-level options
		if [ -z "$mouse_mode_status" ]; then
			mouse_mode_status=$(tmux show-options -g | grep mouse | cut -d ' ' -f2) # Global options
		fi
	fi

	if [ "$mouse_mode_status" != "on" ]; then
		return 0
	fi

	mouse_indicator="$mouse_text_color$TMUX_POWERLINE_SEG_MODE_INDICATOR_MOUSE_MODE_TEXT"

	if [ -z "$segment" ]; then
		segment+="$mouse_indicator"
	else
		segment+="$separator$mouse_indicator"
	fi
}

__copy_mode_indicator() {
	if [ "$TMUX_POWERLINE_SEG_MODE_INDICATOR_COPY_MODE_ENABLED" != "true" ]; then
		return 0
	fi

	# Note that so long as the *_COPY_MODE_ENABLED flag is set, this will always
	# add a non-empty section to the segment, regardless of whether copy mode is
	# actually active. This is because this block of code uses tmux's #()/#{}
	# syntax for command substitution that doesn't get evaluated until runtime,
	# so for the purposes of this shell script it's always non-empty.
	#
	# Because of this, __copy_mode_indicator should always be called last
	# (i.e. it will always be the rightmost section of the segment), otherwise
	# the separator will be printed even if copy mode isn't active.
	copy_mode="$copy_text_color$TMUX_POWERLINE_SEG_MODE_INDICATOR_COPY_MODE_TEXT"
	if [ -z "$segment" ]; then
		segment+="#{?pane_in_mode,$copy_mode,}"
	else
		segment+="#{?pane_in_mode,$separator$copy_mode,}"
	fi
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_MODE_INDICATOR_NORMAL_AND_PREFIX_MODE_ENABLED" ]; then
		export TMUX_POWERLINE_SEG_MODE_INDICATOR_NORMAL_AND_PREFIX_MODE_ENABLED="${NORMAL_AND_PREFIX_MODE_ENABLED_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_MODE_INDICATOR_NORMAL_MODE_TEXT" ]; then
		export TMUX_POWERLINE_SEG_MODE_INDICATOR_NORMAL_MODE_TEXT="${NORMAL_MODE_TEXT_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_MODE_INDICATOR_NORMAL_MODE_TEXT_COLOR" ]; then
		export TMUX_POWERLINE_SEG_MODE_INDICATOR_NORMAL_MODE_TEXT_COLOR="${NORMAL_MODE_TEXT_COLOR_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_MODE_INDICATOR_PREFIX_MODE_TEXT" ]; then
		export TMUX_POWERLINE_SEG_MODE_INDICATOR_PREFIX_MODE_TEXT="${PREFIX_MODE_TEXT_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_MODE_INDICATOR_PREFIX_MODE_TEXT_COLOR" ]; then
		export TMUX_POWERLINE_SEG_MODE_INDICATOR_PREFIX_MODE_TEXT_COLOR="${PREFIX_MODE_TEXT_COLOR_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_MODE_INDICATOR_MOUSE_MODE_ENABLED" ]; then
		export TMUX_POWERLINE_SEG_MODE_INDICATOR_MOUSE_MODE_ENABLED="${MOUSE_MODE_ENABLED_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_MODE_INDICATOR_MOUSE_MODE_TEXT" ]; then
		export TMUX_POWERLINE_SEG_MODE_INDICATOR_MOUSE_MODE_TEXT="${MOUSE_MODE_TEXT_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_MODE_INDICATOR_MOUSE_MODE_TEXT_COLOR" ]; then
		export TMUX_POWERLINE_SEG_MODE_INDICATOR_MOUSE_MODE_TEXT_COLOR="${MOUSE_MODE_TEXT_COLOR_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_MODE_INDICATOR_COPY_MODE_ENABLED" ]; then
		export TMUX_POWERLINE_SEG_MODE_INDICATOR_COPY_MODE_ENABLED="${COPY_MODE_ENABLED_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_MODE_INDICATOR_COPY_MODE_TEXT" ]; then
		export TMUX_POWERLINE_SEG_MODE_INDICATOR_COPY_MODE_TEXT="${COPY_MODE_TEXT_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_MODE_INDICATOR_COPY_MODE_TEXT_COLOR" ]; then
		export TMUX_POWERLINE_SEG_MODE_INDICATOR_COPY_MODE_TEXT_COLOR="${COPY_MODE_TEXT_COLOR_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_MODE_INDICATOR_SUSPEND_MODE_TEXT" ]; then
		export TMUX_POWERLINE_SEG_MODE_INDICATOR_SUSPEND_MODE_TEXT="${SUSPEND_MODE_TEXT_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_MODE_INDICATOR_SUSPEND_MODE_TEXT_COLOR" ]; then
		export TMUX_POWERLINE_SEG_MODE_INDICATOR_SUSPEND_MODE_TEXT_COLOR="${SUSPEND_MODE_TEXT_COLOR_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_MODE_INDICATOR_SEPARATOR_TEXT" ]; then
		export TMUX_POWERLINE_SEG_MODE_INDICATOR_SEPARATOR_TEXT="${SEPARATOR_TEXT_DEFAULT}"
	fi
}
