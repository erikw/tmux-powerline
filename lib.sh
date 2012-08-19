# Library functions.

segments_dir="segments"
declare entries

if [ -n "$USE_PATCHED_FONT" -a "$USE_PATCHED_FONT" == "true" ]; then
	# Separators (patched font required)
	separator_left_bold="⮂"
	separator_left_thin="⮃"
	separator_right_bold="⮀"
	separator_right_thin="⮁"
else
	# Alternative separators in the normal Unicode table.
	separator_left_bold="◀"
	separator_left_thin="❮"
	separator_right_bold="▶"
	separator_right_thin="❯"
fi

# Make sure that grep does not emit colors.
export GREP_OPTIONS="--color=never"

# Register a segment.
register_segment() {
	segment_name="$1"
	entries[${#entries[*]}]="$segment_name"

}

print_status_line_right() {
	local prev_bg="colour235"
	for entry in ${entries[*]}; do
		local script=$(eval echo \${${entry}["script"]})
		local foreground=$(eval echo \${${entry}["foreground"]})
		local background=$(eval echo \${${entry}["background"]})
		local separator=$(eval echo \${${entry}["separator"]})
		local separator_fg=""
		if [ $(eval echo \${${entry}["separator_fg"]+_}) ];then
			separator_fg=$(eval echo \${${entry}["separator_fg"]})
		fi

		local output=$(${script})
		if [ -z "$output" ]; then
			continue
		fi
		__ui_right "$prev_bg" "$background" "$foreground" "$separator" "$separator_fg"
		echo -n "$output"
		prev_bg="$background"
	done
	# End in a clean state.
	echo "#[default]"
}

first_segment_left=1
print_status_line_left() {
	prev_bg="colour148"
	for entry in ${entries[*]}; do
		local script=$(eval echo \${${entry}["script"]})
		local foreground=$(eval echo \${${entry}["foreground"]})
		local background=$(eval echo \${${entry}["background"]})
		local separator=$(eval echo \${${entry}["separator"]})
		local separator_fg=""
		if [ $(eval echo \${${entry}["separator_fg"]+_}) ];then
			separator_fg=$(eval echo \${${entry}["separator_fg"]})
		fi

		local output=$(${script})
		if [ -z "$output" ]; then
			continue
		fi
		__ui_left "$prev_bg" "$background" "$foreground" "$separator" "$separator_fg"
		echo -n "$output"
		prev_bg="$background"
		if [ "$first_segment_left" -eq "1" ]; then
			first_segment_left=0
		fi
	done
	__ui_left "colour235" "colour235" "red" "$separator_right_bold" "$prev_bg"

	# End in a clean state.
	echo "#[default]"
}

#Internal printer for right.
__ui_right() {
	local bg_left="$1"
	local bg_right="$2"
	local fg_right="$3"
	local separator="$4"
	local separator_fg
	if [ -n "$5" ]; then
		separator_fg="$5"
	else
		separator_fg="$bg_right"
	fi
	echo -n " #[fg=${separator_fg}, bg=${bg_left}]${separator}#[fg=${fg_right},bg=${bg_right}] "
}

# Internal printer for left.
__ui_left() {
	local bg_left="$1"
	local bg_right="$2"
	local fg_right="$3"
	local separator
	if [ "$first_segment_left" -eq "1" ]; then
		separator=""
	else
		separator="$4"
	fi

	local separator_bg
	if [ -n "$5" ]; then
		bg_left="$5"
		separator_bg="$bg_right"
	else
		separator_bg="$bg_right"
	fi

	if [ "$first_segment_left" -eq "1" ]; then
		echo -n "#[bg=${bg_right}]"
	fi

	echo -n " #[fg=${bg_left}, bg=${separator_bg}]${separator}#[fg=${fg_right},bg=${bg_right}]"

	if [ "$first_segment_left" -ne "1" ]; then
		echo -n " "
	fi
}

# Get the current path in the segment.
get_tmux_cwd() {
	local env_name=$(tmux display -p "TMUXPWD_#I_#P")
	local env_val=$(tmux show-environment | grep "$env_name")
	# The version below is still quite new for tmux. Uncommented this in the future :-)
	#local env_val=$(tmux show-environment "$env_name" 2>&1)

	if [[ ! $env_val =~ "unknown variable" ]]; then
		local tmux_pwd=$(echo "$env_val" | grep -PZo "(?<==).*$")
		echo "$tmux_pwd"
	fi
}
