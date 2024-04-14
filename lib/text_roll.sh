# shellcheck shell=bash
# Rolling anything what you want.
# arg1: text to roll.
# arg2: max length to display.
# arg3: roll speed in characters per second.
# arg4: mode to fill {"space", "repeat"}
# arg5: repeat separator
roll_text() {
	local text="$1" # Text to print

	if [ -z "$text" ]; then
		return
	fi

	local max_len="10" # Default max length.

	if [ -n "$2" ]; then
		max_len="$2"
	fi

	local speed="1" # Default roll speed in chars per second.

	if [ -n "$3" ]; then
		speed="$3"
	fi

	local fill_mode="space" # Default fill mode

	if [ -n "$4" ]; then
		if [ "$4" = "repeat" ]; then
			fill_mode="repeat"
		elif [ "$4" = "space" ]; then
			fill_mode="space"
		else
			echo "Not a valid fill_mode: {\"space\", \"repeat\"}: $4" >&2
		fi
	fi

	local repeat_sep=" ** " # Default repeat separator

	if [ -n "$5" ]; then
		repeat_sep="$5"
	fi

	local repeat="${repeat_sep}${text}"

	# Skip rolling if the output is less than max_len.
	if [ "${#text}" -le "$max_len" ]; then
		echo "$text"
		return
	fi

	# Anything starting with 0 is an Octal number in Shell,C or Perl,
	# so we must explicitly state the base of a number using base#number
	if [ "$fill_mode" = "repeat" ]; then
		local offset=$((10#$(date +%s) * speed % ${#repeat}))
	elif [ "$fill_mode" = "space" ] || :; then
		local offset=$((10#$(date +%s) * speed % ${#text}))
	fi
	# Truncate text on time-based offset
	text=${text:offset}

	# Ensure text is not longer than max_len
	text=${text:0:max_len}

	# Get fill count by substracting length of current text from max_len
	local fill_count=$((max_len - ${#text}))

	for ((index = 0; index < fill_count; index++)); do
		if [ "$fill_mode" = "repeat" ]; then
			text="${text}${repeat:index:1}"
		elif [ "$fill_mode" = "space" ] || :; then
			text="${text} "
		fi
	done

	echo "${text}"
}
