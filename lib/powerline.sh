# Library functions.

segments_dir="segments"

print_status_line_right() {
  prev_bg="colour0"

  for entry in ${TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS[@]}; do
    local script="$TMUX_POWERLINE_HOME/$segments_dir/$entry.sh"
    local foreground="colour255"
    local background="colour0"
    local separator=$TMUX_POWERLINE_SEPARATOR_LEFT_THIN
    local separator_fg="colour255"

    local output=$(${script})

    if [ -n "$output" ]; then
      __ui_right "$prev_bg" "$background" "$foreground" "$separator" "$separator_fg"
      echo -n "$output"
      prev_bg="$background"
    fi
  done

  # End in a clean state.
  echo "#[default]"
}

print_status_line_left() {
  prev_bg="colour148"
  echo -n "#[fg=colour255, bg=colour0]"

  for entry in ${TMUX_POWERLINE_LEFT_STATUS_SEGMENTS[@]}; do
    local script="$TMUX_POWERLINE_HOME/$segments_dir/$entry.sh"
    local foreground="colour255"
    local background="colour0"
    local separator=$TMUX_POWERLINE_SEPARATOR_RIGHT_THIN
    local separator_fg="colour255"

    local output=$(${script})

    if [ -n "$output" ]; then
      echo -n "$output"
      __ui_left "$prev_bg" "$background" "$foreground" "$separator" "$separator_fg"
      prev_bg="$background"
    fi
  done

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

  echo -n " #[fg=${separator_fg}, bg=${bg_left}] ${separator}#[fg=${fg_right},bg=${bg_right}] "
}

# Internal printer for left.
__ui_left() {
  local bg_left="$1"
  local bg_right="$2"
  local fg_right="$3"
  local separator="$4"

  local separator_bg

  if [ -n "$5" ]; then
    bg_left="$5"
    separator_bg="$bg_right"
  else
    separator_bg="$bg_right"
  fi

  echo -n " #[fg=${bg_left}, bg=${separator_bg}]${separator}#[fg=${fg_right},bg=${bg_right}] "
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
