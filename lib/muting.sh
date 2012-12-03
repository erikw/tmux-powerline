mute_status_check() {
  local side=$1
  local tmux_session=$(tmux display -p "#S")
  local mute_file="${TMUX_POWERLINE_TEMPORARY_DIRECTORY}/mute_${tmux_session}_${side}"

  if [ -e  "$mute_file" ]; then
    exit
  fi
}

mute_status() {
  local side=$1
  local tmux_session=$(tmux display -p "#S")
  local mute_file="${TMUX_POWERLINE_TEMPORARY_DIRECTORY}/mute_${tmux_session}_${side}"

  if [ -e  "$mute_file" ]; then
    rm "$mute_file"
  else
    touch "$mute_file"
  fi
}
