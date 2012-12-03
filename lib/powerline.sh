# Library functions.

print_powerline() {
  local side="$1"
  eval "local input_segments=(\"\${TMUX_POWERLINE_${side^^}_STATUS_SEGMENTS[@]}\")"
  local powerline_segments=()
  local powerline_segment_contents=()

  __process_segment_defaults
  __process_scripts
  __process_colors

  __process_powerline
}

__process_segment_defaults() {
  for segment_index in "${!input_segments[@]}"; do
    local input_segment=(${input_segments[$segment_index]})
    eval "local default_separator=\$TMUX_POWERLINE_DEFAULT_${side^^}SIDE_SEPARATOR"

    powerline_segment_with_defaults=(
      ${input_segment[0]:-"no_script"} \
      ${input_segment[1]:-$TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR} \
      ${input_segment[2]:-$TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR} \
      ${input_segment[3]:-$default_separator} \
    )

    powerline_segments[$segment_index]="${powerline_segment_with_defaults[@]}"
  done
}

__process_scripts() {
  for segment_index in "${!powerline_segments[@]}"; do
    local powerline_segment=(${powerline_segments[$segment_index]})
    local script="$TMUX_POWERLINE_SEGMENTS_HOME/${powerline_segment[0]}.sh"
    local output=$($script)

    if [ -n "$output" ]; then
      powerline_segment_contents[$segment_index]=" $output "
    else
      unset -v powerline_segments[$segment_index]
    fi
  done
}

__process_colors() {
  for segment_index in "${!powerline_segments[@]}"; do
    local powerline_segment=(${powerline_segments[$segment_index]})
    local next_segment=(${powerline_segments[segment_index + 1]})

    if [ $side == 'left' ]; then
      powerline_segment[4]=${next_segment[1]:-$TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR}
    elif [ $side == 'right' ]; then
      powerline_segment[4]=${previous_background_color:-$TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR}
    fi

    powerline_segment[5]=${powerline_segment[1]}

    local previous_background_color=${powerline_segment[1]}

    powerline_segments[$segment_index]="${powerline_segment[@]}"
  done
}

__process_powerline() {
  for segment_index in "${!powerline_segments[@]}"; do
    local powerline_segment=(${powerline_segments[$segment_index]})

    local background_color=${powerline_segment[1]}
    local foreground_color=${powerline_segment[2]}
    local separator=${powerline_segment[3]}
    local separator_background_color=${powerline_segment[4]}
    local separator_foreground_color=${powerline_segment[5]}

    eval "__print_${side}_segment ${segment_index} ${background_color} ${foreground_color} ${separator} ${separator_background_color} ${separator_foreground_color}"
  done
}

__print_left_segment() {
  local content=${powerline_segment_contents[$1]}
  local content_background_color=$2
  local content_foreground_color=$3
  local separator=$4
  local separator_background_color=$5
  local separator_foreground_color=$6

  __print_colored_content "$content" $content_background_color $content_foreground_color
  __print_colored_content $separator $separator_background_color $separator_foreground_color
}

__print_right_segment() {
  local content=${powerline_segment_contents[$1]}
  local content_background_color=$2
  local content_foreground_color=$3
  local separator=$4
  local separator_background_color=$5
  local separator_foreground_color=$6

  __print_colored_content $separator $separator_background_color $separator_foreground_color
  __print_colored_content "$content" $content_background_color $content_foreground_color
}
