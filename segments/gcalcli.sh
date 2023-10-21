# Print next Google Calendar Event

TMUX_POWERLINE_SEG_GCALCLI_MILITARY_TIME_DEFAULT=1

generate_segmentrc() {
	read -d '' rccontents  << EORC
gcalcli uses military time by default - if you want to see 12 hour time format, set TMUX_POWERLINE_SEG_GCALCLI_MILITARY_TIME_DEFAULT to 0
export TMUX_POWERLINE_SEG_GCALCLI_MILITARY_TIME="${TMUX_POWERLINE_SEG_GCALCLI_MILITARY_TIME_DEFAULT}"
EORC
	echo "$rccontents"
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_GCALCLI_MILITARY_TIME" ]; then
		export TMUX_POWERLINE_SEG_GCALCLI_MILITARY_TIME="${TMUX_POWERLINE_SEG_GCALCLI_MILITARY_TIME_DEFAULT}"
	fi
}

run_segment() {
  if ! command -v gcalcli &> /dev/null
  then
    echo "'gcalcli' could not be found"
    return 1
  fi
  __process_settings
  gcmd=(gcalcli agenda)
  if [[ $TMUX_POWERLINE_SEG_GCALCLI_MILITARY_TIME == 0 ]]; then
    gcmd+=(--no-military)
  fi
  "${gcmd[@]}" | head -2 | tail -1 | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' | sed -E 's/ +/ /g'
	return 0
}
