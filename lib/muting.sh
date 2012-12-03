###
# Muting Logic
#
# In all cases $1 is the side to be muted (eg left/right)
#
muted() {
  [ -e "$(__mute_file $1)" ];
}

toggle_mute_status() {
  if muted $1; then
    rm "$(__mute_file $1)"
  else
    touch "$(__mute_file $1)"
  fi
}

__mute_file() {
  local tmux_session=$(tmux display -p "#S")

  echo -n "${TMUX_POWERLINE_TEMPORARY_DIRECTORY}/mute_${tmux_session}_$1"
}
