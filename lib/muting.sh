muted() {
  local side=$1
  local tmux_session=$(tmux display -p "#S")
  local mute_file="${TMUX_POWERLINE_TEMPORARY_DIRECTORY}/mute_${tmux_session}_${side}"

  [ -e "$mute_file" ];
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
