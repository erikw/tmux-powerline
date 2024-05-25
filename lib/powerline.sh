# shellcheck shell=bash
# Library functions

print_powerline_side() {
	local side="$1"
	local upper_side

	upper_side=$(echo "$1" | tr '[:lower:]' '[:upper:]')
	eval "local input_segments=(\"\${TMUX_POWERLINE_${upper_side}_STATUS_SEGMENTS[@]}\")"
	local powerline_segments=()
	local powerline_segment_contents=()

	__check_platform

	__process_segment_defaults
	__process_scripts
	__process_colors

	__process_powerline
}

print_powerline_window_status_current_format() {
	if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_CURRENT" ]; then
		TMUX_POWERLINE_WINDOW_STATUS_CURRENT=(
			"#[$(format inverse)]"
			"$TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR"
			" #I#F "
			"$TMUX_POWERLINE_SEPARATOR_RIGHT_THIN"
			" #W "
			"#[$(format regular)]"
			"$TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR"
		)
	fi

	printf '%s' "${TMUX_POWERLINE_WINDOW_STATUS_CURRENT[@]}"
}

print_powerline_window_status_format() {
	if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_FORMAT" ]; then
		TMUX_POWERLINE_WINDOW_STATUS_FORMAT=(
			"#[$(format regular)]"
			"  #I#{?window_flags,#F, } "
			"$TMUX_POWERLINE_SEPARATOR_RIGHT_THIN"
			" #W "
		)
	fi

	printf '%s' "${TMUX_POWERLINE_WINDOW_STATUS_FORMAT[@]}"
}

format() {
	local type="$1"
	local bg_color
	local fg_color

	bg_color=$(__normalize_color "$TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR")
	fg_color=$(__normalize_color "$TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR")

	case $type in
	inverse)
		echo "fg=$bg_color,bg=$fg_color,nobold,noitalics,nounderscore"
		;;
	regular)
		echo "fg=$fg_color,bg=$bg_color,nobold,noitalics,nounderscore"
		;;
	*) ;;
	esac
}

__process_segment_defaults() {
	# shellcheck disable=SC2154 # disable until we found a better solution for eval input_segments
	for segment_index in "${!input_segments[@]}"; do
		local input_segment
		read -r -a input_segment <<<"${input_segments[segment_index]}"

		powerline_segment_with_defaults=(
			"${input_segment[0]:-no_script}"
			"${input_segment[1]:-default_bg_color}"
			"${input_segment[2]:-default_fg_color}"
			"${input_segment[3]:-default_separator}"
			"${input_segment[4]:-no_sep_bg_color}"
			"${input_segment[5]:-no_sep_fg_color}"
			"${input_segment[6]:-no_spacing_disable}"
			"${input_segment[7]:-no_separator_disable}"
		)

		powerline_segments[segment_index]="${powerline_segment_with_defaults[*]}"
	done
}

__process_scripts() {
	for segment_index in "${!powerline_segments[@]}"; do
		local powerline_segment
		read -r -a powerline_segment <<<"${powerline_segments[segment_index]}"

		if [ -n "$TMUX_POWERLINE_DIR_USER_SEGMENTS" ] && [ -f "$TMUX_POWERLINE_DIR_USER_SEGMENTS/${powerline_segment[0]}.sh" ]; then
			local script="$TMUX_POWERLINE_DIR_USER_SEGMENTS/${powerline_segment[0]}.sh"
		else
			local script="$TMUX_POWERLINE_DIR_SEGMENTS/${powerline_segment[0]}.sh"
		fi

		TMUX_POWERLINE_CUR_SEGMENT_BG=$(__normalize_color "${powerline_segment[1]}")
		TMUX_POWERLINE_CUR_SEGMENT_FG=$(__normalize_color "${powerline_segment[2]}")
		export TMUX_POWERLINE_CUR_SEGMENT_BG TMUX_POWERLINE_CUR_SEGMENT_FG
		# shellcheck disable=SC1090
		source "$script"
		local output
		output=$(run_segment)
		local exit_code="$?"
		unset -f run_segment

		if [ "$exit_code" -ne 0 ] && debug_mode_enabled; then
			local seg_name="${script##*/}"
			echo "Segment '${seg_name}' exited with code ${exit_code}. Aborting."
			exit 1
		fi

		if [ -n "$output" ]; then
			if [[ ${powerline_segment[6]} == "left_disable" ]]; then
				powerline_segment_contents[segment_index]="$output "
			elif [[ ${powerline_segment[6]} == "right_disable" ]]; then
				powerline_segment_contents[segment_index]=" $output"
			elif [[ ${powerline_segment[6]} == "both_disable" ]]; then
				powerline_segment_contents[segment_index]="$output"
			else
				powerline_segment_contents[segment_index]=" $output "
			fi
		else
			unset -v "powerline_segments[segment_index]"
		fi
	done
}

