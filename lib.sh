# Library functions.

addins_path="./addins"
declare entries

# Separators
separator_left_bold="◀"
separator_left_thin="❮"
separator_right_bold="▶"
separator_right_thin="❯"


# Register an addin.
register_addin() {
	addin_name="$1"
	entries[${#entries[*]}]="$addin_name"

}

print_status_line_left() {
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
		__ui_left "$prev_bg" "$background" "$foreground" "$separator" "$separator_fg"
		echo -n "$output"
		prev_bg="$background"
	done
	# End in a clean state.
	echo "#[default]"
}

first_addin_right=1
print_status_line_right() {
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
		__ui_right "$prev_bg" "$background" "$foreground" "$separator" "$separator_fg"
		echo -n "$output"
		prev_bg="$background"
		if [ "$first_addin_right" -eq "1" ]; then
			first_addin_right=0
		fi
	done
	__ui_right "colour235" "colour235" "red" "$separator_right_bold" "$prev_bg"

	# End in a clean state.
	echo "#[default]"
}

#Internal printer for left.
__ui_left() {
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

# Internal printer for right.
__ui_right() {
	local bg_left="$1"
	local bg_right="$2"
	local fg_right="$3"
	local separator
	if [ "$first_addin_right" -eq "1" ]; then
		separator=""
	else
		separator="$4"
	fi

	local separator_fg
	if [ -n "$5" ]; then
		bg_left="$5"
		separator_bg="$bg_right"
	else
		separator_bg="$bg_right"
	fi

	if [ "$first_addin_right" -eq "1" ]; then
		echo -n "#[bg=${bg_right}]"
	fi

	echo -n " #[fg=${bg_left}, bg=${separator_bg}]${separator}#[fg=${fg_right},bg=${bg_right}]"

	if [ "$first_addin_right" -ne "1" ]; then
		echo -n " "
	fi
}
