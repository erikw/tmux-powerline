# Rolling anything what you want.
# arg1: text to roll.
# arg2: max length to display.
# arg3: roll speed in characters per second.
roll_text() {
	local text="$1"  # Text to print

	if [ -z "$text" ]; then
		return;
	fi

	local max_len="10"	# Default max length.

	if [ -n "$2" ]; then
		max_len="$2"
	fi

	local speed="1"  # Default roll speed in chars per second.

	if [ -n "$3" ]; then
		speed="$3"
	fi

	# Skip rolling if the output is less than max_len.
	if [ "${#text}" -le "$max_len" ]; then
		echo "$text"
		return
	fi

	# Anything starting with 0 is an Octal number in Shell,C or Perl,
	# so we must explicitly state the base of a number using base#number
	local offset=$((10#$(date +%s) * ${speed} % ${#text}))

	# Truncate text.
	text=${text:offset}

	local char	# Character.
	local bytes # The bytes of one character.
	local index

	for ((index=0; index < max_len; index++)); do
		char=${text:index:1}
		bytes=$(echo -n $char | wc -c)
		# The character will takes twice space
		# of an alphabet if (bytes > 1).
		if ((bytes > 1)); then
			max_len=$((max_len - 1))
		fi
	done

	text=${text:0:max_len}

	#echo "index=${index} max=${max_len} len=${#text}"
	# How many spaces we need to fill to keep
	# the length of text that will be shown?
	local fill_count=$((${index} - ${#text}))

	for ((index=0; index < fill_count; index++)); do
		text="${text} "
	done

	echo "${text}"
}
