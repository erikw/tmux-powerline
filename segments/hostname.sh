# shellcheck shell=bash
# Prints the hostname.

TMUX_POWERLINE_SEG_HOSTNAME_FORMAT="${TMUX_POWERLINE_SEG_HOSTNAME_FORMAT:-short}"

# check if user has hostname command
has_hostname() {
  command -v $1 >/dev/null
}

generate_segmentrc() {
  read -r -d '' rccontents <<EORC
# Use short or long format for the hostname. Can be {"short, long"}.
export TMUX_POWERLINE_SEG_HOSTNAME_FORMAT="${TMUX_POWERLINE_SEG_HOSTNAME_FORMAT}"
EORC
  echo "$rccontents"
}

run_segment() {
  local opts=""
  if [ "$TMUX_POWERLINE_SEG_HOSTNAME_FORMAT" == "short" ]; then
    if shell_is_osx || shell_is_bsd; then
      opts="hostname"
    else
      opts="hostname"
    fi
  fi

  if has_hostname hostname; then
    hostname ${opts}
  else
    hostnamectl hostname
  fi
  return 0
}