__process_colors() {
	for segment_index in "${!powerline_segments[@]}"; do
		local powerline_segment
		read -r -a powerline_segment <<<"${powerline_segments[segment_index]}"
		local separator_enable=${powerline_segment[7]}
		# Find the next segment that produces content (i.e. skip empty segments).
		for next_segment_index in $(eval echo "{$((segment_index + 1))..${#powerline_segments}}"); do
			[[ -n ${powerline_segments[next_segment_index]} ]] && break
		done
		local next_segment
		read -r -a next_segment <<<"${powerline_segments[next_segment_index]}"

		if [ "${powerline_segment[1]}" = "default_bg_color" ]; then
			powerline_segment[1]="$TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR"
		fi
		if [ "${powerline_segment[2]}" = "default_fg_color" ]; then
			powerline_segment[2]="$TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR"
		fi

		if [ "$side" == 'left' ]; then
			if [ "${powerline_segment[4]}" = "no_sep_bg_color" ]; then
				powerline_segment[4]=${next_segment[1]:-$TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR}
			fi
		elif [ "$side" == 'right' ]; then
			if [ "${powerline_segment[4]}" = "no_sep_bg_color" ]; then
				powerline_segment[4]=${previous_background_color:-$TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR}
			fi
		fi

		if __segment_separator_is_thin; then
			if [ "${powerline_segment[5]}" = "no_sep_fg_color" ]; then
				powerline_segment[5]=${powerline_segment[2]}
			fi
		else
			if [ "${powerline_segment[5]}" = "no_sep_fg_color" ]; then
				powerline_segment[5]=${powerline_segment[1]}
			fi
		fi

		local previous_background_color=${powerline_segment[1]}
		powerline_segment[7]=$separator_enable

		powerline_segments[segment_index]="${powerline_segment[*]}"
	done
}

__process_powerline() {
	for segment_index in "${!powerline_segments[@]}"; do
		local powerline_segment
		read -r -a powerline_segment <<<"${powerline_segments[segment_index]}"

		local background_color=${powerline_segment[1]}
		local foreground_color=${powerline_segment[2]}
		if [ "${powerline_segment[3]}" = "default_separator" ]; then
			if [ "$upper_side" = "RIGHT" ]; then
				local separator="$TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR"
			elif [ "$upper_side" = "LEFT" ]; then
				local separator="$TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR"
			fi
		else
			local separator=${powerline_segment[3]}
		fi
		local separator_background_color=${powerline_segment[4]}
		local separator_foreground_color=${powerline_segment[5]}
		local spacing_disable=${powerline_segment[6]}
		local separator_disable=${powerline_segment[7]}

		eval "__print_${side}_segment \"${segment_index}\" \"${background_color}\" \"${foreground_color}\" \"${separator}\" \"${separator_background_color}\" \"${separator_foreground_color}\" \"${spacing_disable}\" \"${separator_disable}\""
	done
}

__print_left_segment() {
	local content=${powerline_segment_contents[$1]}
	local content_background_color=$2
	local content_foreground_color=$3
	local separator=$4
	local separator_background_color=$5
	local separator_foreground_color=$6
	local spacing_disable=$7
	local separator_disable=$8

	__print_colored_content "$content" "$content_background_color" "$content_foreground_color"
	if [ ! "$separator_disable" == "separator_disable" ]; then
		__print_colored_content "$separator" "$separator_background_color" "$separator_foreground_color"
	fi
}

__print_right_segment() {
	local content=${powerline_segment_contents[$1]}
	local content_background_color=$2
	local content_foreground_color=$3
	local separator=$4
	local separator_background_color=$5
	local separator_foreground_color=$6
	local spacing_disable=$7
	local separator_disable=$8

	if [ ! "$separator_disable" == "separator_disable" ]; then
		__print_colored_content "$separator" "$separator_background_color" "$separator_foreground_color"
	fi
	__print_colored_content "$content" "$content_background_color" "$content_foreground_color"
}

__segment_separator_is_thin() {
	[[ ${powerline_segment[3]} == "$TMUX_POWERLINE_SEPARATOR_LEFT_THIN" || ${powerline_segment[3]} == "$TMUX_POWERLINE_SEPARATOR_RIGHT_THIN" ]]
}

__check_platform() {
	if [ "$SHELL_PLATFORM" == "unknown" ] && debug_mode_enabled; then
		echo "Unknown platform; modify config/shell.sh" >&2
	fi
}
