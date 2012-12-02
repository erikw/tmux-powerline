# Library functions.

segments_dir="segments"

print_status_line_right() {
  prev_bg="colour148"

  for entry in ${TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS[@]}; do
    local script="$TMUX_POWERLINE_HOME/$segments_dir/$entry.sh"
    local foreground='colour255'
    local background='colour0'
    local separator=$TMUX_POWERLINE_SEPARATOR_LEFT_THIN
    local separator_fg='colour255'

    local output=$(${script})

    if [ -n "$output" ]; then
      __ui_right "$prev_bg" "$background" "$foreground" "$separator" "$separator_fg"
      echo -n "$output"
      prev_bg="$background"
      if [ "$first_segment_right" -eq "1" ]; then
        first_segment_right=0
      fi
    fi
  done

  # End in a clean state.
  echo "#[default]"
}

first_segment_left=1
print_status_line_left() {
  prev_bg="colour148"

  for entry in ${TMUX_POWERLINE_LEFT_STATUS_SEGMENTS[@]}; do
    local script="$TMUX_POWERLINE_HOME/$segments_dir/$entry.sh"
    local foreground='colour255'
    local background='colour0'
    local separator=$TMUX_POWERLINE_SEPARATOR_RIGHT_THIN
    local separator_fg='colour255'

    local output=$(${script})

    if [ -n "$output" ]; then
      __ui_left "$prev_bg" "$background" "$foreground" "$separator" "$separator_fg"
      echo -n "$output"
      prev_bg="$background"
      if [ "$first_segment_left" -eq "1" ]; then
        first_segment_left=0
      fi
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
    local env_name=$(tmux display -p "TMUXPWD_#D" | tr -d %)
    local env_val=$(tmux show-environment | grep --color=never "$env_name")
    # The version below is still quite new for tmux. Uncommented this in the future :-)
    #local env_val=$(tmux show-environment "$env_name" 2>&1)

    if [[ ! $env_val =~ "unknown variable" ]]; then
	local tmux_pwd=$(echo "$env_val" | sed 's/^.*=//')
	echo "$tmux_pwd"
    fi
}

# Rolling anything what you want.
# arg1: text to roll.
# arg2: max length to display.
# arg3: roll speed in characters per second.
roll_text() {
    local text="$1"	# Text to print
    if [ -z "$text" ]; then
    	return;
    fi
    local max_len="10"	# Default max length.
    if [ -n "$2" ]; then
    	max_len="$2"
    fi
    local speed="1"	# Default roll speed in chars per second.
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
