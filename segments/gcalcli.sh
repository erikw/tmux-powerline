# shellcheck shell=bash
# Print next Google Calendar Event

TMUX_POWERLINE_SEG_GCALCLI_24HR_TIME_FORMAT="${TMUX_POWERLINE_SEG_GCALCLI_24HR_TIME_FORMAT:-1}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# gcalcli uses 24hr time format by default - if you want to see 12hr time format, set TMUX_POWERLINE_SEG_GCALCLI_MILITARY_TIME_DEFAULT to 0
export TMUX_POWERLINE_SEG_GCALCLI_24HR_TIME_FORMAT="${TMUX_POWERLINE_SEG_GCALCLI_24HR_TIME_FORMAT}"
EORC
	echo "$rccontents"
}

run_segment() {
	if ! command -v gcalcli &>/dev/null; then
		echo "'gcalcli' could not be found"
		return 1
	fi
	gcmd=(gcalcli agenda)
	if [[ $TMUX_POWERLINE_SEG_GCALCLI_24HR_TIME_FORMAT == 0 ]]; then
		gcmd+=(--no-military)
	fi
	"${gcmd[@]}" | head -2 | tail -1 | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' | sed -E 's/ +/ /g'
	return 0
}
